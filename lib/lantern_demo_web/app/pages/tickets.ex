defmodule LanternDemoWeb.App.Pages.Tickets do
  @moduledoc """
  The tickets index: one flat `data_table` — status column, filter chips with
  counts, search, sortable headers, pagination, whole-row click. Every bit of
  table state lives in the URL (`filters`, `order_by`, `page`).
  """
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, params) do
    sid = socket.assigns.sid
    tickets = Store.list_tickets(sid)
    {rows, meta} = query(tickets, Map.drop(params, ["args", "path"]))

    Phoenix.Component.assign(socket,
      rows: rows,
      meta: meta,
      all_tickets: tickets,
      tab_counts: tab_counts(tickets)
    )
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Tickets", path: nil}]

  def actions(_) do
    [%{label: "New ticket", navigate: "/app/tickets/new", variant: "solid"}]
  end

  def handle_event(_, _, _), do: :unhandled

  # ── querying ──

  defp query(tickets, params) do
    filters = filters(params)

    rows =
      tickets
      |> filter(filters)
      |> sort(params)

    page_size = Helpers.parse_int(params["page_size"], 8)
    total = length(rows)
    total_pages = max(1, ceil(total / page_size))
    page = params["page"] |> Helpers.parse_int(1) |> max(1) |> min(total_pages)

    meta = %{
      params: params,
      current_page: page,
      total_pages: total_pages,
      page_size: page_size,
      total_count: total
    }

    {Enum.slice(rows, (page - 1) * page_size, page_size), meta}
  end

  defp filters(params) do
    params
    |> Map.get("filters", %{})
    |> then(fn
      m when is_map(m) -> Map.values(m)
      l when is_list(l) -> l
      _ -> []
    end)
    |> Enum.filter(&is_map/1)
    |> Enum.reject(&(&1["value"] in [nil, "", []]))
  end

  defp filter(tickets, filters) do
    Enum.reduce(filters, tickets, fn %{"field" => field, "value" => value}, acc ->
      case field do
        "status" ->
          Enum.filter(acc, &(Atom.to_string(&1.status) in List.wrap(value)))

        "priority" ->
          Enum.filter(acc, &(Atom.to_string(&1.priority) in List.wrap(value)))

        "assignee" ->
          Enum.filter(acc, &(&1.assignee in List.wrap(value)))

        "title" ->
          Enum.filter(
            acc,
            &String.contains?(String.downcase(&1.title), String.downcase(to_string(value)))
          )

        _ ->
          acc
      end
    end)
  end

  defp sort(rows, params) do
    by = params |> Map.get("order_by", []) |> List.wrap() |> List.first()
    dir = params |> Map.get("order_directions", ["asc"]) |> List.wrap() |> List.first()

    key =
      case by do
        "status" -> &Helpers.status_rank(&1.status)
        "id" -> & &1.id
        "title" -> &String.downcase(&1.title)
        "priority" -> &Helpers.priority_rank(&1.priority)
        "assignee" -> & &1.assignee
        "date" -> &Date.to_gregorian_days(&1.date)
        _ -> nil
      end

    cond do
      is_nil(key) -> rows
      dir == "desc" -> Enum.sort_by(rows, key, :desc)
      true -> Enum.sort_by(rows, key, :asc)
    end
  end

  defp tab_counts(tickets) do
    %{
      all: length(tickets),
      in_progress: Enum.count(tickets, &(&1.status == :in_progress)),
      todo: Enum.count(tickets, &(&1.status == :todo)),
      done: Enum.count(tickets, &(&1.status == :done))
    }
  end

  # ── render ──

  def render(%{view_state: "loading"} = assigns) do
    ~H"""
    <div aria-busy="true" aria-label="Loading tickets" class="acme-skel-list">
      <.skeleton :for={_ <- 1..8} style="height: 2.5rem;" />
    </div>
    """
  end

  def render(%{view_state: "error"} = assigns) do
    ~H"""
    <.alert color="danger" title="Couldn't load tickets">
      The tickets service timed out. This is a simulated failure — nothing is wrong with your data.
      <.button size="sm" variant="outline" patch="/app/tickets">Try again</.button>
    </.alert>
    """
  end

  def render(%{view_state: "empty"} = assigns) do
    ~H"""
    <.empty_state icon="document" title="No tickets yet">
      Create the first ticket to start the list.
      <:action><.button size="sm" variant="solid" patch="/app/tickets/new">New ticket</.button></:action>
    </.empty_state>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="acme-table-page" id="tickets-page">
      <.data_table
        id="tickets"
        rows={@rows}
        meta={@meta}
        path="/app/tickets"
        views={["table"]}
        show_checkboxes={false}
        search_field={:title}
        search_placeholder="Search tickets…"
        page_size_options={[5, 8, 10, 25]}
        row_navigate={&"/app/tickets/#{&1.id}"}
        flush
      >
        <:tab label="All" count={@tab_counts.all} />
        <:tab label="In progress" count={@tab_counts.in_progress} filters={[%{field: "status", value: "in_progress"}]} />
        <:tab label="To do" count={@tab_counts.todo} filters={[%{field: "status", value: "todo"}]} />
        <:tab label="Done" count={@tab_counts.done} filters={[%{field: "status", value: "done"}]} />
        <:filter
          field={:priority}
          label="Priority"
          options={Helpers.priority_options()}
          prompt="Any priority"
        />
        <:filter
          field={:assignee}
          label="Assignee"
          options={Helpers.member_options(@members)}
          prompt="Anyone"
        />
        <:col label="Title" field={:title} sortable :let={t}>
          <span class="acme-ticket-title">
            <span class="acme-mono">{t.identifier}</span>
            <span class="acme-rowtitle">{t.title}</span>
          </span>
        </:col>
        <:col label="Status" field={:status} sortable :let={t}>
          <span class="acme-status-cell">
            <.status_glyph status={t.status} />
            {Helpers.status_label(t.status)}
          </span>
        </:col>
        <:col label="Priority" field={:priority} sortable :let={t}>
          <span class="acme-status-cell">
            <.priority_glyph priority={t.priority} />
            {Helpers.priority_label(t.priority)}
          </span>
        </:col>
        <:col label="Assignee" field={:assignee} sortable :let={t}>
          <span class="acme-status-cell">
            <.avatar size="xs" initials={Helpers.initials_for(@members, t.assignee)} />
            {Helpers.name_for(@members, t.assignee)}
          </span>
        </:col>
        <:col label="Updated" field={:date} sortable :let={t}>{Helpers.fmt_date(t.date)}</:col>
        <:empty>
          <.empty_state icon="document" title="No tickets match">
            Try a different search or clear the filters.
            <:action>
              <.button size="sm" variant="outline" patch="/app/tickets">Clear filters</.button>
            </:action>
            <:action>
              <.button size="sm" variant="solid" patch="/app/tickets/new">New ticket</.button>
            </:action>
          </.empty_state>
        </:empty>
      </.data_table>
    </div>
    """
  end
end
