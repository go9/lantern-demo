defmodule LanternDemoWeb.Docs.Forms do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "button"} = assigns) do
    ~H"""
    <p>
      Variants × colors, sizes, and icon buttons.
      Defaults: <code>variant="outline" color="primary" size="md"</code>.
    </p>
    <.demo_section
      title="Variants"
      description="Six surface styles. Color is primary by default."
      code={~S'''
      <.button :for={v <- ~w(solid soft surface outline dashed ghost)} variant={v}>
        {v}
      </.button>
      '''}
    >
      <div class="docs-row">
        <Button.button :for={v <- ~w(solid soft surface outline dashed ghost)} variant={v}>
          {v}
        </Button.button>
      </div>
    </.demo_section>
    <.demo_section
      title="Colors"
      description="primary, danger, warning, success, info — shown on solid."
      code={~S'''
      <.button :for={c <- ~w(primary danger warning success info)} variant="solid" color={c}>
        {c}
      </.button>
      '''}
    >
      <div class="docs-row">
        <Button.button
          :for={c <- ~w(primary danger warning success info)}
          variant="solid"
          color={c}
        >
          {c}
        </Button.button>
      </div>
    </.demo_section>
    <.demo_section
      title="Sizes"
      description="Text sizes xs–xl, icon size, and the disabled state."
      code={~S'''
      <.button :for={s <- ~w(xs sm md lg xl)} size={s}>{s}</.button>
      <.button size="icon" aria-label="Add"><.icon name="plus" /></.button>
      <.button variant="solid" disabled>disabled</.button>
      '''}
    >
      <div class="docs-row">
        <Button.button :for={s <- ~w(xs sm md lg xl)} size={s}>{s}</Button.button>
        <Button.button size="icon" aria-label="Add"><Icon.icon name="plus" /></Button.button>
        <Button.button variant="solid" disabled>disabled</Button.button>
      </div>
    </.demo_section>
    <.demo_section
      title="Button group"
      description="Joined segmented control — shared borders and radius."
      code={~S'''
      <.button_group>
        <.button>Years</.button>
        <.button>Months</.button>
        <.button>Days</.button>
      </.button_group>
      '''}
    >
      <div class="docs-row">
        <Button.button_group>
          <Button.button>Years</Button.button>
          <Button.button>Months</Button.button>
          <Button.button>Days</Button.button>
        </Button.button_group>
      </div>
    </.demo_section>
    <.demo_section
      title="Icon buttons with label + kbd"
      description="On icon-* sizes, label is the accessible name and tooltip; kbd is the optional hint in that tip. variant ghost/outline/solid."
      code={~S'''
      <.button size="icon" variant="ghost" label="Filter" kbd="F">
        <.icon name="funnel" />
      </.button>
      <.button size="icon" variant="outline" label="Display" kbd="D">
        <.icon name="adjustments-horizontal" />
      </.button>
      <.button size="icon" variant="solid" label="Promote to ticket" kbd="P">
        <.icon name="arrow-up-tray" />
      </.button>
      '''}
    >
      <div class="docs-row">
        <Button.button size="icon" variant="ghost" label="Filter" kbd="F">
          <Icon.icon name="funnel" />
        </Button.button>
        <Button.button size="icon" variant="outline" label="Display" kbd="D">
          <Icon.icon name="adjustments-horizontal" />
        </Button.button>
        <Button.button size="icon" variant="solid" label="Promote to ticket" kbd="P">
          <Icon.icon name="arrow-up-tray" />
        </Button.button>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "input"} = assigns) do
    ~H"""
    <p>
      Text field with label, sublabel, help text, and error states.
      Accepts a <code>Phoenix.HTML.FormField</code>.
    </p>
    <.demo_section
      title="Basic"
      description="Label, name, and placeholder."
      code={~S'''
      <.input id="in-1" name="name" label="Name" placeholder="Ada Lovelace" />
      '''}
    >
      <Form.input id="in-1" name="name" label="Name" placeholder="Ada Lovelace" value={nil} />
    </.demo_section>
    <.demo_section
      title="Help text & sublabel"
      description="Sublabel sits beside the label; help_text sits under the control."
      code={~S'''
      <.input
        name="email"
        label="Email"
        sublabel="Required"
        help_text="We never share it."
        placeholder="you@example.com"
      />
      '''}
    >
      <Form.input
        id="in-2"
        name="email"
        label="Email"
        sublabel="Required"
        help_text="We never share it."
        placeholder="you@example.com"
        value={nil}
      />
    </.demo_section>
    <.demo_section
      title="Error state"
      description="Pass errors as a list of strings (or use FormField)."
      code={~S'''
      <.input name="handle" label="Handle" value="not valid!" errors={["must not contain spaces"]} />
      '''}
    >
      <Form.input
        id="in-3"
        name="handle"
        label="Handle"
        value="not valid!"
        errors={["must not contain spaces"]}
      />
    </.demo_section>
    <.demo_section
      title="Disabled"
      description="Disabled fields keep their value but cannot be edited."
      code={~S'''
      <.input name="ro" label="Disabled" value="read only" disabled />
      '''}
    >
      <Form.input id="in-4" name="ro" label="Disabled" value="read only" disabled />
    </.demo_section>
    """
  end

  def member(%{member: "textarea"} = assigns) do
    ~H"""
    <p>
      Multi-line text input with the same label, help text, and error chrome as
      <code>input</code>.
    </p>
    <.demo_section
      title="Basic"
      description="Label and placeholder."
      code={~S'''
      <.textarea name="notes" label="Notes" placeholder="Write something…" />
      '''}
    >
      <Textarea.textarea
        id="ta-1"
        name="notes"
        label="Notes"
        placeholder="Write something…"
        value={nil}
      />
    </.demo_section>
    <.demo_section
      title="Help text"
      description="help_text under the control, same as input."
      code={~S'''
      <.textarea name="bio" label="Bio" help_text="A short intro for your profile." />
      '''}
    >
      <Textarea.textarea
        id="ta-2"
        name="bio"
        label="Bio"
        help_text="A short intro for your profile."
        value={nil}
      />
    </.demo_section>
    <.demo_section
      title="Error state"
      description="Invalid border and error list."
      code={~S'''
      <.textarea
        name="bad"
        label="With error"
        value="too short"
        errors={["is too short (minimum is 20 characters)"]}
      />
      '''}
    >
      <Textarea.textarea
        id="ta-3"
        name="bad"
        label="With error"
        value="too short"
        errors={["is too short (minimum is 20 characters)"]}
      />
    </.demo_section>
    <.demo_section
      title="Disabled"
      description="Read-only presentation via disabled."
      code={~S'''
      <.textarea name="ro" label="Disabled" value="Read only content" disabled />
      '''}
    >
      <Textarea.textarea
        id="ta-4"
        name="ro"
        label="Disabled"
        value="Read only content"
        disabled
      />
    </.demo_section>
    """
  end

  def member(%{member: "color-input"} = assigns) do
    ~H"""
    <p>A native color control with form-compatible name/value, label, help text, errors, disabled state, and density tokens.</p>
    <.demo_section title="Theme color" description="The submitted element is the real input type=color." code={~s"<.color_input id=\"brand-color\" name=\"brand\" value=\"#4f46e5\" label=\"Brand color\" help_text=\"Used in the project header.\" />"}>
      <ColorInput.color_input id="brand-color" name="brand" value="#4f46e5" label="Brand color" help_text="Used in the project header." />
      <ColorInput.color_input id="disabled-color" name="disabled" value="#64748b" label="Disabled" size="sm" disabled />
    </.demo_section>
    """
  end

  def member(%{member: "checkbox"} = assigns) do
    ~H"""
    <p>
      Fluxon-compatible, <code>FormField</code>-aware. A hidden input submits the
      unchecked value so forms always receive the param.
    </p>
    <.demo_section
      title="Basic"
      description="Unchecked by default; label is optional."
      code={~S'''
      <.checkbox id="ck-1" name="accept" label="Accept the terms" />
      '''}
    >
      <Checkbox.checkbox id="ck-1" name="accept" label="Accept the terms" />
    </.demo_section>
    <.demo_section
      title="Checked with description"
      description="description renders under the label for longer helper copy."
      code={~S'''
      <.checkbox
        name="notify"
        checked
        label="Email me about activity"
        description="At most one email per day."
      />
      '''}
    >
      <Checkbox.checkbox
        id="ck-2"
        name="notify"
        checked
        label="Email me about activity"
        description="At most one email per day."
      />
    </.demo_section>
    <.demo_section
      title="Disabled"
      description="Non-interactive; value still posts if the control is checked."
      code={~S'''
      <.checkbox name="dis" label="Disabled" disabled />
      '''}
    >
      <Checkbox.checkbox id="ck-3" name="dis" label="Disabled" disabled />
    </.demo_section>
    <.demo_section
      title="Error state"
      description="Invalid chrome and error message under the control."
      code={~S'''
      <.checkbox name="err" label="Required" errors={["must be accepted"]} />
      '''}
    >
      <Checkbox.checkbox id="ck-4" name="err" label="Required" errors={["must be accepted"]} />
    </.demo_section>
    """
  end

  def member(%{member: "radio"} = assigns) do
    ~H"""
    <p>
      Exclusive single selection — <code>list</code> (default) or <code>cards</code> variant.
    </p>
    <.demo_section
      title="List"
      description="Default list layout; sublabel annotates an option."
      code={~S'''
      <.radio name="plan" value="pro" label="Plan" variant="list">
        <:radio value="basic" label="Basic" />
        <:radio value="pro" label="Pro" sublabel="Popular" />
        <:radio value="enterprise" label="Enterprise" />
      </.radio>
      '''}
    >
      <Radio.radio id="rd-list" name="plan" value="pro" label="Plan" variant="list">
        <:radio value="basic" label="Basic" />
        <:radio value="pro" label="Pro" sublabel="Popular" />
        <:radio value="enterprise" label="Enterprise" />
      </Radio.radio>
    </.demo_section>
    <.demo_section
      title="Cards"
      description="Card layout with optional per-option description."
      code={~S'''
      <.radio name="tier" value="team" label="Tier" variant="cards">
        <:radio value="free" label="Free" description="Hobby projects" />
        <:radio value="team" label="Team" description="Collaboration" />
        <:radio value="scale" label="Scale" description="Growing teams" />
      </.radio>
      '''}
    >
      <Radio.radio id="rd-cards" name="tier" value="team" label="Tier" variant="cards">
        <:radio value="free" label="Free" description="Hobby projects" />
        <:radio value="team" label="Team" description="Collaboration" />
        <:radio value="scale" label="Scale" description="Growing teams" />
      </Radio.radio>
    </.demo_section>
    """
  end

  def member(%{member: "switch"} = assigns) do
    ~H"""
    <p>
      Toggle switch for binary settings. Sizes <code>sm</code>/<code>md</code>/<code>lg</code>,
      with optional label and description.
    </p>
    <.demo_section
      title="Basic"
      description="Unchecked and checked. A hidden input always submits the off value."
      code={~S'''
      <.switch name="sw_off" label="Unchecked" />
      <.switch name="sw_on" checked label="Checked" />
      '''}
    >
      <div class="docs-row" style="flex-direction: column; align-items: flex-start; gap: .75rem;">
        <Switch.switch id="sw-1" name="sw_off" label="Unchecked" />
        <Switch.switch id="sw-2" name="sw_on" checked label="Checked" />
      </div>
    </.demo_section>
    <.demo_section
      title="Sizes"
      description="sm, md (default), and lg."
      code={~S'''
      <.switch name="sw_sm" size="sm" label="sm" checked />
      <.switch name="sw_md" size="md" label="md" checked />
      <.switch name="sw_lg" size="lg" label="lg" checked />
      '''}
    >
      <div class="docs-row">
        <Switch.switch id="sw-sm" name="sw_sm" size="sm" label="sm" checked />
        <Switch.switch id="sw-md" name="sw_md" size="md" label="md" checked />
        <Switch.switch id="sw-lg" name="sw_lg" size="lg" label="lg" checked />
      </div>
    </.demo_section>
    <.demo_section
      title="Label & description"
      description="description sits under the label for longer helper copy."
      code={~S'''
      <.switch
        name="sw_desc"
        checked
        label="Email notifications"
        description="At most one email per day."
      />
      '''}
    >
      <Switch.switch
        id="sw-4"
        name="sw_desc"
        checked
        label="Email notifications"
        description="At most one email per day."
      />
    </.demo_section>
    <.demo_section
      title="Disabled"
      description="Non-interactive switch."
      code={~S'''
      <.switch name="sw_dis" label="Disabled" disabled />
      '''}
    >
      <Switch.switch id="sw-3" name="sw_dis" label="Disabled" disabled />
    </.demo_section>
    """
  end

  def member(%{member: "select"} = assigns) do
    ~H"""
    <p>
      FormField-aware select (Fluxon API): rich listbox with keyboard nav +
      type-ahead over a hidden input, or a <code>native</code> fallback.
    </p>
    <.demo_section
      title="Basic"
      description="Rich listbox with label, options, and placeholder."
      code={~S'''
      <.select
        name="channel"
        label="Channel"
        options={[{"eBay", "ebay"}, {"Shopify", "shopify"}, {"Direct", "direct"}]}
        placeholder="Pick a channel"
      />
      '''}
    >
      <Select.select
        id="sel-1"
        name="channel"
        label="Channel"
        options={[{"eBay", "ebay"}, {"Shopify", "shopify"}, {"Direct", "direct"}]}
        placeholder="Pick a channel"
      />
    </.demo_section>
    <.demo_section
      title="With value"
      description="Controlled value selects the matching option."
      code={~S'''
      <.select
        name="status"
        label="Status"
        value="active"
        options={[{"Active", "active"}, {"Archived", "archived"}]}
      />
      '''}
    >
      <Select.select
        id="sel-2"
        name="status"
        label="Status"
        value="active"
        options={[{"Active", "active"}, {"Archived", "archived"}]}
      />
    </.demo_section>
    <.demo_section
      title="Multiple"
      description="multiple keeps the panel open and submits name[] for each selection."
      code={~S'''
      <.select
        name="tags"
        label="Multiple"
        multiple
        value={["elixir", "phoenix"]}
        options={[
          {"Elixir", "elixir"},
          {"Phoenix", "phoenix"},
          {"LiveView", "liveview"},
          {"Ecto", "ecto"}
        ]}
      />
      '''}
    >
      <Select.select
        id="sel-5"
        name="tags"
        label="Multiple"
        multiple
        value={["elixir", "phoenix"]}
        options={[
          {"Elixir", "elixir"},
          {"Phoenix", "phoenix"},
          {"LiveView", "liveview"},
          {"Ecto", "ecto"}
        ]}
      />
    </.demo_section>
    <.demo_section
      title="Searchable"
      description="searchable adds a filter box in the listbox (or set search_threshold)."
      code={~S'''
      <.select
        name="country"
        label="Searchable"
        searchable
        placeholder="Pick a country"
        options={["Argentina", "Australia", "Brazil", "Canada", "Denmark"]}
      />
      '''}
    >
      <Select.select
        id="sel-6"
        name="country"
        label="Searchable"
        searchable
        placeholder="Pick a country"
        options={[
          "Argentina",
          "Australia",
          "Brazil",
          "Canada",
          "Denmark",
          "Estonia",
          "France",
          "Germany",
          "Iceland",
          "Japan",
          "Mexico",
          "Netherlands",
          "Norway",
          "Portugal",
          "Sweden",
          "United States"
        ]}
      />
    </.demo_section>
    <.demo_section
      title="Multi + search"
      description="Combine multiple and searchable for large option sets."
      code={~S'''
      <.select
        name="team"
        label="Multi + search"
        multiple
        searchable
        options={["Ada", "Alan", "Barbara", "Donald", "Edsger", "Grace", "Ken", "Radia"]}
      />
      '''}
    >
      <Select.select
        id="sel-7"
        name="team"
        label="Multi + search"
        multiple
        searchable
        options={["Ada", "Alan", "Barbara", "Donald", "Edsger", "Grace", "Ken", "Radia"]}
      />
    </.demo_section>
    <.demo_section
      title="Native"
      description="native renders a plain &lt;select&gt; — useful for dense tool UIs."
      code={~S'''
      <.select name="size" label="Native" native value={25} options={[10, 25, 50]} />
      '''}
    >
      <Select.select
        id="sel-3"
        name="size"
        label="Native"
        native
        value={25}
        options={[10, 25, 50]}
      />
    </.demo_section>
    <.demo_section
      title="Error state"
      description="Same FormField / errors list pattern as input."
      code={~S'''
      <.select name="bad" label="With error" options={["a"]} errors={["can't be blank"]} />
      '''}
    >
      <Select.select
        id="sel-4"
        name="bad"
        label="With error"
        options={["a"]}
        errors={["can't be blank"]}
      />
    </.demo_section>
    <.demo_section
      title="Client mode (default)"
      description="Zag owns the value from data-default-value; picks sync the hidden input and fire input/change, so an existing phx-change keeps working with no server round trip."
      code={~S'''
      <.select
        id="sel-client"
        name="channel"
        label="Client mode"
        value="shopify"
        options={[{"eBay", "ebay"}, {"Shopify", "shopify"}, {"Direct", "direct"}]}
      />
      '''}
    >
      <Select.select
        id="sel-client"
        name="channel"
        label="Client mode"
        value="shopify"
        options={[{"eBay", "ebay"}, {"Shopify", "shopify"}, {"Direct", "direct"}]}
      />
    </.demo_section>
    <.demo_section
      title="Server-driven (controlled)"
      description="controlled makes the server value truth: client picks flow out through on_change, and server patches flow back into the machine. Pick in the listbox, or drive it from the server buttons."
      code={~S'''
      <.select
        id="sel-controlled"
        name="status"
        label="Controlled"
        controlled
        on_change="controlled_status_changed"
        value={@controlled_status}
        options={[{"Active", "active"}, {"Archived", "archived"}]}
      />
      '''}
    >
      <Select.select
        id="sel-controlled"
        name="status"
        label="Controlled"
        controlled
        on_change="controlled_status_changed"
        value={@controlled_status}
        options={[{"Active", "active"}, {"Archived", "archived"}]}
      />
      <p class="docs-confirm-status" role="status">
        Server value: <code>{@controlled_status}</code>
      </p>
      <div class="docs-row">
        <Button.button
          size="sm"
          variant={if @controlled_status == "active", do: "solid", else: "outline"}
          phx-click="set_controlled_status"
          phx-value-value="active"
        >
          Set active (server)
        </Button.button>
        <Button.button
          size="sm"
          variant={if @controlled_status == "archived", do: "solid", else: "outline"}
          phx-click="set_controlled_status"
          phx-value-value="archived"
        >
          Set archived (server)
        </Button.button>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "autocomplete"} = assigns) do
    ~H"""
    <p>
      Accessible static or LiveView-backed search. Lantern owns the combobox,
      keyboard selection, and presentation; your LiveView owns remote querying,
      authorization, and result order. The public API mirrors Fluxon 2.3.1.
    </p>
    <.demo_section
      title="Static filtering"
      description="Static options filter in the browser; selection fills the hidden form input."
      code={~S'''
      <.autocomplete
        id="ac-fruit"
        name="fruit"
        label="Fruit"
        placeholder="Search fruit…"
        options={["Apple", "Apricot", "Banana", "Blackberry", "Cherry", "Grape"]}
      />
      '''}
    >
      <Autocomplete.autocomplete
        id="ac-fruit"
        name="fruit"
        label="Fruit"
        placeholder="Search fruit…"
        options={["Apple", "Apricot", "Banana", "Blackberry", "Cherry", "Grape"]}
      />
    </.demo_section>

    <.demo_section
      title="Server-backed search"
      description="Type at least two characters (try “zel”). The LiveView filters server-owned data and patches grouped, rich results back into the same focused combobox."
      code={~S'''
      # LiveView
      def handle_event("search_catalog", %{"query" => query}, socket) do
        {:noreply, assign(socket, :catalog_options, search_catalog(query))}
      end

      <.autocomplete
        id="ac-catalog"
        name="game_id"
        label="Game catalog"
        options={@catalog_options}
        on_search="search_catalog"
        search_threshold={2}
        debounce={250}
        clearable
        no_results_text="No games match %{query}"
      >
        <:option :let={{label, value}}>
          <span>{label}</span><code>{value}</code>
        </:option>
      </.autocomplete>
      '''}
    >
      <Autocomplete.autocomplete
        id="ac-catalog"
        name="game_id"
        label="Game catalog"
        description="Server-backed, grouped results with rich option rows."
        placeholder="Search the catalog…"
        options={@catalog_options}
        on_search="search_catalog"
        search_threshold={2}
        debounce={250}
        clearable
        no_results_text="No games match %{query}"
      >
        <:header>Results from the demo LiveView</:header>
        <:option :let={{label, value}}>
          <span class="docs-option-rich">
            <span>{label}</span>
            <code>{value}</code>
          </span>
        </:option>
        <:footer>Fixed demo data; production search remains caller-owned.</:footer>
      </Autocomplete.autocomplete>
    </.demo_section>
    """
  end

  def member(%{member: "slider"} = assigns) do
    ~H"""
    <p>A pointer and keyboard slider writes its hidden input on committed changes. <code>value_text</code> supplies human-readable aria-valuetext; disabled and invalid states remain visible.</p>
    <.demo_section title="Volume" description="Use Arrow keys, Home, End, PageUp, PageDown, or drag the thumb." code={~s"<.slider id=\"volume\" name=\"volume\" value={72} min={0} max={100} step={4} label=\"Volume\" value_text=\"{value}%\" />"}>
      <Slider.slider id="volume" name="volume" value={72} min={0} max={100} step={4} label="Volume" value_text="{value}%" />
      <Slider.slider id="disabled-volume" name="disabled_volume" value={20} label="Disabled" disabled />
      <Slider.slider id="invalid-volume" name="invalid_volume" value={120} label="Invalid" errors={["Choose a value below 100"]} />
    </.demo_section>
    """
  end

  def member(%{member: "datetime-field"} = assigns) do
    ~H"""
    <p>
      Segmented, keyboard-first entry: type straight into a segment,
      <kbd>↑</kbd><kbd>↓</kbd> to step, <kbd>←</kbd><kbd>→</kbd> to move.
      Backs a hidden input with the canonical value.
    </p>
    <.demo_section
      title="Date mode"
      description="Canonical value is YYYY-MM-DD."
      code={~S'''
      <.datetime_field id="dtf-date" name="dtf1" mode={:date} value="2026-07-08" />
      '''}
    >
      <DatetimeField.datetime_field id="dtf-date" name="dtf1" mode={:date} value="2026-07-08" />
    </.demo_section>
    <.demo_section
      title="Time mode"
      description="precision controls which segments appear (:minute, :second, :millisecond)."
      code={~S'''
      <.datetime_field
        id="dtf-time"
        name="dtf2"
        mode={:time}
        precision={:millisecond}
        value="14:30:00.000"
      />
      '''}
    >
      <DatetimeField.datetime_field
        id="dtf-time"
        name="dtf2"
        mode={:time}
        precision={:millisecond}
        value="14:30:00.000"
      />
    </.demo_section>
    <.demo_section
      title="Datetime mode"
      description="Combined date + time; canonical value is ISO-8601 local."
      code={~S'''
      <.datetime_field
        id="dtf-dt"
        name="at"
        mode={:datetime}
        precision={:millisecond}
        value="2026-07-08T14:30:00.000"
      />
      '''}
    >
      <DatetimeField.datetime_field
        id="dtf-dt"
        name="at"
        mode={:datetime}
        precision={:millisecond}
        value="2026-07-08T14:30:00.000"
      />
    </.demo_section>
    """
  end

  def member(%{member: "calendar"} = assigns) do
    ~H"""
    <p>
      APG-grid month calendar: arrow keys move by day/week,
      <kbd>PgUp</kbd>/<kbd>PgDn</kbd> by month, <kbd>t</kbd> jumps to today.
    </p>
    <.demo_section
      title="Basic"
      description="Selected day uses monochrome-primary fill; today gets a coral ring."
      code={~S'''
      <.calendar id="cal-demo" selected={Date.utc_today()} />
      '''}
    >
      <div class="docs-cal-box">
        <Calendar.calendar id="cal-demo" selected={Date.utc_today()} />
      </div>
    </.demo_section>
    <.demo_section
      title="Week start & min date"
      description="week_start is 0=Sunday … 6=Saturday; min disables earlier days."
      code={~S'''
      <.calendar id="cal-min" selected={~D[2026-07-08]} week_start={1} min="2026-01-01" />
      '''}
    >
      <div class="docs-cal-box">
        <Calendar.calendar
          id="cal-min"
          selected={~D[2026-07-08]}
          week_start={1}
          min="2026-01-01"
        />
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "date-picker"} = assigns) do
    ~H"""
    <p>
      Fluxon-compatible API. Segmented trigger + calendar popover with a time pane
      (<code>date_time_picker</code>). <code>time_picker</code>
      is segments-only — a lantern-ui extension.
    </p>
    <.demo_section
      title="Date picker"
      description="Segmented date trigger with a calendar popover."
      code={~S'''
      <.date_picker id="pk-date" name="due" label="Due date" value="2026-07-08" />
      '''}
    >
      <DatePicker.date_picker id="pk-date" name="due" label="Due date" value="2026-07-08" />
    </.demo_section>
    <.demo_section
      title="Date-time picker"
      description="Calendar plus a time pane; precision controls the time segments."
      code={~S'''
      <.date_time_picker
        id="pk-dt"
        name="starts_at"
        label="Starts at"
        precision={:millisecond}
        value="2026-07-08T09:15:00.000"
      />
      '''}
    >
      <DatePicker.date_time_picker
        id="pk-dt"
        name="starts_at"
        label="Starts at"
        precision={:millisecond}
        value="2026-07-08T09:15:00.000"
      />
    </.demo_section>
    <.demo_section
      title="Time picker"
      description="Segments-only time entry — a lantern-ui extension."
      code={~S'''
      <.time_picker id="pk-time" name="alarm" label="Alarm" value="08:45:00.000" />
      '''}
    >
      <DatePicker.time_picker id="pk-time" name="alarm" label="Alarm" value="08:45:00.000" />
    </.demo_section>
    <.demo_section
      title="Error state"
      description="Same error chrome as other form controls."
      code={~S'''
      <.date_picker id="pk-err" name="bad" label="With error" errors={["can't be blank"]} />
      '''}
    >
      <DatePicker.date_picker
        id="pk-err"
        name="bad"
        label="With error"
        value={nil}
        errors={["can't be blank"]}
      />
    </.demo_section>
    <.demo_section
      title="Date range"
      description="Two ordinary form fields compose a start and end date range."
      code={~S'''
      <.date_range_picker start_field={f[:from]} end_field={f[:to]} label="Release window" />
      '''}
    >
      <DatePicker.date_range_picker
        id="pk-range"
        start_field={@range_form[:from]}
        end_field={@range_form[:to]}
        label="Release window"
      />
    </.demo_section>
    """
  end
end
