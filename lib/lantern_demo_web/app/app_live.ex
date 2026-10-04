defmodule LanternDemoWeb.AppLive do
  @moduledoc """
  The /app demo: a small ticket tracker ("Acme") built only from lantern
  components. One LiveView owns routing (`/app/*path`), auth gating, the shell,
  toasts + undo, and the Cmd+K palette; each page is a module under
  `LanternDemoWeb.App.Pages` with `mount_page/2`, `crumbs/1`, `actions/1`,
  `render/1` and `handle_event/3`.

  State is per visitor (`DemoApp.Store`, keyed by a session-cookie id) — it
  lives in memory only and resets after two idle hours.
  """
  use Phoenix.LiveView
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Pages
  alias LanternDemoWeb.App.Shell

  @pages %{
    login: Pages.Login,
    dashboard: Pages.Dashboard,
    tickets: Pages.Tickets,
    ticket: Pages.Ticket,
    ticket_new: Pages.TicketForm,
    ticket_edit: Pages.TicketForm,
    projects: Pages.Projects,
    project: Pages.Project,
    team: Pages.Team,
    settings: Pages.Settings,
    notifications: Pages.Notifications,
    not_found: Pages.NotFound
  }

  def mount(_params, session, socket) do
    sid = session["app_sid"] || Base.url_encode64(:crypto.strong_rand_bytes(12), padding: false)

    {:ok,
     socket
     |> assign(sid: sid, page: :login, page_title: "Acme", view_state: nil, undo: nil)
     |> assign(palette_query: "", palette_groups: palette_groups(sid, ""))
     |> refresh_shell()}
  end

  # ── routing ──

  def handle_params(params, _uri, socket) do
    {page, args} = route(params["path"] || [])
    sid = socket.assigns.sid
    signed_in = Store.signed_in?(sid)

    cond do
      page != :login and not signed_in ->
        {:noreply, push_patch(socket, to: "/app/login")}

      page == :login and signed_in ->
        {:noreply, push_patch(socket, to: "/app")}

      true ->
        mod = Map.fetch!(@pages, page)

        socket =
          socket
          |> assign(page: page, args: args, params: params, mod: mod)
          |> assign(view_state: view_state(params["state"]))
          |> refresh_shell()
          |> mod.mount_page(Map.merge(params, %{"args" => args}))

        {:noreply, assign(socket, :page_title, title(socket) <> " · Acme")}
    end
  end

  defp route([]), do: {:dashboard, []}
  defp route(["login"]), do: {:login, []}
  defp route(["tickets"]), do: {:tickets, []}
  defp route(["tickets", "new"]), do: {:ticket_new, []}
  defp route(["tickets", id]), do: {:ticket, [id]}
  defp route(["tickets", id, "edit"]), do: {:ticket_edit, [id]}
  defp route(["projects"]), do: {:projects, []}
  defp route(["projects", id]), do: {:project, [id]}
  defp route(["team"]), do: {:team, []}
  defp route(["settings"]), do: {:settings, []}
  defp route(["notifications"]), do: {:notifications, []}
  defp route(_), do: {:not_found, []}

  defp view_state(s) when s in ~w(loading error empty), do: s
  defp view_state(_), do: nil

  defp title(socket) do
    case socket.assigns.mod.crumbs(socket.assigns) do
      [] -> "Acme"
      crumbs -> crumbs |> List.last() |> Map.fetch!(:label)
    end
  end

  # ── shell data ──

  defp refresh_shell(socket) do
    sid = socket.assigns.sid
    settings = Store.get_settings(sid)
    members = Store.list_members(sid)

    assign(socket,
      counts: Store.counts(sid),
      unread: Store.unread_count(sid),
      settings: settings,
      appearance: settings.appearance,
      members: members,
      user: Enum.find(members, &(&1.email == settings.email)) || hd(members)
    )
  end

  # ── events ──

  def handle_event("sign_out", _params, socket) do
    Store.sign_out(socket.assigns.sid)

    {:noreply,
     socket
     |> put_flash(:info, "You've been signed out.")
     |> push_patch(to: "/app/login")}
  end

  def handle_event("toggle_theme", _params, socket) do
    next = if socket.assigns.appearance.theme == "dark", do: "light", else: "dark"
    Store.update_appearance(socket.assigns.sid, %{theme: next})
    {:noreply, socket |> refresh_shell() |> toast(:info, "Switched to #{next} mode.")}
  end

  def handle_event("palette_search", %{"query" => q}, socket) do
    {:noreply,
     assign(socket, palette_query: q, palette_groups: palette_groups(socket.assigns.sid, q))}
  end

  def handle_event("palette_select", %{"value" => value}, socket) do
    socket = LanternUI.close_dialog(socket, "acme-palette")

    case value do
      "go:" <> path -> {:noreply, push_patch(socket, to: path)}
      "ticket:" <> id -> {:noreply, push_patch(socket, to: "/app/tickets/#{id}")}
      "act:new-ticket" -> {:noreply, push_patch(socket, to: "/app/tickets/new")}
      "act:toggle-theme" -> handle_event("toggle_theme", %{}, socket)
      "act:sign-out" -> handle_event("sign_out", %{}, socket)
      "act:" <> state -> {:noreply, push_patch(socket, to: "/app/tickets?state=#{state}")}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("undo", _params, socket) do
    sid = socket.assigns.sid

    case socket.assigns.undo do
      {:ticket, ticket} ->
        Store.restore_ticket(sid, ticket.id)

        {:noreply,
         socket
         |> assign(undo: nil)
         |> refresh_shell()
         |> Pages.refresh()
         |> toast(:success, "#{ticket.identifier} restored.", title: "Undone")}

      {:member, member} ->
        Store.restore_member(sid, member)

        {:noreply,
         socket
         |> assign(undo: nil)
         |> refresh_shell()
         |> Pages.refresh()
         |> toast(:success, "#{member.name} is back on the team.", title: "Undone")}

      {:notifications, notes} ->
        Store.restore_notifications(sid, notes)

        {:noreply,
         socket
         |> assign(undo: nil)
         |> refresh_shell()
         |> Pages.refresh()
         |> toast(:success, "Notifications restored.", title: "Undone")}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(event, params, socket) do
    case socket.assigns.mod.handle_event(event, params, socket) do
      {:noreply, socket} -> {:noreply, socket |> refresh_shell()}
      :unhandled -> {:noreply, socket}
    end
  end

  # ── render ──

  def render(%{page: :login} = assigns), do: Pages.Login.render(assigns)

  def render(assigns) do
    ~H"""
    <Shell.shell
      page={@page}
      crumbs={@mod.crumbs(assigns)}
      actions={@mod.actions(assigns)}
      appearance={@appearance}
      counts={@counts}
      unread={@unread}
      user={@user}
      flash={@flash}
      palette_groups={@palette_groups}
      palette_query={@palette_query}
    >
      {@mod.render(assigns)}
    </Shell.shell>
    """
  end

  # ── palette ──

  @nav [
    {"Dashboard", "/app", "chart-bar"},
    {"Tickets", "/app/tickets", "document"},
    {"Notifications", "/app/notifications", "inbox"},
    {"Projects", "/app/projects", "folder"},
    {"Team", "/app/team", "globe-alt"},
    {"Settings", "/app/settings", "adjustments-horizontal"}
  ]

  @actions [
    {"act:new-ticket", "New ticket", "plus", "Create a ticket"},
    {"act:toggle-theme", "Toggle dark mode", "adjustments-horizontal", "Flip light and dark"},
    {"act:loading", "Preview the loading state", "arrow-path", "Tickets, with a skeleton"},
    {"act:error", "Preview the error state", "exclamation-circle", "Tickets, with a retry"},
    {"act:empty", "Preview the empty state", "inbox", "Tickets, with nothing in them"},
    {"act:sign-out", "Sign out", "arrow-right", "Back to the login screen"}
  ]

  def palette_groups(sid, query) do
    q = query |> String.trim() |> String.downcase()
    match? = fn text -> q == "" or String.contains?(String.downcase(text), q) end

    nav =
      for {label, path, icon} <- @nav, match?.(label) do
        %{value: "go:" <> path, label: "Go to #{label}", icon: icon}
      end

    actions =
      for {value, label, icon, desc} <- @actions, match?.(label) do
        %{value: value, label: label, icon: icon, description: desc}
      end

    tickets =
      if q == "" do
        []
      else
        sid
        |> Store.list_tickets()
        |> Enum.filter(&(match?.(&1.title) or match?.(&1.identifier)))
        |> Enum.take(6)
        |> Enum.map(
          &%{
            value: "ticket:#{&1.id}",
            label: "#{&1.identifier} #{&1.title}",
            icon: "document",
            description: LanternDemoWeb.App.Helpers.status_label(&1.status)
          }
        )
      end

    [{"Tickets", tickets}, {"Navigate", nav}, {"Actions", actions}]
    |> Enum.reject(fn {_, items} -> items == [] end)
  end

  def toast(socket, kind, message, opts \\ []),
    do: LanternUI.send_toast(socket, kind, message, opts)
end
