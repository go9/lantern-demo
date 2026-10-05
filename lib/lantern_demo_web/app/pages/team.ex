defmodule LanternDemoWeb.App.Pages.Team do
  @moduledoc "Team: members table with role selects, a validated invite dialog and remove-with-undo."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, _params) do
    Phoenix.Component.assign(socket,
      invite_open: false,
      invite_form: %{"name" => "", "email" => "", "role" => "member"},
      invite_errors: %{}
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
       invite_open: true,
       invite_form: %{"name" => "", "email" => "", "role" => "member"},
       invite_errors: %{}
     )}
  end

  def handle_event("invite_dialog_change", %{"open" => o}, socket) do
    {:noreply, Phoenix.Component.assign(socket, invite_open: o in [true, "true"])}
  end

  def handle_event("invite_change", %{"invite" => f}, socket) do
    {:noreply,
     Phoenix.Component.assign(socket,
       invite_form: f,
       invite_errors: validate(f, socket.assigns.members)
     )}
  end

  def handle_event("send_invite", %{"invite" => f}, socket) do
    case validate(f, socket.assigns.members) do
      errors when map_size(errors) > 0 ->
        {:noreply, Phoenix.Component.assign(socket, invite_form: f, invite_errors: errors)}

      _ ->
        role = if f["role"] in Store.roles(), do: f["role"], else: "member"

        case Store.invite_member(socket.assigns.sid, %{
               name: String.trim(f["name"]),
               email: f["email"] |> String.trim() |> String.downcase(),
               role: role
             }) do
          {:ok, member} ->
            {:noreply,
             socket
             |> Phoenix.Component.assign(invite_open: false)
             |> LanternDemoWeb.AppLive.toast(:success, "#{member.name} was invited as #{role}.",
               title: "Invite sent"
             )}

          {:error, :taken} ->
            {:noreply,
             Phoenix.Component.assign(socket,
               invite_form: f,
               invite_errors: %{"email" => ["is already on the team"]}
             )}

          {:error, :limit} ->
            {:noreply,
             Phoenix.Component.assign(socket,
               invite_form: f,
               invite_errors: %{"email" => ["team size limit reached for this demo"]}
             )}
        end
    end
  end

  def handle_event("set_role", %{"id" => "role-" <> rest, "value" => v}, socket) do
    value = v |> List.wrap() |> List.first()
    idx = rest |> String.replace_suffix("-select", "") |> Helpers.to_int(-1)
    member = if idx >= 0, do: Enum.at(socket.assigns.members, idx)

    if member && value in ~w(admin member viewer) && member.role != value do
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

  defp validate(f, members) do
    name = String.trim(f["name"] || "")
    email = f["email"] |> to_string() |> String.trim() |> String.downcase()

    %{}
    |> then(fn e -> if name == "", do: Map.put(e, "name", ["can't be blank"]), else: e end)
    |> then(fn e ->
      cond do
        email == "" ->
          Map.put(e, "email", ["can't be blank"])

        not Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email) ->
          Map.put(e, "email", ["must be a valid email"])

        Enum.any?(members, &(&1.email == email)) ->
          Map.put(e, "email", ["is already on the team"])

        true ->
          e
      end
    end)
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
      <form id="invite-form" phx-change="invite_change" phx-submit="send_invite" class="acme-form">
        <.stack gap="md">
          <div>
            <h2 id="invite-title" class="acme-dialog-title">Invite a teammate</h2>
            <p class="acme-muted">They'll get an email with a link to join Acme.</p>
          </div>
          <.input id="invite-name" name="invite[name]" label="Name" placeholder="Margaret Hamilton" value={@invite_form["name"]} errors={Map.get(@invite_errors, "name", [])} />
          <.input id="invite-email" name="invite[email]" type="email" label="Email" placeholder="margaret@acme.test" value={@invite_form["email"]} errors={Map.get(@invite_errors, "email", [])} />
          <.select id="invite-role" name="invite[role]" label="Role" value={@invite_form["role"]} options={Helpers.role_options()} />
          <div class="acme-dialog-actions">
            <.button type="button" variant="ghost" phx-click={LanternUI.close_dialog("invite-dialog")}>Cancel</.button>
            <.button type="submit" variant="solid">Send invite</.button>
          </div>
        </.stack>
      </form>
    </.modal>
    """
  end
end
