defmodule LanternDemoWeb.App.Pages.Ticket do
  @moduledoc """
  Ticket detail (detail + inspector recipe): description, comments with a
  validated composer, an activity timeline, and an inspector whose status,
  priority and assignee are Zag selects driven by the server.
  """
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, %{"args" => [id]}) do
    sid = socket.assigns.sid

    Phoenix.Component.assign(socket,
      ticket: Store.get_ticket(sid, id),
      projects: Store.list_projects(sid),
      panel_open: Map.get(socket.assigns, :panel_open, true),
      comment_draft: "",
      comment_error: nil
    )
  end

  def crumbs(%{ticket: nil}),
    do: [
      %{label: "Acme", path: "/app"},
      %{label: "Tickets", path: "/app/tickets"},
      %{label: "Not found", path: nil}
    ]

  def crumbs(%{ticket: t}) do
    [
      %{label: "Acme", path: "/app"},
      %{label: "Tickets", path: "/app/tickets"},
      %{label: t.identifier, path: nil}
    ]
  end

  def actions(%{ticket: nil}), do: []

  def actions(%{ticket: t} = assigns) do
    [
      %{
        kind: :panel_toggle,
        label: "Toggle properties panel",
        event: "toggle_panel",
        open: assigns.panel_open
      },
      %{label: "Edit", navigate: "/app/tickets/#{t.id}/edit"},
      %{label: "Delete ticket", event: "delete_ticket", color: "danger"}
    ]
  end

  # ── events ──

  def handle_event("set_panel", %{"open" => open}, socket) do
    {:noreply, Phoenix.Component.assign(socket, panel_open: open == true or open == "true")}
  end

  def handle_event("toggle_panel", _params, socket) do
    {:noreply, Phoenix.Component.assign(socket, panel_open: !socket.assigns.panel_open)}
  end

  def handle_event("side_panel", _params, socket), do: {:noreply, socket}

  def handle_event("set_field", %{"id" => "ticket-status-select", "value" => v}, socket) do
    change(socket, :status, Helpers.pick(%{"value" => v}), "Status", &Helpers.status_label/1)
  end

  def handle_event("set_field", %{"id" => "ticket-priority-select", "value" => v}, socket) do
    change(
      socket,
      :priority,
      Helpers.pick(%{"value" => v}),
      "Priority",
      &Helpers.priority_label/1
    )
  end

  def handle_event("set_field", %{"id" => "ticket-assignee-select", "value" => v}, socket) do
    change(
      socket,
      :assignee,
      Helpers.pick(%{"value" => v}),
      "Assignee",
      &Helpers.name_for(socket.assigns.members, &1)
    )
  end

  def handle_event("comment_change", %{"comment" => %{"body" => body}}, socket) do
    {:noreply, Phoenix.Component.assign(socket, comment_draft: body, comment_error: nil)}
  end

  def handle_event("add_comment", %{"comment" => %{"body" => body}}, socket) do
    body = String.trim(body)

    if body == "" do
      {:noreply, Phoenix.Component.assign(socket, comment_error: "Write something first.")}
    else
      t = socket.assigns.ticket
      Store.add_comment(socket.assigns.sid, t.id, %{author: socket.assigns.user.name, body: body})

      {:noreply,
       socket
       |> reload()
       |> Phoenix.Component.assign(comment_draft: "", comment_error: nil)
       |> LanternDemoWeb.AppLive.toast(:success, "Your comment is on #{t.identifier}.",
         title: "Comment added"
       )}
    end
  end

  def handle_event("delete_ticket", _params, socket) do
    t = socket.assigns.ticket
    Store.delete_ticket(socket.assigns.sid, t.id)

    {:noreply,
     socket
     |> Phoenix.Component.assign(undo: {:ticket, t})
     |> LanternDemoWeb.AppLive.toast(:warning, "#{t.identifier} “#{t.title}” was deleted.",
       title: "Ticket deleted",
       duration: 8000,
       action: %{label: "Undo", event: "undo"}
     )
     |> Phoenix.LiveView.push_patch(to: "/app/tickets")}
  end

  def handle_event(_, _, _), do: :unhandled

  defp change(socket, field, value, label, fmt) do
    t = socket.assigns.ticket

    value =
      case field do
        :status ->
          Helpers.to_atom_in(value, [:todo, :in_progress, :done], t.status)

        :priority ->
          Helpers.to_atom_in(value, [:low, :medium, :high, :urgent], t.priority)

        :assignee ->
          if Enum.any?(socket.assigns.members, &(&1.email == value)), do: value, else: t.assignee
      end

    if Map.get(t, field) == value do
      {:noreply, socket}
    else
      note = "#{label} changed to #{fmt.(value)}"
      Store.update_ticket(socket.assigns.sid, t.id, %{field => value, note: note})

      {:noreply,
       socket
       |> reload()
       |> LanternDemoWeb.AppLive.toast(:success, "#{label} is now #{fmt.(value)}.",
         title: "#{t.identifier} updated"
       )}
    end
  end

  defp reload(socket) do
    Phoenix.Component.assign(socket,
      ticket: Store.get_ticket(socket.assigns.sid, socket.assigns.ticket.id)
    )
  end

  # ── render ──

  def render(%{ticket: nil} = assigns) do
    ~H"""
    <.empty_state icon="exclamation-circle" title="Ticket not found">
      It may have been deleted.
      <:action><.button size="sm" variant="solid" patch="/app/tickets">Back to tickets</.button></:action>
    </.empty_state>
    """
  end

  def render(assigns) do
    ~H"""
    <.stack gap="lg">
      <.page_header title={@ticket.title} description={"#{@ticket.identifier} · #{Helpers.project_name(@projects, @ticket.project_id)}"} />
      <div class="acme-detail">
        <.stack gap="lg" class="acme-detail-main">
          <.card title="Description">
            <p :if={@ticket.body != ""} class="acme-body">{@ticket.body}</p>
            <p :if={@ticket.body == ""} class="acme-muted">No description yet.</p>
          </.card>

          <.card title={"Comments (#{length(@ticket.comments)})"}>
            <.stack gap="md">
              <div :for={c <- @ticket.comments} class="acme-comment">
                <.avatar size="sm" initials={c.initials} />
                <div>
                  <div class="acme-comment-head"><strong>{c.author}</strong> <span class="acme-muted">{c.at}</span></div>
                  <p class="acme-body">{c.body}</p>
                </div>
              </div>
              <p :if={@ticket.comments == []} class="acme-muted">No comments yet — start the thread.</p>
              <form id="comment-form" phx-change="comment_change" phx-submit="add_comment">
                <.stack gap="sm">
                  <.textarea
                    id="comment-body"
                    name="comment[body]"
                    label="Add a comment"
                    rows={3}
                    placeholder="Write a comment…"
                    value={@comment_draft}
                    errors={if @comment_error, do: [@comment_error], else: []}
                  />
                  <div><.button size="sm" variant="solid" type="submit">Comment</.button></div>
                </.stack>
              </form>
            </.stack>
          </.card>

          <.card title="Activity">
            <.timeline>
              <.timeline_item
                :for={{a, i} <- Enum.with_index(@ticket.activity)}
                status={if i == 0, do: :active, else: :done}
                label={a.text}
                at={a.at}
              />
            </.timeline>
          </.card>
        </.stack>

        <.side_panel id="ticket-panel" open={@panel_open} aria-label="Ticket properties">
          <.inspector aria-label="Ticket">
            <.inspector_section title="Properties">
              <.stack gap="md">
                <.select
                  id="ticket-status"
                  name="status"
                  label="Status"
                  controlled
                  on_change="set_field"
                  value={Atom.to_string(@ticket.status)}
                  options={Helpers.status_options()}
                />
                <.select
                  id="ticket-priority"
                  name="priority"
                  label="Priority"
                  controlled
                  on_change="set_field"
                  value={Atom.to_string(@ticket.priority)}
                  options={Helpers.priority_options()}
                />
                <.select
                  id="ticket-assignee"
                  name="assignee"
                  label="Assignee"
                  controlled
                  on_change="set_field"
                  value={@ticket.assignee}
                  options={Helpers.member_options(@members)}
                />
              </.stack>
            </.inspector_section>
            <.inspector_section title="Details">
              <.description_list layout="dense">
                <:item label="Project">
                  <.link patch={"/app/projects/#{@ticket.project_id}"} class="acme-link">
                    {Helpers.project_name(@projects, @ticket.project_id)}
                  </.link>
                </:item>
                <:item label="Tag"><.badge size="sm">{@ticket.tag}</.badge></:item>
                <:item label="Created">{Helpers.fmt_date(@ticket.date)}</:item>
              </.description_list>
            </.inspector_section>
          </.inspector>
        </.side_panel>
      </div>
    </.stack>
    """
  end
end
