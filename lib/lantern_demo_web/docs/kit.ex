defmodule LanternDemoWeb.Docs.Kit do
  @moduledoc """
  Shared building blocks for the docs pages: the example (preview/code tabs)
  wrapper, the read-only code block, and the introspected API table.
  """
  use Phoenix.Component

  alias LanternUI.Charts, warn: false
  alias LanternUI.Charts, warn: false
  alias LanternUI.Components.Accordion, warn: false
  alias LanternUI.Components.Alert, warn: false
  alias LanternUI.Components.AlertDialog, warn: false
  alias LanternUI.Components.Autocomplete, warn: false
  alias LanternUI.Components.Badge, warn: false
  alias LanternUI.Components.Avatar, warn: false
  alias LanternUI.Components.Breadcrumb, warn: false
  alias LanternUI.Components.Button, warn: false
  alias LanternUI.Components.Calendar, warn: false
  alias LanternUI.Components.Checkbox, warn: false
  alias LanternUI.Components.Command, warn: false
  alias LanternUI.Components.DatePicker, warn: false
  alias LanternUI.Components.DatetimeField, warn: false
  alias LanternUI.Components.DescriptionList, warn: false
  alias LanternUI.Components.Dropdown, warn: false
  alias LanternUI.Components.EmptyState, warn: false
  alias LanternUI.Components.Form, warn: false
  alias LanternUI.Components.Icon, warn: false
  alias LanternUI.Components.Inspector, warn: false
  alias LanternUI.Components.Layout, warn: false
  alias LanternUI.Components.ListRow, warn: false
  alias LanternUI.Components.Loading, warn: false
  alias LanternUI.Components.Modal, warn: false
  alias LanternUI.Components.Message, warn: false
  alias LanternUI.Components.MessageScroller, warn: false
  alias LanternUI.Components.Menu, warn: false
  alias LanternUI.Components.Popover, warn: false
  alias LanternUI.Components.Progress, warn: false
  alias LanternUI.Components.Meter, warn: false
  alias LanternUI.Components.ResourceList, warn: false
  alias LanternUI.Components.ColorInput, warn: false
  alias LanternUI.Components.ScrollArea, warn: false
  alias LanternUI.Components.Slider, warn: false
  alias LanternUI.Components.Navlist, warn: false
  alias LanternUI.Components.Pagination, warn: false
  alias LanternUI.Components.Radio, warn: false
  alias LanternUI.Components.Select, warn: false
  alias LanternUI.Components.Separator, warn: false
  alias LanternUI.Components.SidePanel, warn: false
  alias LanternUI.Components.Sheet, warn: false
  alias LanternUI.Components.Skeleton, warn: false
  alias LanternUI.Components.Stat, warn: false
  alias LanternUI.Components.StateGlyph, warn: false
  alias LanternUI.Components.Switch, warn: false
  alias LanternUI.Components.Table, warn: false
  alias LanternUI.Components.Tabs, warn: false
  alias LanternUI.Components.Textarea, warn: false
  alias LanternUI.Components.Timeline, warn: false
  alias LanternUI.Components.Toast, warn: false
  alias LanternUI.Components.Tooltip, warn: false

  @api_map %{
    "app-shell" => [
      {Layout, :app_shell},
      {Layout, :nav_group},
      {Layout, :nav_item},
      {Layout, :breadcrumb_bar},
      {Layout, :page_header}
    ],
    "navlist" => [{Navlist, :navlist}, {Navlist, :navheading}, {Navlist, :navlink}],
    "table" => [{Table, :table}, {Table, :table_head}, {Table, :table_body}, {Table, :table_row}],
    "description-list" => [{DescriptionList, :description_list}],
    "pagination" => [{Pagination, :pagination}],
    "tabs" => [{Tabs, :tabs_list}, {Tabs, :tabs_panel}],
    "select" => [{Select, :select}],
    "badge" => [{Badge, :badge}],
    "button" => [{Button, :button}],
    "icon" => [{Icon, :icon}],
    "input" => [{Form, :input}, {Form, :label}, {Form, :error}],
    "popover" => [{Popover, :popover}],
    "menu" => [
      {Menu, :menu},
      {Menu, :menu_item},
      {Menu, :menu_separator},
      {Menu, :menubar},
      {Menu, :menubar_menu}
    ],
    "slider" => [{Slider, :slider}],
    "resource-list" => [{ResourceList, :resource_list}, {ResourceList, :resource_list_item}],
    "color-input" => [{ColorInput, :color_input}],
    "progress-meter" => [{Progress, :progress}, {Meter, :meter}],
    "scroll-area" => [{ScrollArea, :scroll_area}],
    "autocomplete" => [{Autocomplete, :autocomplete}],
    "accordion" => [{Accordion, :accordion}, {Accordion, :accordion_item}],
    "datetime-field" => [{DatetimeField, :datetime_field}],
    "calendar" => [{Calendar, :calendar}],
    "date-picker" => [
      {DatePicker, :date_picker},
      {DatePicker, :date_time_picker},
      {DatePicker, :time_picker},
      {DatePicker, :date_range_picker}
    ],
    "checkbox" => [{Checkbox, :checkbox}],
    "modal" => [{Modal, :modal}],
    "alert-dialog" => [{AlertDialog, :alert_dialog}],
    "dropdown" => [
      {Dropdown, :dropdown},
      {Dropdown, :dropdown_button},
      {Dropdown, :dropdown_link},
      {Dropdown, :dropdown_header},
      {Dropdown, :dropdown_separator},
      {Dropdown, :dropdown_custom}
    ],
    "command" => [
      {Command, :command},
      {Command, :command_group},
      {Command, :command_item},
      {Command, :command_empty},
      {Command, :command_separator},
      {Command, :command_shortcut}
    ],
    "breadcrumb" => [{Breadcrumb, :breadcrumb}],
    "empty-state" => [{EmptyState, :empty_state}],
    "timeline" => [{Timeline, :timeline}, {Timeline, :timeline_item}],
    "switch" => [{Switch, :switch}],
    "radio" => [{Radio, :radio}],
    "textarea" => [{Textarea, :textarea}],
    "alert" => [{Alert, :alert}],
    "loading" => [{Loading, :loading}],
    "skeleton" => [{Skeleton, :skeleton}],
    "stat" => [{Stat, :stat_card}, {Stat, :stat_grid}],
    "separator" => [{Separator, :separator}],
    "tooltip" => [{Tooltip, :tooltip}],
    "toast" => [{Toast, :toast_group}],
    "sheet" => [{Sheet, :sheet}],
    "chat-kit" => [
      {Avatar, :avatar},
      {Message, :message},
      {MessageScroller, :message_scroller},
      {MessageScroller, :message_scroller_item}
    ],
    "area-chart" => [{Charts, :area_chart}],
    "line-chart" => [{Charts, :line_chart}],
    "bar-chart" => [{Charts, :bar_chart}],
    "sparkline" => [{Charts, :sparkline}],
    "list-row" => [{ListRow, :list_row}],
    "inspector" => [
      {Inspector, :inspector},
      {Inspector, :inspector_section}
    ],
    "state-glyph" => [
      {StateGlyph, :state_glyph},
      {StateGlyph, :status_glyph},
      {StateGlyph, :priority_glyph},
      {StateGlyph, :run_glyph},
      {StateGlyph, :sync_glyph},
      {StateGlyph, :source_glyph}
    ],
    "side-panel" => [{SidePanel, :side_panel}, {SidePanel, :side_panel_toggle}]
  }

  attr(:title, :string, required: true)
  attr(:description, :string, default: nil)
  attr(:code, :string, required: true)
  slot(:inner_block, required: true)

  def demo_section(assigns) do
    slug = slugify(assigns.title) <> "-" <> Integer.to_string(:erlang.phash2(assigns.code), 36)
    assigns = assigns |> assign(:code_id, "code-" <> slug) |> assign(:ex_id, "ex-" <> slug)

    ~H"""
    <section class="docs-section">
      <h2 class="docs-section-title">{@title}</h2>
      <p :if={@description} class="docs-section-desc">{@description}</p>
      <div id={@ex_id} class="docs-example" phx-hook="DocsExample">
        <div class="docs-example-tabs" role="tablist" aria-label="Example view">
          <button type="button" class="docs-example-tab" role="tab" data-tab="preview" aria-selected="true">
            Preview
          </button>
          <button type="button" class="docs-example-tab" role="tab" data-tab="code" aria-selected="false">
            Code
          </button>
        </div>
        <div class="docs-example-panel" data-panel="preview">
          <div class="docs-demo">{render_slot(@inner_block)}</div>
        </div>
        <div class="docs-example-panel" data-panel="code" hidden>
          <.code_block id={@code_id} code={@code} />
        </div>
      </div>
    </section>
    """
  end

  attr(:id, :string, default: nil)
  attr(:code, :string, required: true)

  def snippet(assigns) do
    ~H"""
    <pre class="docs-pre"><code>{String.trim(@code)}</code></pre>
    """
  end

  attr(:id, :string, default: nil)
  attr(:code, :string, required: true)

  def code_block(assigns) do
    ~H"""
    <LiveCode.Editor.editor
      id={@id}
      language={LiveCode.Languages.HEEx}
      readonly
      value={String.trim(@code)}
      class="docs-codeblock"
    />
    """
  end

  def command_demo_code do
    ~S"""
    # LiveView - the palette does no filtering, so you do
    def handle_event("command_search", %{"query" => query}, socket) do
      {:noreply, assign(socket, query: query, groups: command_matches(query))}
    end

    def handle_event("command_select", %{"value" => value}, socket) do
      {:noreply, assign(socket, :selection, value)}
    end

    <.button phx-click={LanternUI.open_dialog("cmd-demo")}>
      Search... <.command_shortcut>Cmd+K</.command_shortcut>
    </.button>

    <.command id="cmd-demo" on_search="command_search" on_select="command_select">
      <%= for {{group, items}, index} <- Enum.with_index(@groups) do %>
        <.command_separator :if={index > 0} />
        <.command_group label={group}>
          <.command_item :for={cmd <- items} value={cmd.value} disabled={cmd.disabled}>
            <:icon><.icon name={cmd.icon} /></:icon>
            {cmd.label}
            <:description>{cmd.description}</:description>
            <:shortcut>{cmd.shortcut}</:shortcut>
          </.command_item>
        </.command_group>
      <% end %>

      <.command_empty :if={@groups == []}>No commands match "{@query}".</.command_empty>

      <:footer>Up/Down to navigate - Enter to select - Esc to close</:footer>
    </.command>
    """
  end

  defp slugify(title) do
    title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")
  end

  attr(:member, :string, required: true)

  def api_section(assigns) do
    assigns = assign(assigns, :entries, Map.get(@api_map, assigns.member, []))

    ~H"""
    <section :if={@entries != []} class="docs-api">
      <h2 class="docs-section-title">API reference</h2>
      <p class="docs-section-desc">Props and slots, introspected from the component.</p>
      <.api_table :for={{mod, fun} <- @entries} module={mod} fun={fun} multi={length(@entries) > 1} />
    </section>
    """
  end

  attr(:module, :atom, required: true)
  attr(:fun, :atom, required: true)
  attr(:multi, :boolean, default: false)

  def api_table(assigns) do
    info = assigns.module.__components__()[assigns.fun]

    assigns =
      assign(assigns,
        attrs: (info && Enum.reject(info.attrs, &(&1.type == :global))) || [],
        slots: (info && info.slots) || []
      )

    ~H"""
    <div class="docs-api-fn">
      <div :if={@multi} class="docs-api-fn-head"><code>{@fun}/1</code></div>
      <table class="docs-api-table">
        <thead>
          <tr>
            <th class="docs-api-c1">Prop</th>
            <th class="docs-api-c2">Type</th>
            <th class="docs-api-c3">Default</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={a <- @attrs}>
            <td><code>{a.name}</code><span :if={a.required} class="docs-api-req" title="required">*</span></td>
            <td><code class="docs-api-type">{attr_type(a)}</code></td>
            <td><code class="docs-api-default">{attr_default(a)}</code></td>
            <td>{a.doc}</td>
          </tr>
          <tr :if={@slots != []} class="docs-api-div"><td colspan="4">Slots</td></tr>
          <tr :for={sl <- @slots}>
            <td><code>:{sl.name}</code><span :if={sl.required} class="docs-api-req">*</span></td>
            <td class="docs-api-muted" colspan="3">{sl.doc}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp attr_type(%{type: type, opts: opts}) do
    values = if Keyword.has_key?(opts, :values), do: Enum.to_list(opts[:values])

    cond do
      values && length(values) > 10 -> "one of #{length(values)} values"
      values -> Enum.map_join(values, " | ", &to_string/1)
      is_atom(type) -> type |> Atom.to_string() |> String.trim_leading("Elixir.")
      true -> inspect(type)
    end
  end

  defp attr_default(%{required: true}), do: "—"

  defp attr_default(%{opts: opts}) do
    if Keyword.has_key?(opts, :default), do: inspect(opts[:default]), else: "—"
  end
end
