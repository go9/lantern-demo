defmodule LanternDemoWeb.App.Pages.Project do
  @moduledoc "One project (overview recipe): header + progress ring, a stat strip and a flat ticket list with filter chips."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, %{"args" => [id]}) do
    sid = socket.assigns.sid
    project = Store.get_project(sid, id)
    tickets = if project, do: Store.project_tickets(sid, project.id), else: []

    Phoenix.Component.assign(socket,
      project: project,
      p_tickets: tickets,
      p_filter: Map.get(socket.assigns, :p_filter, "all")
    )
  end

  def crumbs(%{project: nil}),
    do: [
      %{label: "Acme", path: "/app"},
      %{label: "Projects", path: "/app/projects"},
      %{label: "Not found", path: nil}
    ]

  def crumbs(%{project: p}),
    do: [
      %{label: "Acme", path: "/app"},
      %{label: "Projects", path: "/app/projects"},
      %{label: p.name, path: nil}
    ]

  def actions(%{project: nil}), do: []

  def actions(%{project: p}),
    do: [%{label: "New ticket", navigate: "/app/tickets/new?project=#{p.id}", variant: "solid"}]

  def handle_event("project_filter", %{"status" => s}, socket) do
    {:noreply, Phoenix.Component.assign(socket, p_filter: s)}
  end

  def handle_event(_, _, _), do: :unhandled

  defp shown(tickets, "all"), do: tickets
  defp shown(tickets, s), do: Enum.filter(tickets, &(Atom.to_string(&1.status) == s))
  defp count(tickets, s), do: tickets |> shown(s) |> length()

  def render(%{project: nil} = assigns) do
    ~H"""
    <.empty_state icon="folder" title="Project not found">
      It may have been removed.
      <:action><.button size="sm" variant="solid" patch="/app/projects">All projects</.button></:action>
    </.empty_state>
    """
  end

  def render(assigns) do
    assigns = assign(assigns, :done, count(assigns.p_tickets, "done"))

    ~H"""
    <.stack gap="lg">
      <.page_header title={@project.name} description={@project.summary}>
        <:actions>
          <.progress shape="ring" completed={@done} scope={length(@p_tickets)} label="Progress">
            {@done}/{length(@p_tickets)}
          </.progress>
        </:actions>
      </.page_header>
      <.stat_grid>
        <:stat label="Tickets" value={length(@p_tickets)} />
        <:stat label="In progress" value={count(@p_tickets, "in_progress")} />
        <:stat label="To do" value={count(@p_tickets, "todo")} />
        <:stat label="Done" value={@done} />
      </.stat_grid>
      <.card flush title="Tickets">
        <:actions>
          <div class="acme-chips" role="group" aria-label="Filter project tickets">
            <.button
              :for={{label, key} <- [{"All", "all"}, {"In progress", "in_progress"}, {"To do", "todo"}, {"Done", "done"}]}
              size="sm"
              variant={if @p_filter == key, do: "solid", else: "outline"}
              phx-click="project_filter"
              phx-value-status={key}
              aria-pressed={to_string(@p_filter == key)}
            >
              {label} <span class="acme-chip-count">{count(@p_tickets, key)}</span>
            </.button>
          </div>
        </:actions>
        <.list_row
          :for={t <- shown(@p_tickets, @p_filter)}
          identifier={t.identifier}
          title={t.title}
          patch={"/app/tickets/#{t.id}"}
        >
          <:leading>
            <.priority_glyph priority={t.priority} />
            <.status_glyph status={t.status} />
            <span class="lui-list-row-status">{Helpers.status_label(t.status)}</span>
          </:leading>
          <:meta><.badge size="sm">{t.tag}</.badge></:meta>
          <:trailing>
            <.avatar size="xs" initials={Helpers.initials_for(@members, t.assignee)} />
            {Helpers.fmt_date(t.date)}
          </:trailing>
        </.list_row>
        <.empty_state :if={shown(@p_tickets, @p_filter) == []} icon="document" title="No tickets here">
          {if @p_tickets == [], do: "This project has no tickets yet.", else: "Nothing matches that filter."}
          <:action>
            <.button size="sm" variant="solid" patch={"/app/tickets/new?project=#{@project.id}"}>New ticket</.button>
          </:action>
        </.empty_state>
      </.card>
    </.stack>
    """
  end
end
