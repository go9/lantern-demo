defmodule LanternDemoWeb.App.Pages do
  @moduledoc "Cross-page helpers: re-run the current page's data loading after an out-of-page change."

  def refresh(socket) do
    mod = socket.assigns.mod
    params = Map.merge(socket.assigns.params, %{"args" => socket.assigns.args})
    mod.mount_page(socket, params)
  end
end
