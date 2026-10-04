defmodule LanternDemoWeb.App.Pages.Notifications do
  @moduledoc "Inbox of notifications: flat list, All / Unread chips, mark-all-read, clear with undo."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store

  def mount_page(socket, _params) do
    Phoenix.Component.assign(socket,
      notes: Store.list_notifications(socket.assigns.sid),
      n_filter: Map.get(socket.assigns, :n_filter, "all")
    )
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Notifications", path: nil}]

  def actions(assigns) do
    unread = Enum.count(assigns.notes, &(!&1.read))

    [
      %{label: "Mark all read", event: "mark_all_read", disabled: unread == 0},
      %{label: "Clear all", event: "clear_all", disabled: assigns.notes == []}
    ]
  end

  def handle_event("n_filter", %{"f" => f}, socket) do
    {:noreply, Phoenix.Component.assign(socket, n_filter: f)}
  end

  def handle_event("mark_all_read", _params, socket) do
    Store.mark_all_read(socket.assigns.sid)

    {:noreply,
     socket
     |> mount_page(%{})
     |> LanternDemoWeb.AppLive.toast(:success, "Everything is marked as read.",
       title: "All caught up"
     )}
  end

  def handle_event("clear_all", _params, socket) do
    notes = Store.clear_notifications(socket.assigns.sid)

    {:noreply,
     socket
     |> mount_page(%{})
     |> Phoenix.Component.assign(undo: {:notifications, notes})
     |> LanternDemoWeb.AppLive.toast(:warning, "#{length(notes)} notifications were cleared.",
       title: "Inbox cleared",
       duration: 8000,
       action: %{label: "Undo", event: "undo"}
     )}
  end

  def handle_event("open_note", %{"id" => id}, socket) do
    Store.mark_read(socket.assigns.sid, LanternDemoWeb.App.Helpers.to_int(id, 0))
    {:noreply, socket}
  end

  def handle_event(_, _, _), do: :unhandled

  defp shown(notes, "unread"), do: Enum.reject(notes, & &1.read)
  defp shown(notes, _), do: notes

  def icon_for("mention"), do: "pencil-square"
  def icon_for("review"), do: "check-circle"
  def icon_for("status"), do: "check"
  def icon_for("invite"), do: "globe-alt"
  def icon_for(_), do: "information-circle"

  def render(%{view_state: "loading"} = assigns) do
    ~H"""
    <div aria-busy="true" aria-label="Loading notifications" class="acme-skel-list">
      <.skeleton :for={_ <- 1..6} style="height: 3rem;" />
    </div>
    """
  end

  def render(assigns) do
    assigns = assign(assigns, :unread_n, Enum.count(assigns.notes, &(!&1.read)))

    ~H"""
    <.card flush title="Inbox" class="acme-notes">
      <:actions>
        <div class="acme-chips" role="group" aria-label="Filter notifications">
          <.button size="sm" variant={if @n_filter == "all", do: "solid", else: "outline"} phx-click="n_filter" phx-value-f="all" aria-pressed={to_string(@n_filter == "all")}>
            All <span class="acme-chip-count">{length(@notes)}</span>
          </.button>
          <.button size="sm" variant={if @n_filter == "unread", do: "solid", else: "outline"} phx-click="n_filter" phx-value-f="unread" aria-pressed={to_string(@n_filter == "unread")}>
            Unread <span class="acme-chip-count">{@unread_n}</span>
          </.button>
        </div>
      </:actions>
      <.list_row
        :for={n <- shown(@notes, @n_filter)}
        title={n.title}
        class={[!n.read && "acme-unread"]}
        patch={n.link}
        phx-click="open_note"
        phx-value-id={n.id}
      >
        <:leading>
          <.icon name={icon_for(n.kind)} />
        </:leading>
        <:meta><span class="acme-muted">{n.body}</span></:meta>
        <:trailing>
          <.badge :if={!n.read} size="sm" color="primary">new</.badge>
          {n.at}
        </:trailing>
      </.list_row>
      <.empty_state
        :if={shown(@notes, @n_filter) == []}
        icon="inbox"
        title={if @notes == [], do: "Nothing here", else: "You're all caught up"}
      >
        {if @notes == [], do: "New mentions and reviews will land here.", else: "No unread notifications."}
      </.empty_state>
    </.card>
    """
  end
end
