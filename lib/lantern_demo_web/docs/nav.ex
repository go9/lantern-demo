defmodule LanternDemoWeb.Docs.Nav do
  @moduledoc """
  The docs information architecture: sections → pages. One page per concept;
  a page may merge several component "members" (each a function clause in a
  `LanternDemoWeb.Docs.*` module). `kind` says how the page renders:

    * `:members` — rendered by `DocsLive` from its members
    * `:static`  — a hand-written page in `LanternDemoWeb.Docs.Guides`
    * `:live`    — its own LiveView (route-level); only listed here for the nav
  """

  @sections [
    %{
      id: "getting-started",
      title: "Getting started",
      icon: "sparkles",
      desc: "Install lantern-ui, theme it, and see what changed recently.",
      pages: [
        %{
          id: "whats-new",
          title: "What's new",
          desc: "Everything shipped in this release, with live links.",
          kind: :live,
          path: "/whats-new"
        },
        %{
          id: "installation",
          title: "Installation",
          desc: "Add lantern_ui to a Phoenix app in three steps.",
          kind: :static
        },
        %{
          id: "theming",
          title: "Theming",
          desc: "Tokens, the shadcn preset, density and dark mode.",
          kind: :live
        },
        %{
          id: "ai",
          title: "AI legibility",
          desc: "llms.txt, agent rules, skills and a linter so coding agents build with lantern correctly.",
          kind: :static
        }
      ]
    },
    %{
      id: "foundations",
      title: "Foundations",
      icon: "adjustments-horizontal",
      desc: "Tokens and primitives every other component is built from.",
      pages: [
        %{
          id: "colors",
          title: "Colors & tokens",
          desc: "The semantic color tokens, in light and dark.",
          kind: :static
        },
        %{
          id: "typography",
          title: "Typography",
          desc: "Type scale, families and text roles.",
          kind: :static
        },
        %{
          id: "spacing",
          title: "Spacing & stack",
          desc: "Space tokens, radii, density, and the stack primitive.",
          kind: :static
        },
        %{
          id: "icons",
          title: "Icons",
          desc: "The built-in icon set and how to size and color it.",
          kind: :members,
          members: ~w(icon)
        },
        %{
          id: "status",
          title: "Status & indicators",
          desc: "State glyphs, badges, progress, progress ring and meter.",
          kind: :members,
          members: ~w(state-glyph badge progress-meter)
        }
      ]
    },
    %{
      id: "layout",
      title: "Layout",
      icon: "view-columns",
      desc: "The chrome around a page: shell, panels and dividers.",
      pages: [
        %{
          id: "app-shell",
          title: "App shell",
          desc: "Brand, breadcrumb bar, collapsible sidebar and main column.",
          kind: :members,
          members: ~w(app-shell)
        },
        %{
          id: "panels",
          title: "Side panel & inspector",
          desc: "Collapsible right-hand panels and key/value inspectors.",
          kind: :members,
          members: ~w(side-panel inspector)
        },
        %{
          id: "dividers",
          title: "Separator & scroll area",
          desc: "Dividers and bounded scrolling regions.",
          kind: :members,
          members: ~w(separator scroll-area)
        }
      ]
    },
    %{
      id: "forms",
      title: "Forms & inputs",
      icon: "pencil-square",
      desc: "Buttons and every way to collect a value.",
      pages: [
        %{
          id: "buttons",
          title: "Buttons & actions",
          desc: "Variants, colors, sizes and icon buttons.",
          kind: :members,
          members: ~w(button)
        },
        %{
          id: "text-inputs",
          title: "Text inputs",
          desc: "Input, textarea and color input.",
          kind: :members,
          members: ~w(input textarea color-input)
        },
        %{
          id: "choice",
          title: "Checkbox, radio & switch",
          desc: "Pick one, pick many, or flip a setting.",
          kind: :members,
          members: ~w(checkbox radio switch)
        },
        %{
          id: "select",
          title: "Select & autocomplete",
          desc: "Client and server-driven option pickers.",
          kind: :members,
          members: ~w(select autocomplete)
        },
        %{
          id: "slider",
          title: "Slider",
          desc: "Pick a number or a range by dragging.",
          kind: :members,
          members: ~w(slider)
        },
        %{
          id: "date-time",
          title: "Date & time",
          desc: "Datetime field, calendar and date/time pickers.",
          kind: :members,
          members: ~w(datetime-field calendar date-picker)
        }
      ]
    },
    %{
      id: "data-display",
      title: "Data display",
      icon: "circle-stack",
      desc: "Tables, lists, stats and charts.",
      pages: [
        %{
          id: "tables-lists",
          title: "Tables & lists",
          desc: "Table, description list, resource list and flat list rows.",
          kind: :members,
          members: ~w(table description-list resource-list list-row)
        },
        %{
          id: "data-table",
          title: "Data table",
          desc: "Sorting, filtering and pagination over live rows.",
          kind: :live
        },
        %{
          id: "stat-cards",
          title: "Stat cards",
          desc: "Compact summary metrics.",
          kind: :members,
          members: ~w(stat)
        },
        %{
          id: "charts",
          title: "Charts",
          desc: "Area, line and bar charts plus sparklines.",
          kind: :members,
          members: ~w(area-chart line-chart bar-chart sparkline)
        },
        %{
          id: "accordion-timeline",
          title: "Accordion & timeline",
          desc: "Disclose detail and show ordered history.",
          kind: :members,
          members: ~w(accordion timeline)
        }
      ]
    },
    %{
      id: "feedback",
      title: "Feedback",
      icon: "exclamation-circle",
      desc: "Tell people what happened, what is loading, and what is empty.",
      pages: [
        %{
          id: "alerts",
          title: "Alerts",
          desc: "Inline messages for info, success, warning and errors.",
          kind: :members,
          members: ~w(alert)
        },
        %{
          id: "toasts",
          title: "Toasts",
          desc: "Stacked notifications, bursts, actions and flash.",
          kind: :members,
          members: ~w(toast)
        },
        %{
          id: "loading",
          title: "Loading & skeleton",
          desc: "Spinners and placeholder shapes.",
          kind: :members,
          members: ~w(loading skeleton)
        },
        %{
          id: "empty-states",
          title: "Empty states",
          desc: "What to show when there is nothing yet.",
          kind: :members,
          members: ~w(empty-state)
        }
      ]
    },
    %{
      id: "overlays",
      title: "Overlays",
      icon: "window",
      desc: "Layers above the page: dialogs, sheets, popovers, menus.",
      pages: [
        %{
          id: "dialogs",
          title: "Modal & alert dialog",
          desc: "Focus-trapped dialogs for forms and confirmations.",
          kind: :members,
          members: ~w(modal alert-dialog)
        },
        %{
          id: "sheet",
          title: "Sheet",
          desc: "Edge-anchored panels in four directions.",
          kind: :members,
          members: ~w(sheet)
        },
        %{
          id: "popover-tooltip",
          title: "Popover & tooltip",
          desc: "Anchored floating content and hints.",
          kind: :members,
          members: ~w(popover tooltip)
        },
        %{
          id: "menus",
          title: "Dropdown & menus",
          desc: "Action menus, dropdowns and menubars.",
          kind: :members,
          members: ~w(dropdown menu)
        },
        %{
          id: "command",
          title: "Command palette",
          desc: "Search-driven actions behind Cmd+K.",
          kind: :members,
          members: ~w(command)
        }
      ]
    },
    %{
      id: "navigation",
      title: "Navigation",
      icon: "map-pin",
      desc: "Move between views and places.",
      pages: [
        %{
          id: "tabs",
          title: "Tabs",
          desc: "Switch between sibling views.",
          kind: :members,
          members: ~w(tabs)
        },
        %{
          id: "breadcrumb-pagination",
          title: "Breadcrumb & pagination",
          desc: "Where you are, and paging through more.",
          kind: :members,
          members: ~w(breadcrumb pagination)
        },
        %{
          id: "nav-list",
          title: "Nav list",
          desc: "Grouped vertical navigation.",
          kind: :members,
          members: ~w(navlist)
        }
      ]
    },
    %{
      id: "blocks",
      title: "Blocks",
      icon: "squares-2x2",
      desc: "Eight copy-paste page blocks, each live and interactive.",
      pages: [
        %{
          id: "app-shell",
          title: "App shell",
          desc: "Sidebar + breadcrumb bar + content.",
          kind: :live,
          path: "/blocks/app-shell"
        },
        %{
          id: "dashboard",
          title: "Dashboard",
          desc: "Stat cards, activity, charts.",
          kind: :live,
          path: "/blocks/dashboard"
        },
        %{
          id: "list",
          title: "List",
          desc: "Filter chips, search and a flat list.",
          kind: :live,
          path: "/blocks/list"
        },
        %{
          id: "detail",
          title: "Detail + inspector",
          desc: "A record with a side inspector.",
          kind: :live,
          path: "/blocks/detail"
        },
        %{
          id: "settings",
          title: "Settings",
          desc: "Grouped settings forms.",
          kind: :live,
          path: "/blocks/settings"
        },
        %{
          id: "form",
          title: "Form",
          desc: "Validated create/edit form.",
          kind: :live,
          path: "/blocks/form"
        },
        %{
          id: "login",
          title: "Login",
          desc: "Centered sign-in card.",
          kind: :live,
          path: "/blocks/login"
        },
        %{
          id: "destructive",
          title: "Destructive flow",
          desc: "Confirm before you delete.",
          kind: :live,
          path: "/blocks/destructive"
        }
      ]
    },
    %{
      id: "patterns",
      title: "Patterns",
      icon: "inbox",
      desc: "Larger compositions built from several components.",
      pages: [
        %{
          id: "chat-kit",
          title: "Chat kit",
          desc: "Messages, avatars and a streaming scroller.",
          kind: :members,
          members: ~w(chat-kit)
        }
      ]
    },
    %{
      id: "tools",
      title: "Tools",
      icon: "folder",
      desc: "The standalone lantern tools, running on sandboxed data.",
      pages: [
        %{id: "db", title: "DB viewer", desc: "A Postgres table editor.", kind: :live, path: "/"},
        %{
          id: "s3",
          title: "S3 viewer",
          desc: "An S3 file manager.",
          kind: :live,
          path: "/storage"
        },
        %{
          id: "livecode",
          title: "LiveCode",
          desc: "An in-browser code editor.",
          kind: :live,
          path: "/livecode"
        }
      ]
    }
  ]

  @member_titles %{
    "icon" => "Icon",
    "state-glyph" => "State glyph",
    "badge" => "Badge",
    "progress-meter" => "Progress and meter",
    "app-shell" => "App shell",
    "side-panel" => "Side panel",
    "inspector" => "Inspector",
    "separator" => "Separator",
    "scroll-area" => "Scroll area",
    "button" => "Button",
    "input" => "Input",
    "textarea" => "Textarea",
    "color-input" => "Color input",
    "checkbox" => "Checkbox",
    "radio" => "Radio",
    "switch" => "Switch",
    "select" => "Select",
    "autocomplete" => "Autocomplete",
    "slider" => "Slider",
    "datetime-field" => "Datetime field",
    "calendar" => "Calendar",
    "date-picker" => "Date & time pickers",
    "table" => "Table",
    "description-list" => "Description list",
    "resource-list" => "Resource list",
    "list-row" => "List row",
    "stat" => "Stat cards",
    "area-chart" => "Area chart",
    "line-chart" => "Line chart",
    "bar-chart" => "Bar chart",
    "sparkline" => "Sparkline",
    "accordion" => "Accordion",
    "timeline" => "Timeline",
    "alert" => "Alert",
    "toast" => "Toast",
    "loading" => "Loading",
    "skeleton" => "Skeleton",
    "empty-state" => "Empty state",
    "modal" => "Modal",
    "alert-dialog" => "Alert dialog",
    "sheet" => "Sheet",
    "popover" => "Popover",
    "tooltip" => "Tooltip",
    "dropdown" => "Dropdown menu",
    "menu" => "Menu and menubar",
    "command" => "Command palette",
    "tabs" => "Tabs",
    "breadcrumb" => "Breadcrumb",
    "pagination" => "Pagination",
    "navlist" => "Nav list",
    "chat-kit" => "Chat kit"
  }

  def member_title(m), do: Map.fetch!(@member_titles, m)
  def member_titles, do: @member_titles

  def sections, do: @sections

  def section(id), do: Enum.find(@sections, &(&1.id == id))

  def page(section_id, page_id) do
    with %{pages: pages} = s <- section(section_id),
         %{} = p <- Enum.find(pages, &(&1.id == page_id)) do
      {s, p}
    else
      _ -> nil
    end
  end

  @doc "Canonical path of a page."
  def path(%{path: path}, _section), do: path
  def path(%{id: id}, %{id: sid}), do: "/docs/#{sid}/#{id}"
  def path(%{id: sid}), do: "/docs/#{sid}"

  @doc "Every page as `{section, page}` — the flat list the search index is built from."
  def all_pages do
    for s <- @sections, p <- s.pages, do: {s, p}
  end

  @doc "Old `/components/:slug` slug → new path, so existing links keep working."
  def legacy_path(slug) do
    all =
      for s <- @sections,
          s.id not in ["blocks", "tools"],
          p <- s.pages,
          m <- Map.get(p, :members, [p.id]),
          do: {m, path(p, s)}

    all |> Map.new() |> Map.get(slug)
  end
end
