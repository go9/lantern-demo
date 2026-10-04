defmodule LanternDemoWeb.App.Pages.Team do
  @moduledoc "Team: members table with role selects, a validated invite dialog and remove-with-undo."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, _params) do
    Phoenix.Component.assign(socket,
      invite_open: false
    )
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Team", path: nil}]

  def actions(_) do
    [
      %{
        label: "Invite member",
        event: "open_invite",
        variant: "solid"
      }
    ]
  end

  def handle_event("open_invite", _params, socket) do
    {:noreply,
     Phoenix.Component.assign(socket,
       invite_open: true
     )}
  end

  def handle_event("invite_dialog_change", %{"open" => o}, socket) do
    {:noreply, Phoenix.Component.assign(socket, invite_open: o in [true, "true"])}
  end

  def handle_event("send_invite", %{"name" => name, "email" => email} = f, socket) do
    name = String.trim(name)
    email = email |> String.trim() |> String.downcase()

    cond do
      name == "" or not Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email) ->
        {:noreply, error_toast(socket, "Enter a name and a valid email address.")}

      true ->
        case Store.invite_member(socket.assigns.sid, %{
               name: name,
               email: email,
               role: f["role"] || "member"
             }) do
          {:ok, member} ->
            {:noreply,
             socket
             |> Phoenix.Component.assign(invite_open: false)
             |> Phoenix.LiveView.push_event("acme:reset-form", %{id: "invite-form"})
             |> LanternDemoWeb.AppLive.toast(
               :success,
               "#{member.name} was invited as #{f["role"] || "member"}.", title: "Invite sent")}

          {:error, :taken} ->
            {:noreply, error_toast(socket, "#{email} is already on the team.")}
        end
    end
  end

  def handle_event("set_role", %{"id" => "role-" <> rest, "value" => v}, socket) do
    value = v |> List.wrap() |> List.first()
    idx = rest |> String.replace_suffix("-select", "") |> String.to_integer()
    member = Enum.at(socket.assigns.members, idx)

    if member && member.role != value do
      Store.update_member_role(socket.assigns.sid, member.email, value)

      {:noreply,
       LanternDemoWeb.AppLive.toast(socket, :success, "#{member.name} is now #{value}.",
         title: "Role updated"
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("remove_member", %{"email" => email}, socket) do
    case Store.remove_member(socket.assigns.sid, email) do
      nil ->
        {:noreply, socket}

      member ->
        {:noreply,
         socket
         |> Phoenix.Component.assign(undo: {:member, member})
         |> LanternDemoWeb.AppLive.toast(:warning, "#{member.name} was removed from Acme.",
           title: "Member removed",
           duration: 8000,
           action: %{label: "Undo", event: "undo"}
         )}
    end
  end

  def handle_event(_, _, _), do: :unhandled

  defp error_toast(socket, message) do
    LanternDemoWeb.AppLive.toast(socket, :error, message, title: "Couldn't send the invite")
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:meta, %{
        params: %{},
        current_page: 1,
        total_pages: 1,
        page_size: 25,
        total_count: length(assigns.members)
      })
      |> assign(:rows, Enum.with_index(assigns.members, fn m, i -> Map.put(m, :idx, i) end))

    ~H"""
    <.data_table
      id="team"
      rows={@rows}
      meta={@meta}
      path="/app/team"
      views={["table"]}
      show_checkboxes={false}
      row_id={& &1.email}
      row_navigate={&"/app/tickets?filters[0][field]=assignee&filters[0][value]=#{URI.encode_www_form(&1.email)}"}
      flush
    >
      <:col label="Member" :let={m}>
        <span class="acme-person">
          <.avatar size="sm" initials={m.initials} />
          <span>
            <strong>{m.name}</strong>
            <span class="acme-muted acme-block">{m.email}</span>
          </span>
        </span>
      </:col>
      <:col label="Role" :let={m}>
        <.select
          id={"role-#{m.idx}"}
          name={"role_#{m.idx}"}
          size="sm"
          class="acme-role-select"
          controlled
          on_change="set_role"
          value={m.role}
          options={Helpers.role_options()}
          aria-label={"Role for #{m.name}"}
        />
      </:col>
      <:row_action :let={m}>
        <.dropdown id={"member-menu-#{m.idx}"} placement="bottom-end">
          <:toggle>
            <.button size="sm" variant="ghost" aria-label={"Actions for #{m.name}"}>
              <.icon name="ellipsis-horizontal" />
            </.button>
          </:toggle>
          <.dropdown_link patch={"/app/tickets?filters[0][field]=assignee&filters[0][value]=#{URI.encode_www_form(m.email)}"}>
            View tickets
          </.dropdown_link>
          <.dropdown_separator />
          <.dropdown_button phx-click="remove_member" phx-value-email={m.email} data-danger>
            Remove from team
          </.dropdown_button>
        </.dropdown>
      </:row_action>
    </.data_table>

    <.modal id="invite-dialog" open={@invite_open} on_change="invite_dialog_change" aria_labelledby="invite-title">
      <%!-- see projects.ex: dialog forms are driven by the AcmeDialogForm hook (native validation, no re-render) --%>
      <form id="invite-form" phx-hook="AcmeDialogForm" data-enter="send_invite" class="acme-form">
        <.stack gap="md">
          <div>
            <h2 id="invite-title" class="acme-dialog-title">Invite a teammate</h2>
            <p class="acme-muted">They'll get an email with a link to join Acme.</p>
          </div>
          <.input id="invite-name" name="name" label="Name" placeholder="Margaret Hamilton" required maxlength="60" />
          <.input id="invite-email" name="email" type="email" label="Email" placeholder="margaret@acme.test" required />
          <.select id="invite-role" name="role" label="Role" value="member" options={Helpers.role_options()} />
          <div class="acme-dialog-actions">
            <.button type="button" variant="ghost" phx-click={LanternUI.close_dialog("invite-dialog")}>Cancel</.button>
            <.button type="button" variant="solid" data-submit="send_invite">Send invite</.button>
          </div>
        </.stack>
      </form>
    </.modal>
    """
  end
end
