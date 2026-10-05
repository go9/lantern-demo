defmodule LanternDemoWeb.App.Shell do
  @moduledoc """
  The Acme chrome for /app: brand, search, notifications, user menu, the
  sidebar, the breadcrumb bar (title trail + page actions), the toast deck and
  the Cmd+K palette. It never links into the docs.
  """
  use Phoenix.Component
  use LanternUI

  alias LanternUI.Components.Theme

  attr(:page, :atom, required: true)

  attr(:crumbs, :list,
    required: true,
    doc: "[%{label:, path:}] — the last entry is the page title"
  )

  attr(:actions, :list, default: [])
  attr(:appearance, :map, required: true)
  attr(:counts, :map, required: true)
  attr(:unread, :integer, default: 0)
  attr(:user, :map, required: true)
  attr(:flash, :map, default: %{})
  attr(:palette_groups, :list, default: [])
  attr(:palette_query, :string, default: "")
  slot(:inner_block, required: true)

  def shell(assigns) do
    assigns = assign(assigns, :title, assigns.crumbs |> List.last() |> Map.fetch!(:label))

    ~H"""
    <.app_shell
      id="acme-shell"
      class={theme_class(@appearance)}
      data-lantern-density={@appearance.density}
      data-page={@page}
    >
      <:brand>
        <.icon name="sparkles" /> <span class="lui-brand-name">Acme</span>
      </:brand>
      <:header>
        <.badge size="sm" variant="soft">Demo workspace</.badge>
      </:header>
      <:actions>
        <.button
          variant="outline"
          size="sm"
          type="button"
          class="acme-search-btn"
          aria-label="Search"
          phx-click={LanternUI.open_dialog("acme-palette")}
        >
          <.icon name="magnifying-glass" /> <span class="acme-search-label">Search</span>
          <kbd class="acme-kbd">⌘K</kbd>
        </.button>
        <.button size="icon" variant="ghost" label="Notifications" patch="/app/notifications" class="acme-bell">
          <.icon name="inbox" />
          <span :if={@unread > 0} class="acme-bell-dot" aria-label={"#{@unread} unread"}>{@unread}</span>
        </.button>
        <.dropdown id="acme-user-menu" placement="bottom-end">
          <:toggle>
            <.avatar size="sm" initials={@user.initials} aria-label="Account menu" />
          </:toggle>
          <.dropdown_header>{@user.name}</.dropdown_header>
          <.dropdown_link patch="/app/settings">Settings</.dropdown_link>
          <.dropdown_button phx-click="toggle_theme">
            {if @appearance.theme == "dark", do: "Switch to light mode", else: "Switch to dark mode"}
          </.dropdown_button>
          <.dropdown_separator />
          <.dropdown_button phx-click="sign_out">Sign out</.dropdown_button>
        </.dropdown>
      </:actions>
      <:breadcrumb>
        <.breadcrumb home="/app" items={@crumbs} aria_label="Location" />
      </:breadcrumb>
      <:breadcrumb_actions
        :for={a <- @actions}
        label={a.label}
        patch={a[:navigate]}
        phx-click={a[:event]}
        disabled={a[:disabled]}
      >
        <.action action={a} />
      </:breadcrumb_actions>
      <:sidebar>
        <.nav_group label="Workspace">
          <.nav_item label="Dashboard" icon="chart-bar" patch="/app" active={@page == :dashboard} />
          <.nav_item
            label="Tickets"
            icon="document"
            patch="/app/tickets"
            badge={@counts.todo + @counts.in_progress}
            active={@page in [:tickets, :ticket, :ticket_new, :ticket_edit]}
          />
          <.nav_item
            label="Notifications"
            icon="inbox"
            patch="/app/notifications"
            badge={if @unread > 0, do: @unread}
            active={@page == :notifications}
          />
        </.nav_group>
        <.nav_group label="Manage">
          <.nav_item
            label="Projects"
            icon="folder"
            patch="/app/projects"
            active={@page in [:projects, :project]}
          />
          <.nav_item label="Team" icon="globe-alt" patch="/app/team" active={@page == :team} />
          <.nav_item
            label="Settings"
            icon="adjustments-horizontal"
            patch="/app/settings"
            active={@page == :settings}
          />
        </.nav_group>
      </:sidebar>
      <:sidebar_footer>
        <.nav_link label="Sign out" icon="arrow-right" href="#" phx-click="sign_out" />
      </:sidebar_footer>

      <Theme.theme preset={@appearance.preset} id="acme-theme" />
      <.toast_group id="acme-toasts" placement="bottom-right" flash={@flash} />
      <h1 class="lui-sr-only">{@title}</h1>
      {render_slot(@inner_block)}

      <.command
        id="acme-palette"
        label="Search Acme"
        placeholder="Search tickets, pages and actions…"
        on_search="palette_search"
        on_select="palette_select"
        debounce={120}
      >
        <%= for {{group, items}, index} <- Enum.with_index(@palette_groups) do %>
          <.command_separator :if={index > 0} />
          <.command_group label={group}>
            <.command_item :for={item <- items} value={item.value}>
              <:icon><.icon name={item.icon} /></:icon>
              {item.label}
              <:description :if={item[:description]}>{item.description}</:description>
            </.command_item>
          </.command_group>
        <% end %>
        <.command_empty :if={@palette_groups == []}>Nothing matches “{@palette_query}”.</.command_empty>
        <:footer>↑↓ to move · Enter to open · Esc to close</:footer>
      </.command>
    </.app_shell>
    """
  end

  attr(:action, :map, required: true)

  defp action(%{action: %{kind: :panel_toggle}} = assigns) do
    ~H"""
    <.side_panel_toggle
      id="ticket-panel-toggle"
      panel_id="ticket-panel"
      panel_key="acme-ticket"
      open={@action.open}
      kbd="]"
    />
    """
  end

  defp action(%{action: a} = assigns) do
    assigns = assign(assigns, :a, a)

    ~H"""
    <.button
      size="sm"
      variant={@a[:variant] || "outline"}
      color={@a[:color] || "primary"}
      patch={@a[:navigate]}
      phx-click={@a[:event]}
      disabled={@a[:disabled]}
    >
      {@a.label}
    </.button>
    """
  end

  def theme_class(%{theme: "dark"}), do: "dark"
  def theme_class(%{theme: "light"}), do: "light"
  def theme_class(_), do: nil
end
