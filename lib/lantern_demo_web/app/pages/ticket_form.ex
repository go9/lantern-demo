defmodule LanternDemoWeb.App.Pages.TicketForm do
  @moduledoc "New / edit ticket (form recipe) with inline validation, Zag selects and a success toast."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Helpers

  def mount_page(socket, %{"args" => args} = params) do
    sid = socket.assigns.sid
    editing = socket.assigns.page == :ticket_edit
    ticket = if editing, do: Store.get_ticket(sid, hd(args))

    form =
      cond do
        ticket ->
          %{
            "title" => ticket.title,
            "body" => ticket.body,
            "status" => Atom.to_string(ticket.status),
            "priority" => Atom.to_string(ticket.priority),
            "assignee" => ticket.assignee,
            "project_id" => to_string(ticket.project_id),
            "tag" => ticket.tag
          }

        true ->
          %{
            "title" => "",
            "body" => "",
            "status" => "todo",
            "priority" => "medium",
            "assignee" => socket.assigns.settings.email,
            "project_id" => params["project"] || "1",
            "tag" => "ui"
          }
      end

    Phoenix.Component.assign(socket,
      editing: editing,
      ticket: ticket,
      projects: Store.list_projects(sid),
      form: form,
      errors: %{}
    )
  end

  def crumbs(%{editing: true, ticket: nil}),
    do: [
      %{label: "Acme", path: "/app"},
      %{label: "Tickets", path: "/app/tickets"},
      %{label: "Not found", path: nil}
    ]

  def crumbs(%{editing: true, ticket: t}) do
    [
      %{label: "Acme", path: "/app"},
      %{label: "Tickets", path: "/app/tickets"},
      %{label: t.identifier, path: "/app/tickets/#{t.id}"},
      %{label: "Edit", path: nil}
    ]
  end

  def crumbs(_) do
    [
      %{label: "Acme", path: "/app"},
      %{label: "Tickets", path: "/app/tickets"},
      %{label: "New ticket", path: nil}
    ]
  end

  def actions(_), do: []

  def handle_event("validate", %{"ticket" => params}, socket) do
    form = Map.merge(socket.assigns.form, params)
    # only re-check fields that already had an error so typing never nags early
    errors = Map.filter(validate(form), fn {k, _} -> Map.has_key?(socket.assigns.errors, k) end)
    {:noreply, Phoenix.Component.assign(socket, form: form, errors: errors)}
  end

  def handle_event("save", %{"ticket" => params}, socket) do
    form = Map.merge(socket.assigns.form, params)

    case validate(form) do
      errors when map_size(errors) > 0 ->
        {:noreply, Phoenix.Component.assign(socket, form: form, errors: errors)}

      _ ->
        save(socket, form)
    end
  end

  def handle_event(_, _, _), do: :unhandled

  defp validate(form) do
    %{}
    |> check("title", String.trim(form["title"]) == "", "can't be blank")
    |> check(
      "title",
      String.trim(form["title"]) != "" and String.length(String.trim(form["title"])) < 3,
      "is too short (min 3)"
    )
    |> check("title", String.length(form["title"]) > 80, "is too long (max 80)")
    |> check("tag", String.trim(form["tag"]) == "", "can't be blank")
  end

  defp check(errors, _field, false, _msg), do: errors
  defp check(errors, field, true, msg), do: Map.update(errors, field, [msg], &(&1 ++ [msg]))

  defp attrs(form) do
    %{
      title: String.trim(form["title"]),
      body: String.trim(form["body"]),
      status: String.to_existing_atom(form["status"]),
      priority: String.to_existing_atom(form["priority"]),
      assignee: form["assignee"],
      project_id: String.to_integer(form["project_id"]),
      tag: String.trim(form["tag"])
    }
  end

  defp save(%{assigns: %{editing: true, ticket: t}} = socket, form) do
    Store.update_ticket(socket.assigns.sid, t.id, Map.put(attrs(form), :note, "Ticket edited"))

    {:noreply,
     socket
     |> LanternDemoWeb.AppLive.toast(:success, "#{t.identifier} was saved.",
       title: "Ticket updated"
     )
     |> Phoenix.LiveView.push_patch(to: "/app/tickets/#{t.id}")}
  end

  defp save(socket, form) do
    t = Store.create_ticket(socket.assigns.sid, attrs(form))

    {:noreply,
     socket
     |> LanternDemoWeb.AppLive.toast(:success, "“#{t.title}” was filed as #{t.identifier}.",
       title: "Ticket created"
     )
     |> Phoenix.LiveView.push_patch(to: "/app/tickets/#{t.id}")}
  end

  # ── render ──

  def render(%{editing: true, ticket: nil} = assigns) do
    ~H"""
    <.empty_state icon="exclamation-circle" title="Ticket not found">
      It may have been deleted.
      <:action><.button size="sm" variant="solid" patch="/app/tickets">Back to tickets</.button></:action>
    </.empty_state>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="acme-narrow">
      <.card
        title={if @editing, do: "Edit #{@ticket.identifier}", else: "New ticket"}
        description="Small, sharp titles get picked up fastest."
      >
        <form id="ticket-form" phx-change="validate" phx-submit="save" class="acme-form" novalidate>
          <.stack gap="md">
            <.alert :if={@errors != %{}} color="danger" title="Fix the highlighted fields">
              {@errors |> map_size()} {if map_size(@errors) == 1, do: "field needs", else: "fields need"} attention before this can be saved.
            </.alert>
            <.input
              id="ticket-title"
              name="ticket[title]"
              label="Title"
              placeholder="Visible progress ring"
              value={@form["title"]}
              errors={Map.get(@errors, "title", [])}
              phx-debounce="300"
            />
            <.textarea
              id="ticket-body"
              name="ticket[body]"
              label="Description"
              rows={5}
              placeholder="What changes, and how will the reviewer see it?"
              value={@form["body"]}
              help_text="Markdown welcome. Screenshots beat paragraphs."
            />
            <div class="acme-form-grid">
              <.select id="ticket-form-status" name="ticket[status]" label="Status" value={@form["status"]} options={Helpers.status_options()} />
              <.select id="ticket-form-priority" name="ticket[priority]" label="Priority" value={@form["priority"]} options={Helpers.priority_options()} />
              <.select id="ticket-form-assignee" name="ticket[assignee]" label="Assignee" value={@form["assignee"]} options={Helpers.member_options(@members)} />
              <.select id="ticket-form-project" name="ticket[project_id]" label="Project" value={@form["project_id"]} options={Helpers.project_options(@projects)} />
            </div>
            <.input
              id="ticket-tag"
              name="ticket[tag]"
              label="Tag"
              value={@form["tag"]}
              errors={Map.get(@errors, "tag", [])}
              help_text="One short word — ui, docs, auth…"
            />
          </.stack>
        </form>
        <:footer>
          <.button size="sm" variant="ghost" patch={if @editing, do: "/app/tickets/#{@ticket.id}", else: "/app/tickets"}>
            Cancel
          </.button>
          <.button size="sm" variant="solid" type="submit" form="ticket-form">
            {if @editing, do: "Save changes", else: "Create ticket"}
          </.button>
        </:footer>
      </.card>
    </div>
    """
  end
end
