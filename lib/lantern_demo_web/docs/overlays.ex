defmodule LanternDemoWeb.Docs.Overlays do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "modal"} = assigns) do
    ~H"""
    <p>
      General-purpose dialog content on the shared overlay runtime: focus trap,
      <kbd>Esc</kbd>/outside dismissal, optional close button, and token-driven fade.
      Use it for forms, details, and reversible workflows.
    </p>
    <.demo_section
      title="Edit workspace details"
      description="A normal modal can contain arbitrary form content and dismisses on Esc, close button, or outside click."
      code={~S'''
      <.button phx-click={LanternUI.open_dialog("workspace-modal")}>Edit workspace</.button>

      <.modal id="workspace-modal">
        <h2>Edit workspace</h2>
        <.input name="workspace_name" label="Workspace name" value="Acme Operations" />
        <.button phx-click={LanternUI.close_dialog("workspace-modal")}>Cancel</.button>
        <.button variant="solid" phx-click={LanternUI.close_dialog("workspace-modal")}>Save</.button>
      </.modal>
      '''}
    >
      <div class="docs-row">
        <Button.button phx-click={LanternUI.open_dialog("demo-modal")}>
          Edit workspace…
        </Button.button>
      </div>
      <Modal.modal id="demo-modal">
        <h2 style="margin: 0 0 1rem; font-size: 1.05rem;">Edit workspace details</h2>
        <Form.input
          id="modal-workspace-name"
          name="workspace_name"
          label="Workspace name"
          value="Acme Operations"
        />
        <div style="display: flex; gap: .5rem; justify-content: flex-end; margin-top: 1rem;">
          <Button.button phx-click={LanternUI.close_dialog("demo-modal")}>Cancel</Button.button>
          <Button.button variant="solid" phx-click={LanternUI.close_dialog("demo-modal")}>
            Save changes
          </Button.button>
        </div>
      </Modal.modal>
    </.demo_section>
    """
  end

  def member(%{member: "alert-dialog"} = assigns) do
    ~H"""
    <p>
      A deliberately constrained confirmation surface for irreversible or high-impact
      choices. Unlike a general modal, it requires consequence copy plus cancel/action
      controls, focuses Cancel first, hides the generic close button, and ignores outside clicks.
    </p>
    <.demo_section
      title="Revoke a production credential"
      description="The consequence is concrete and the destructive action is visually singular. This demo never changes a real credential."
      code={~S'''
      <.button phx-click={LanternUI.open_dialog("revoke-key")}>Revoke key…</.button>

      <.alert_dialog id="revoke-key">
        <:title>Revoke the production API key?</:title>
        <:description>Requests using pk_live_7K… will fail immediately.</:description>
        <:cancel>
          <.button phx-click={LanternUI.close_dialog("revoke-key")}>Keep key</.button>
        </:cancel>
        <:action>
          <.button color="danger" variant="solid" phx-click="revoke_key">Revoke key</.button>
        </:action>
      </.alert_dialog>
      '''}
    >
      <div class="docs-row">
        <Button.button phx-click={LanternUI.open_dialog("alert-dialog-demo")}>
          Revoke production key…
        </Button.button>
        <p
          :if={@alert_dialog_status}
          id="alert-dialog-status"
          class="docs-confirm-status"
          role="status"
        >
          {@alert_dialog_status}
        </p>
      </div>
      <AlertDialog.alert_dialog id="alert-dialog-demo">
        <:title>Revoke the production API key?</:title>
        <:description>
          Requests using <code>pk_live_7K…</code> will fail immediately. This demo changes no real credential.
        </:description>
        <:cancel>
          <Button.button phx-click={LanternUI.close_dialog("alert-dialog-demo")}>
            Keep key
          </Button.button>
        </:cancel>
        <:action>
          <Button.button color="danger" variant="solid" phx-click="confirm_demo_revoke">
            Revoke key
          </Button.button>
        </:action>
      </AlertDialog.alert_dialog>
    </.demo_section>
    """
  end

  def member(%{member: "sheet"} = assigns) do
    ~H"""
    <p>
      Slide-over panel (drawer) that enters from a screen edge. Shares the modal's
      <code>open_dialog</code>/<code>close_dialog</code> runtime with focus trap and Escape/backdrop dismissal.
    </p>
    <.demo_section
      title="Trigger & content"
      description="A button opens the sheet; it shares the modal's open_dialog/close_dialog runtime."
      code={~S'''
      <.button phx-click={open_dialog("settings")}>Open sheet</.button>

      <.sheet id="settings" title="Edit settings">
        <p>Sheet body content goes here.</p>
        <:footer>
          <.button variant="outline" size="sm" phx-click={close_dialog("settings")}>Cancel</.button>
          <.button variant="solid" size="sm" phx-click={close_dialog("settings")}>Save</.button>
        </:footer>
      </.sheet>
      '''}
    >
      <Button.button phx-click={LanternUI.open_dialog("sheet-basic")}>Open sheet</Button.button>
      <Sheet.sheet id="sheet-basic" title="Edit settings">
        <p>
          Sheet body content goes here. Focus is trapped; Escape or the backdrop closes it.
        </p>
        <:footer>
          <Button.button
            variant="outline"
            size="sm"
            phx-click={LanternUI.close_dialog("sheet-basic")}
          >
            Cancel
          </Button.button>
          <Button.button
            variant="solid"
            size="sm"
            phx-click={LanternUI.close_dialog("sheet-basic")}
          >
            Save
          </Button.button>
        </:footer>
      </Sheet.sheet>
    </.demo_section>

    <.demo_section
      title="Placement"
      description="Slides in from any edge — left, right (default), top, or bottom."
      code={~S'''
      <.sheet id="nav" placement="left">…</.sheet>
      <.sheet id="panel" placement="right">…</.sheet>
      <.sheet id="banner" placement="top">…</.sheet>
      <.sheet id="tray" placement="bottom">…</.sheet>
      '''}
    >
      <div class="docs-row">
        <Button.button phx-click={LanternUI.open_dialog("sheet-left")}>left</Button.button>
        <Button.button phx-click={LanternUI.open_dialog("sheet-right")}>right</Button.button>
        <Button.button phx-click={LanternUI.open_dialog("sheet-top")}>top</Button.button>
        <Button.button phx-click={LanternUI.open_dialog("sheet-bottom")}>bottom</Button.button>
      </div>
      <Sheet.sheet id="sheet-left" placement="left" title="left">
        <p>Slides in from the left.</p>
      </Sheet.sheet>
      <Sheet.sheet id="sheet-right" placement="right" title="right">
        <p>Slides in from the right.</p>
      </Sheet.sheet>
      <Sheet.sheet id="sheet-top" placement="top" title="top">
        <p>Slides in from the top.</p>
      </Sheet.sheet>
      <Sheet.sheet id="sheet-bottom" placement="bottom" title="bottom">
        <p>Slides in from the bottom.</p>
      </Sheet.sheet>
    </.demo_section>

    <.demo_section
      title="Prevent closing"
      description="prevent_closing removes the close button and disables Escape/backdrop dismissal — the sheet must be closed by an explicit action."
      code={~S'''
      <.sheet id="confirm" title="Confirm" prevent_closing>
        <p>You must choose an action.</p>
        <:footer>
          <.button variant="solid" size="sm" phx-click={close_dialog("confirm")}>Done</.button>
        </:footer>
      </.sheet>
      '''}
    >
      <Button.button phx-click={LanternUI.open_dialog("sheet-locked")}>
        Open locked sheet
      </Button.button>
      <Sheet.sheet id="sheet-locked" title="Confirm" prevent_closing>
        <p>You must choose an action.</p>
        <:footer>
          <Button.button
            variant="solid"
            size="sm"
            phx-click={LanternUI.close_dialog("sheet-locked")}
          >
            Done
          </Button.button>
        </:footer>
      </Sheet.sheet>
    </.demo_section>
    """
  end

  def member(%{member: "popover"} = assigns) do
    ~H"""
    <p>Popover content is a surface for form-like content. It keeps focus return, Escape, and outside-click dismissal while allowing interaction inside the panel. Unlike a dropdown menu, it does not close when a field is used.</p>
    <.demo_section title="Filter form" description="The default slot is the trigger and :content is the panel." code={~s"<.popover id=\"filters\" placement=\"bottom-start\"><.button variant=\"outline\">Filters</.button><:content><.input name=\"query\" label=\"Project name\" /><.button size=\"sm\">Apply</.button></:content></.popover>"}>
      <Popover.popover id="filters" placement="bottom-start"><Button.button variant="outline">Filters</Button.button><:content><Form.input name="query" label="Project name" description="Search active projects." /><Button.button size="sm">Apply</Button.button></:content></Popover.popover>
    </.demo_section>
    """
  end

  def member(%{member: "tooltip"} = assigns) do
    ~H"""
    <p>
      Hover/focus tips with placement and optional arrow. Content can be a string or a
      <code>:content</code> slot.
    </p>
    <.demo_section
      title="Placement"
      description="placement positions the tip relative to the trigger."
      code={~S'''
      <.tooltip id="tip-top" value="Placed on top" placement="top">
        <.button size="sm">Top</.button>
      </.tooltip>
      <.tooltip id="tip-bottom" value="Placed on bottom" placement="bottom">
        <.button size="sm">Bottom</.button>
      </.tooltip>
      '''}
    >
      <div class="docs-row">
        <Tooltip.tooltip id="tip-top" value="Placed on top" placement="top">
          <Button.button size="sm">Top</Button.button>
        </Tooltip.tooltip>
        <Tooltip.tooltip id="tip-bottom" value="Placed on bottom" placement="bottom">
          <Button.button size="sm">Bottom</Button.button>
        </Tooltip.tooltip>
      </div>
    </.demo_section>
    <.demo_section
      title="Rich content"
      description="Use the :content slot for markup inside the tip."
      code={~S'''
      <.tooltip id="tip-content" placement="top">
        <.button size="sm">Rich content</.button>
        <:content>
          <strong>Bold</strong> tip with <em>markup</em>
        </:content>
      </.tooltip>
      '''}
    >
      <div class="docs-row">
        <Tooltip.tooltip id="tip-content" placement="top">
          <Button.button size="sm">Rich content</Button.button>
          <:content>
            <strong>Bold</strong> tip with <em>markup</em>
          </:content>
        </Tooltip.tooltip>
      </div>
    </.demo_section>
    <.demo_section
      title="No arrow"
      description="arrow={false} removes the caret."
      code={~S'''
      <.tooltip id="tip-no-arrow" value="No arrow" placement="bottom" arrow={false}>
        <.button size="sm">No arrow</.button>
      </.tooltip>
      '''}
    >
      <div class="docs-row">
        <Tooltip.tooltip id="tip-no-arrow" value="No arrow" placement="bottom" arrow={false}>
          <Button.button size="sm">No arrow</Button.button>
        </Tooltip.tooltip>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "dropdown"} = assigns) do
    ~H"""
    <p>
      Fluxon-compatible family with WAI-ARIA menu semantics — <kbd>↑</kbd><kbd>↓</kbd>
      move through items, <kbd>Esc</kbd> closes, focus returns to the trigger.
    </p>
    <.demo_section
      title="Label trigger"
      description="Default toggle button from label=; header, buttons, separator, and danger item."
      code={~S'''
      <.dropdown id="dd-demo" label="Actions">
        <.dropdown_header>object.png</.dropdown_header>
        <.dropdown_button><.icon name="arrow-down-tray" /> Download</.dropdown_button>
        <.dropdown_button><.icon name="arrow-path" /> Rename</.dropdown_button>
        <.dropdown_separator />
        <.dropdown_button data-danger><.icon name="trash" /> Delete</.dropdown_button>
      </.dropdown>
      '''}
    >
      <div class="docs-row">
        <Dropdown.dropdown id="dd-demo" label="Actions">
          <Dropdown.dropdown_header>object.png</Dropdown.dropdown_header>
          <Dropdown.dropdown_button>
            <Icon.icon name="arrow-down-tray" /> Download
          </Dropdown.dropdown_button>
          <Dropdown.dropdown_button>
            <Icon.icon name="arrow-path" /> Rename
          </Dropdown.dropdown_button>
          <Dropdown.dropdown_separator />
          <Dropdown.dropdown_button data-danger>
            <Icon.icon name="trash" /> Delete
          </Dropdown.dropdown_button>
        </Dropdown.dropdown>
      </div>
    </.demo_section>
    <.demo_section
      title="Custom toggle & placement"
      description=":toggle slot for any trigger; placement anchors the panel."
      code={~S'''
      <.dropdown id="dd-icon" placement="bottom-end">
        <:toggle>
          <.button size="icon" aria-label="More"><.icon name="ellipsis-horizontal" /></.button>
        </:toggle>
        <.dropdown_button>Duplicate</.dropdown_button>
        <.dropdown_button>Move…</.dropdown_button>
      </.dropdown>
      '''}
    >
      <div class="docs-row">
        <Dropdown.dropdown id="dd-icon" placement="bottom-end">
          <:toggle>
            <Button.button size="icon" aria-label="More">
              <Icon.icon name="ellipsis-horizontal" />
            </Button.button>
          </:toggle>
          <Dropdown.dropdown_button>Duplicate</Dropdown.dropdown_button>
          <Dropdown.dropdown_button>Move…</Dropdown.dropdown_button>
          </Dropdown.dropdown>
        </div>
      </.demo_section>
    <.demo_section
      title="Custom content"
      description="Use dropdown_custom for non-item content that should stay inside the menu panel."
      code={~S'''
      <.dropdown id="dd-custom" label="Account">
        <.dropdown_custom><p>Signed in as ada@example.com</p></.dropdown_custom>
      </.dropdown>
      '''}
    >
      <Dropdown.dropdown id="dd-custom" label="Account">
        <Dropdown.dropdown_custom class="docs-dropdown-custom">
          <p data-part="custom-content">Signed in as ada@example.com</p>
        </Dropdown.dropdown_custom>
      </Dropdown.dropdown>
    </.demo_section>
    """
  end

  def member(%{member: "menu"} = assigns) do
    ~H"""
    <p>These controls implement the APG menu-button and menubar keyboard models with roles, roving tabindex, arrow keys, Home, and End.</p>
    <.demo_section title="Actions" description="Items can be disabled, separated, linked, or custom-triggered." code={~s"<.menu label=\"File\"><.menu_item>New</.menu_item><.menu_separator /><.menu_item disabled>Unavailable</.menu_item><.menu_item>Export</.menu_item></.menu>"}>
      <Menu.menu id="file-menu" label="File"><Menu.menu_item>New</Menu.menu_item><Menu.menu_separator /><Menu.menu_item disabled>Unavailable</Menu.menu_item><Menu.menu_item>Export <kbd>⌘E</kbd></Menu.menu_item></Menu.menu>
    </.demo_section>
    <.demo_section title="Menubar" description="Top-level entries use horizontal arrow navigation." code={~s"<.menubar label=\"Editor\"><.menubar_menu label=\"File\"><.menu_item>New</.menu_item></.menubar_menu><.menubar_menu label=\"Edit\"><.menu_item>Undo</.menu_item></.menubar_menu></.menubar>"}>
      <Menu.menubar id="editor-menubar" label="Editor"><Menu.menubar_menu label="File"><Menu.menu_item>New</Menu.menu_item></Menu.menubar_menu><Menu.menubar_menu label="Edit"><Menu.menu_item>Undo</Menu.menu_item></Menu.menubar_menu></Menu.menubar>
    </.demo_section>
    """
  end

  def member(%{member: "command"} = assigns) do
    ~H"""
    <p>
      A ⌘K dialog: a modal combobox over a listbox of actions, on the shared overlay
      runtime. The component owns opening, the focus trap, keyboard traversal, and
      <code>aria-activedescendant</code>; <strong>it never filters its own children</strong>
      — it renders exactly the items you hand it and reports the query upward, so search
      can come from a database, an index, or memory.
    </p>
    <.demo_section
      title="Searchable actions"
      description="Press ⌘J (Ctrl+J on Windows/Linux; ⌘K is the docs search) or use the button. Type to filter, ↑/↓ to move, Enter to choose, Esc to close. Filtering happens in the LiveView — the palette itself renders whatever it is given."
      code={command_demo_code()}
    >
      <div class="docs-row">
        <Button.button phx-click={LanternUI.open_dialog("cmd-demo")}>
          Search commands…
          <Command.command_shortcut>⌘J</Command.command_shortcut>
        </Button.button>
        <p id="command-selection" class="docs-confirm-status" role="status">
          <%= case @command_selection do %>
            <% nil -> %>
              Nothing chosen yet — open the palette and press Enter on a row.
            <% {value, label} -> %>
              Selected <strong>{label}</strong> (<code>{value}</code>)
          <% end %>
        </p>
      </div>

      <Command.command
        id="cmd-demo"
        hotkey="j"
        label="Demo command palette"
        placeholder="Type a command or search…"
        on_search="command_search"
        on_select="command_select"
        debounce={120}
      >
        <%= for {{group, items}, index} <- Enum.with_index(@command_groups) do %>
          <Command.command_separator :if={index > 0} />
          <Command.command_group label={group}>
            <Command.command_item
              :for={cmd <- items}
              value={cmd.value}
              disabled={Map.get(cmd, :disabled, false)}
            >
              <:icon><Icon.icon name={cmd.icon} /></:icon>
              {cmd.label}
              <:description>{cmd.description}</:description>
              <:shortcut :if={cmd.shortcut}>{cmd.shortcut}</:shortcut>
            </Command.command_item>
          </Command.command_group>
        <% end %>
        <Command.command_empty :if={@command_groups == []}>
          No commands match “{@command_query}”.
        </Command.command_empty>

        <:footer>
          <span>↑↓ to navigate · ↵ to select · esc to close</span>
        </:footer>
      </Command.command>
    </.demo_section>
    """
  end
end
