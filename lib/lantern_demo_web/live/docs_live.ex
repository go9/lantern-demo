defmodule LanternDemoWeb.DocsLive do
  @moduledoc """
  The docs: landing (`/docs`), section landings (`/docs/:section`), and the
  component / guide pages (`/docs/:section/:page`). Structure lives in
  `LanternDemoWeb.Docs.Nav`; page bodies in the per-section modules under
  `LanternDemoWeb.Docs.*`. This module owns only the shared demo state and the
  event handlers the live previews fire.
  """
  use Phoenix.LiveView

  alias LanternDemoWeb.Docs.{Guides, Nav, Page}

  @member_titles Nav.member_titles()

  @member_mods %{
    "icon" => LanternDemoWeb.Docs.Foundations,
    "state-glyph" => LanternDemoWeb.Docs.Foundations,
    "badge" => LanternDemoWeb.Docs.Foundations,
    "progress-meter" => LanternDemoWeb.Docs.Foundations,
    "app-shell" => LanternDemoWeb.Docs.Structure,
    "side-panel" => LanternDemoWeb.Docs.Structure,
    "inspector" => LanternDemoWeb.Docs.Structure,
    "separator" => LanternDemoWeb.Docs.Structure,
    "scroll-area" => LanternDemoWeb.Docs.Structure,
    "button" => LanternDemoWeb.Docs.Forms,
    "input" => LanternDemoWeb.Docs.Forms,
    "textarea" => LanternDemoWeb.Docs.Forms,
    "color-input" => LanternDemoWeb.Docs.Forms,
    "checkbox" => LanternDemoWeb.Docs.Forms,
    "radio" => LanternDemoWeb.Docs.Forms,
    "switch" => LanternDemoWeb.Docs.Forms,
    "select" => LanternDemoWeb.Docs.Forms,
    "autocomplete" => LanternDemoWeb.Docs.Forms,
    "slider" => LanternDemoWeb.Docs.Forms,
    "datetime-field" => LanternDemoWeb.Docs.Forms,
    "calendar" => LanternDemoWeb.Docs.Forms,
    "date-picker" => LanternDemoWeb.Docs.Forms,
    "table" => LanternDemoWeb.Docs.DataDisplay,
    "description-list" => LanternDemoWeb.Docs.DataDisplay,
    "resource-list" => LanternDemoWeb.Docs.DataDisplay,
    "list-row" => LanternDemoWeb.Docs.DataDisplay,
    "stat" => LanternDemoWeb.Docs.DataDisplay,
    "area-chart" => LanternDemoWeb.Docs.DataDisplay,
    "line-chart" => LanternDemoWeb.Docs.DataDisplay,
    "bar-chart" => LanternDemoWeb.Docs.DataDisplay,
    "sparkline" => LanternDemoWeb.Docs.DataDisplay,
    "accordion" => LanternDemoWeb.Docs.DataDisplay,
    "timeline" => LanternDemoWeb.Docs.DataDisplay,
    "alert" => LanternDemoWeb.Docs.Feedback,
    "toast" => LanternDemoWeb.Docs.Feedback,
    "loading" => LanternDemoWeb.Docs.Feedback,
    "skeleton" => LanternDemoWeb.Docs.Feedback,
    "empty-state" => LanternDemoWeb.Docs.Feedback,
    "modal" => LanternDemoWeb.Docs.Overlays,
    "alert-dialog" => LanternDemoWeb.Docs.Overlays,
    "sheet" => LanternDemoWeb.Docs.Overlays,
    "popover" => LanternDemoWeb.Docs.Overlays,
    "tooltip" => LanternDemoWeb.Docs.Overlays,
    "dropdown" => LanternDemoWeb.Docs.Overlays,
    "menu" => LanternDemoWeb.Docs.Overlays,
    "command" => LanternDemoWeb.Docs.Overlays,
    "tabs" => LanternDemoWeb.Docs.Navigation,
    "breadcrumb" => LanternDemoWeb.Docs.Navigation,
    "pagination" => LanternDemoWeb.Docs.Navigation,
    "navlist" => LanternDemoWeb.Docs.Navigation,
    "chat-kit" => LanternDemoWeb.Docs.Patterns
  }

  @catalog [
    %{
      group: "Nintendo 64",
      label: "The Legend of Zelda: Ocarina of Time",
      value: "zelda-ocarina"
    },
    %{group: "Nintendo 64", label: "The Legend of Zelda: Majora's Mask", value: "zelda-majora"},
    %{group: "Nintendo 64", label: "Super Mario 64", value: "super-mario-64"},
    %{
      group: "Nintendo Switch",
      label: "The Legend of Zelda: Breath of the Wild",
      value: "zelda-botw"
    },
    %{group: "Nintendo Switch", label: "Metroid Dread", value: "metroid-dread"},
    %{group: "Nintendo Switch", label: "Animal Crossing: New Horizons", value: "animal-crossing"}
  ]

  # Command palette source data. The component deliberately filters nothing —
  # it renders exactly the items it is handed — so this list stays here and the
  # LiveView answers `command_search` itself.
  @commands [
    %{
      group: "Navigate",
      value: "goto-buttons",
      label: "Go to Button",
      icon: "cursor-arrow-rays",
      description: "Components → Button",
      shortcut: "G B"
    },
    %{
      group: "Navigate",
      value: "goto-data-table",
      label: "Go to Data table",
      icon: "view-columns",
      description: "Components → Data table",
      shortcut: "G T"
    },
    %{
      group: "Navigate",
      value: "goto-theming",
      label: "Go to Theming",
      icon: "sparkles",
      description: "Tokens, density, and dark mode",
      shortcut: "G H"
    },
    %{
      group: "Actions",
      value: "toggle-theme",
      label: "Toggle dark mode",
      icon: "adjustments-horizontal",
      description: "Flip the demo between light and dark",
      shortcut: "⌘ D"
    },
    %{
      group: "Actions",
      value: "copy-install",
      label: "Copy install snippet",
      icon: "document",
      description:
        ~s({:lantern_ui, github: "go9/lantern-ui", ref: "0ad0627054ee6765c81eceace58ad316959565bb"}),
      shortcut: "⌘ C"
    },
    %{
      group: "Actions",
      value: "new-ticket",
      label: "Open a new ticket",
      icon: "inbox",
      description: "File an issue against lantern-ui",
      shortcut: "⌘ N"
    },
    %{
      group: "Danger zone",
      value: "reset-sandbox",
      label: "Reset the sandbox database",
      icon: "trash",
      description: "Disabled in this demo",
      shortcut: nil,
      disabled: true
    }
  ]

  # Snippets retained for pages that still use the single-blob format
  # (app-shell, charts). Feature pages embed code per demo_section.
  @snippets %{
    "app-shell" => ~S"""
    <.app_shell id="app">
      <:brand><.icon name="bolt" /> <span class="lui-brand-name">Acme</span></:brand>
      <:header><.breadcrumb>…</.breadcrumb></:header>
      <:actions><.button variant="outline" size="sm">Account</.button></:actions>

      <:sidebar>
        <.nav_group label="Workspace">
          <.nav_item label="Dashboard" icon="chart-bar" navigate={~p"/"} active />
          <.nav_item label="Buckets" icon="cloud" navigate={~p"/buckets"} />
        </.nav_group>
      </:sidebar>

      <%!-- page content --%>
    </.app_shell>
    """,
    "area-chart" => ~S"""
    # series: a list of %{date, value} points
    daily_revenue = [
      %{date: ~D[2026-06-01], value: 40.0},
      %{date: ~D[2026-06-02], value: 47.5},
      %{date: ~D[2026-06-03], value: 52.1}
      # …one per day
    ]

    <.area_chart id="rev" series={daily_revenue} height={220} value_format={:currency} />
    """,
    "line-chart" => ~S"""
    # series: a list of lines; each line's points are {datetime, value} tuples
    web1 = [
      {~U[2026-07-07 00:00:00Z], 0.30},
      {~U[2026-07-07 01:00:00Z], 0.42}
      # …one per hour
    ]

    <.line_chart
      id="cpu"
      series={[
        %{label: "web-1", color: "var(--lantern-accent)", points: web1},
        %{label: "web-2", color: "var(--lantern-fg-subtle)", points: web2}
      ]}
    />
    """,
    "bar-chart" => ~S"""
    <.bar_chart id="q" series={[%{label: "Q1", value: 42}, %{label: "Q2", value: 31}]} />
    """,
    "sparkline" => ~S"""
    <.sparkline id="s" series={[3, 5, 4, 8, 6, 9]} height={48} />
    """
  }

  @chat_demo_messages [
    %{
      id: "chat-1",
      role: :assistant,
      initials: "F",
      header: "Assistant - 09:41",
      body:
        "Welcome. This transcript shows how a message row, avatar, metadata, and footer compose together.",
      footer: "Ready",
      align: "start",
      tone: "surface"
    },
    %{
      id: "chat-2",
      role: :user,
      initials: "AL",
      header: "Alex - 09:42",
      body: "Can you outline the three states this conversation can show?",
      footer: "Seen",
      align: "end",
      tone: "primary"
    },
    %{
      id: "chat-3",
      role: :assistant,
      initials: "LU",
      header: "Assistant - 09:42",
      body:
        "The sample uses a current transcript, a busy streaming row, and a follow control for the latest item.",
      footer: "Delivered",
      align: "start",
      tone: "surface"
    },
    %{
      id: "chat-4",
      role: :user,
      initials: "AL",
      header: "Alex - 09:43",
      body: "What makes the longer response readable in a compact viewport?",
      footer: "Seen",
      align: "end",
      tone: "primary"
    },
    %{
      id: "chat-5",
      role: :assistant,
      initials: "F",
      header: "Assistant - 09:43",
      body:
        "Readable chat content benefits from a deliberate measure and visible paragraph breaks.\n\nKeep supporting context in short paragraphs, use plain text when the component does not promise Markdown rendering, and let the surrounding message bubble provide the visual grouping.\n\nThe fixed-height viewport below is intentionally small enough to make the follow behavior observable while keeping each turn easy to scan.",
      footer: "Delivered",
      align: "start",
      tone: "surface"
    },
    %{
      id: "chat-6",
      role: :user,
      initials: "AL",
      header: "Alex - 09:44",
      body: "Add one more reply so I can see the latest item move into view.",
      footer: "Seen",
      align: "end",
      tone: "primary"
    },
    %{
      id: "chat-7",
      role: :assistant,
      initials: "LU",
      header: "Assistant - 09:44",
      body:
        "The last item is marked as the scroll anchor. Use the controls above to append, hold, or reset this transcript.",
      footer: "Delivered",
      align: "start",
      tone: "surface"
    }
  ]

  def mount(_params, _session, socket) do
    today = Date.utc_today()

    area =
      for i <- 0..29 do
        %{date: Date.add(today, i - 29), value: 40 + :math.sin(i / 4) * 12 + i * 0.8}
      end

    line = [
      %{
        label: "web-1",
        color: "var(--lantern-accent)",
        points:
          for(
            i <- 0..23,
            do: {DateTime.add(~U[2026-07-07 00:00:00Z], i * 3600), 0.3 + :math.sin(i / 3) * 0.2}
          )
      },
      %{
        label: "web-2",
        color: "var(--lantern-fg-subtle)",
        points:
          for(
            i <- 0..23,
            do: {DateTime.add(~U[2026-07-07 00:00:00Z], i * 3600), 0.5 + :math.cos(i / 4) * 0.15}
          )
      }
    ]

    {:ok,
     assign(socket,
       snippets: @snippets,
       demo_tab: "one",
       toast_placement: "top-right",
       catalog_options: [],
       command_query: "",
       command_groups: command_matches(""),
       command_selection: nil,
       alert_dialog_status: nil,
       area: area,
       line: line,
       bars: [
         %{label: "Q1", value: 42},
         %{label: "Q2", value: 31},
         %{label: "Q3", value: 55},
         %{label: "Q4", value: 47}
       ],
       spark: [3, 5, 4, 8, 6, 9, 7, 11, 9, 12],
       chat_demo_messages: @chat_demo_messages,
       chat_demo_busy: false,
       chat_demo_next_reply: 8,
       dense_scope: "all",
       panel_open: true,
       controlled_status: "active",
       range_form:
         Phoenix.Component.to_form(%{"from" => "2026-08-01", "to" => "2026-08-07"}, as: :range)
     )}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, resolve(socket, params)}
  end

  def handle_event("set_toast_placement", %{"placement" => placement}, socket) do
    {:noreply, assign(socket, :toast_placement, placement)}
  end

  def handle_event("demo_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :demo_tab, tab)}
  end

  def handle_event("demo_toast", %{"kind" => kind}, socket) do
    {:noreply,
     LanternUI.send_toast(socket, kind, "This is a #{kind} toast", title: String.capitalize(kind))}
  end

  # Server-driven select: the Zag machine reports picks here, and the server
  # value below is truth — patches flow back into the machine.
  def handle_event("controlled_status_changed", %{"value" => values}, socket) do
    {:noreply, assign(socket, :controlled_status, List.first(List.wrap(values)))}
  end

  def handle_event("set_controlled_status", %{"value" => value}, socket) do
    {:noreply, assign(socket, :controlled_status, value)}
  end

  def handle_event("demo_toast_burst", _params, socket) do
    socket =
      Enum.reduce(~w(info success warning danger info success), socket, fn kind, acc ->
        LanternUI.send_toast(acc, kind, "Toast #{kind}", title: String.capitalize(kind))
      end)

    {:noreply, socket}
  end

  def handle_event("demo_toast_action", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :success, "Workspace settings were updated.",
       title: "Changes saved",
       action: %{label: "Undo", event: "demo_toast_undo"}
     )}
  end

  def handle_event("demo_toast_undo", _params, socket) do
    {:noreply, LanternUI.send_toast(socket, :info, "Undone.", title: "Reverted")}
  end

  def handle_event("demo_toast_sticky", _params, socket) do
    {:noreply, LanternUI.send_toast(socket, :warning, "Stays until dismissed.", duration: 0)}
  end

  def handle_event("demo_toast_flash", _params, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :info, "Flash message via put_flash")}
  end

  def handle_event("demo_toast_flash_error", _params, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :error, "Something went wrong (put_flash)")}
  end

  # Regression check: a re-render right after send_toast must not eat the toast.
  def handle_event("demo_toast_patch", _params, socket) do
    {:noreply,
     socket
     |> LanternUI.send_toast(:info, "I should survive the re-render.", title: "Patch test")
     |> assign(:toast_placement, socket.assigns.toast_placement)
     |> assign(:demo_tab, "patch-#{System.unique_integer([:positive])}")}
  end

  def handle_event("search_catalog", %{"query" => query}, socket) do
    {:noreply, assign(socket, :catalog_options, catalog_options(query))}
  end

  # The palette does no filtering of its own — it renders what it is handed and
  # reports the query upward. Answering this event is what makes typing filter.
  def handle_event("command_search", %{"query" => query}, socket) do
    {:noreply, assign(socket, command_query: query, command_groups: command_matches(query))}
  end

  def handle_event("command_select", %{"value" => value}, socket) do
    label =
      Enum.find_value(@commands, value, fn cmd -> cmd.value == value && cmd.label end)

    {:noreply, assign(socket, :command_selection, {value, label})}
  end

  def handle_event("confirm_demo_revoke", _params, socket) do
    socket =
      socket
      |> assign(:alert_dialog_status, "Demo key revoked — no real credential was changed.")
      |> LanternUI.close_dialog("alert-dialog-demo")

    {:noreply, socket}
  end

  def handle_event("chat_append_reply", _params, socket) do
    next_reply = socket.assigns.chat_demo_next_reply

    reply = %{
      id: "chat-reply-#{next_reply}",
      role: :assistant,
      initials: "F",
      header: "Assistant - now",
      body: "Here is the stable appended reply. The new final item becomes the scroll anchor.",
      footer: "Delivered",
      align: "start",
      tone: "surface"
    }

    {:noreply,
     assign(socket,
       chat_demo_messages: socket.assigns.chat_demo_messages ++ [reply],
       chat_demo_next_reply: next_reply + 1
     )}
  end

  def handle_event("chat_toggle_streaming", _params, socket) do
    {:noreply, update(socket, :chat_demo_busy, &(!&1))}
  end

  def handle_event("chat_reset", _params, socket) do
    {:noreply, assign(socket, chat_demo_messages: @chat_demo_messages, chat_demo_busy: false)}
  end

  def handle_event("set_dense_scope", params, socket) do
    scope = params["tab"] || params["segment"]
    {:noreply, assign(socket, :dense_scope, scope)}
  end

  def handle_event("toggle_panel", _params, socket) do
    {:noreply, update(socket, :panel_open, &(!&1))}
  end

  def handle_event("set_panel", %{"open" => open}, socket) do
    {:noreply, assign(socket, :panel_open, open == true or open == "true")}
  end

  defp resolve(socket, %{"section" => sid, "page" => pid}) do
    case Nav.page(sid, pid) do
      {s, p} ->
        assign(socket,
          view: :page,
          section: s,
          page: p,
          page_id: p.id,
          current: "#{s.id}/#{p.id}",
          page_title: "#{p.title} — lantern-ui"
        )

      nil ->
        missing(socket)
    end
  end

  defp resolve(socket, %{"section" => sid}) do
    case Nav.section(sid) do
      nil ->
        missing(socket)

      s ->
        assign(socket,
          view: :section,
          section: s,
          current: "#{s.id}",
          page_title: "#{s.title} — lantern-ui"
        )
    end
  end

  defp resolve(socket, _params) do
    assign(socket, view: :index, current: "docs", page_title: "Documentation — lantern-ui")
  end

  defp missing(socket) do
    assign(socket, view: :missing, current: "docs", page_title: "Not found — lantern-ui")
  end

  def render(assigns) do
    assigns = assign(assigns, :titles, @member_titles)

    ~H"""
    <LanternDemoWeb.DocsShell.shell current={@current}>
      <Page.index_landing :if={@view == :index} />
      <div :if={@view == :missing} class="docs-page">
        <h1 class="docs-page-title">Page not found</h1>
        <p class="docs-page-desc">That docs page doesn't exist. <.link navigate="/docs">Back to the docs index.</.link></p>
      </div>
      <Page.section_landing :if={@view == :section} section={@section} />
      <%= if @view == :page do %>
        <%= if @page.kind == :static do %>
          {Guides.page(assigns)}
        <% else %>
          <Page.members
            section={@section}
            page={@page}
            titles={@titles}
            render_member={fn m -> render_member(assigns, m) end}
          />
        <% end %>
      <% end %>
    </LanternDemoWeb.DocsShell.shell>
    """
  end

  defp render_member(assigns, member) do
    mod = Map.fetch!(@member_mods, member)
    mod.member(Map.put(assigns, :member, member))
  end

  defp catalog_options(query) do
    normalized = query |> String.trim() |> String.downcase()

    if String.length(normalized) < 2 do
      []
    else
      @catalog
      |> Enum.filter(fn item ->
        String.contains?(String.downcase(item.label), normalized) or
          String.contains?(item.value, normalized)
      end)
      |> Enum.group_by(& &1.group)
      |> Enum.sort_by(fn {group, _items} -> group end)
      |> Enum.map(fn {group, items} ->
        {group, Enum.map(items, &{&1.label, &1.value})}
      end)
    end
  end

  defp command_matches(query) do
    normalized = query |> String.trim() |> String.downcase()

    @commands
    |> Enum.filter(fn cmd ->
      normalized == "" or
        String.contains?(String.downcase(cmd.label), normalized) or
        String.contains?(String.downcase(cmd.description || ""), normalized) or
        String.contains?(String.downcase(cmd.group), normalized)
    end)
    |> Enum.chunk_by(& &1.group)
    |> Enum.map(fn [%{group: group} | _] = items -> {group, items} end)
  end
end
