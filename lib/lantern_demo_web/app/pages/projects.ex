defmodule LanternDemoWeb.App.Pages.Projects do
  @moduledoc "Projects overview: a card per project with a progress ring, plus a validated 'New project' dialog."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store

  def mount_page(socket, _params) do
    sid = socket.assigns.sid
    tickets = Store.list_tickets(sid)

    projects =
      Enum.map(Store.list_projects(sid), fn p ->
        mine = Enum.filter(tickets, &(&1.project_id == p.id))
        Map.merge(p, %{completed: Enum.count(mine, &(&1.status == :done)), scope: length(mine)})
      end)

    Phoenix.Component.assign(socket,
      projects: projects,
      new_open: false,
      project_form: %{"name" => "", "summary" => ""},
      project_errors: %{}
    )
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Projects", path: nil}]

  def actions(_) do
    [
      %{
        label: "New project",
        event: "open_new_project",
        variant: "solid"
      }
    ]
  end

  def handle_event("open_new_project", _params, socket) do
    {:noreply,
     Phoenix.Component.assign(socket,
       new_open: true,
       project_form: %{"name" => "", "summary" => ""},
       project_errors: %{}
     )}
  end

  # A non-controlled dialog is closed by the client (Esc, backdrop, Cancel) and
  # tells the server through on_change; keep the flag in step so the next
  # open_new_project is a real change.
  def handle_event("project_dialog_change", %{"open" => o}, socket) do
    {:noreply, Phoenix.Component.assign(socket, new_open: o in [true, "true"])}
  end

  def handle_event("project_change", %{"project" => p}, socket) do
    {:noreply,
     Phoenix.Component.assign(socket,
       project_form: p,
       project_errors: validate(p, socket.assigns.projects)
     )}
  end

  def handle_event("create_project", %{"project" => p}, socket) do
    case validate(p, socket.assigns.projects) do
      errors when map_size(errors) > 0 ->
        {:noreply, Phoenix.Component.assign(socket, project_form: p, project_errors: errors)}

      _ ->
        case Store.create_project(socket.assigns.sid, %{
               name: String.trim(p["name"]),
               summary: String.trim(p["summary"] || "")
             }) do
          nil ->
            {:noreply,
             LanternDemoWeb.AppLive.toast(
               socket,
               :error,
               "This demo workspace has reached its project limit.",
               title: "Couldn't create the project"
             )}

          project ->
            {:noreply,
             socket
             |> mount_page(%{})
             |> LanternDemoWeb.AppLive.toast(:success, "“#{project.name}” is ready for tickets.",
               title: "Project created"
             )}
        end
    end
  end

  def handle_event(_, _, _), do: :unhandled

  defp validate(p, projects) do
    name = String.trim(p["name"] || "")

    cond do
      name == "" ->
        %{"name" => ["can't be blank"]}

      String.length(name) > 40 ->
        %{"name" => ["is too long (max 40)"]}

      Enum.any?(projects, &(String.downcase(&1.name) == String.downcase(name))) ->
        %{"name" => ["is already taken"]}

      true ->
        %{}
    end
  end

  def render(%{view_state: "loading"} = assigns) do
    ~H"""
    <div aria-busy="true" aria-label="Loading projects" class="acme-skel-list">
      <.skeleton :for={_ <- 1..4} style="height: 2.75rem;" />
    </div>
    """
  end

  def render(assigns) do
    assigns =
      assign(assigns, :meta, %{
        params: %{},
        current_page: 1,
        total_pages: 1,
        page_size: 25,
        total_count: length(assigns.projects)
      })

    ~H"""
    <.data_table
      id="projects"
      rows={@projects}
      meta={@meta}
      path="/app/projects"
      views={["table"]}
      show_checkboxes={false}
      row_navigate={&"/app/projects/#{&1.id}"}
      flush
    >
      <:col label="Project" :let={p}>
        <span class="acme-ticket-title">
          <span class="acme-rowtitle">{p.name}</span>
          <span class="acme-muted">{p.summary}</span>
        </span>
      </:col>
      <:col label="Progress" :let={p}>
        <span class="acme-status-cell">
          <.progress shape="ring" completed={p.completed} scope={p.scope} size="sm" label={"#{p.name} progress"} />
          {p.completed} of {p.scope} done
        </span>
      </:col>
      <:col label="Tickets" :let={p}>{p.scope}</:col>
      <:col label="Status" :let={p}>
        <.badge size="sm" color={if p.status == :active, do: "success", else: "neutral"}>{p.status}</.badge>
      </:col>
      <:empty>
        <.empty_state icon="folder" title="No projects yet">
          Projects group tickets and track progress.
          <:action><.button size="sm" variant="solid" phx-click="open_new_project">New project</.button></:action>
        </.empty_state>
      </:empty>
    </.data_table>

    <.modal id="new-project-dialog" open={@new_open} on_change="project_dialog_change" aria_label="New project">
      <form id="project-form" phx-change="project_change" phx-submit="create_project" class="acme-form">
        <.stack gap="md">
          <div>
            <h2 id="new-project-title" class="acme-dialog-title">New project</h2>
            <p class="acme-muted">Group tickets and track their progress together.</p>
          </div>
          <.input
            id="project-name"
            name="project[name]"
            label="Name"
            placeholder="Mobile app"
            value={@project_form["name"]}
            errors={Map.get(@project_errors, "name", [])}
          />
          <.textarea
            id="project-summary"
            name="project[summary]"
            label="Summary"
            rows={3}
            value={@project_form["summary"]}
            placeholder="What is this project for?"
          />
          <div class="acme-dialog-actions">
            <.button type="button" variant="ghost" phx-click={LanternUI.close_dialog("new-project-dialog")}>Cancel</.button>
            <.button type="submit" variant="solid">Create project</.button>
          </div>
        </.stack>
      </form>
    </.modal>
    """
  end
end
