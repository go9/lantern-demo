defmodule LanternDemoWeb.App.Pages.NotFound do
  @moduledoc "Unknown /app path, inside the shell."
  use Phoenix.Component
  use LanternUI

  def mount_page(socket, _params), do: socket
  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Page not found", path: nil}]
  def actions(_), do: []
  def handle_event(_, _, _), do: :unhandled

  def render(assigns) do
    ~H"""
    <.empty_state icon="exclamation-circle" title="That page doesn't exist">
      The link may be old, or the record was deleted.
      <:action><.button size="sm" variant="solid" patch="/app">Back to the dashboard</.button></:action>
    </.empty_state>
    """
  end
end
