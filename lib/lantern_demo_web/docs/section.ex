defmodule LanternDemoWeb.Docs.Section do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Phoenix.Component
      import LanternDemoWeb.Docs.Kit, only: [demo_section: 1, code_block: 1, snippet: 1, command_demo_code: 0]

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
    end
  end
end
