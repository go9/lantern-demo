defmodule LanternDemoWeb.Docs.Foundations do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "icon"} = assigns) do
    ~H"""
    <p>Inline heroicons (outline), sized by font-size.</p>
    <.demo_section
      title="Gallery"
      description="Pass a heroicon name; the glyph scales with surrounding font-size."
      code={~S'''
      <.icon name="calendar-days" />
      <.icon name="magnifying-glass" />
      <.icon name="check" />
      '''}
    >
      <div class="docs-row docs-icons">
        <span
          :for={
            n <-
              ~w(plus minus check x-mark chevron-down chevron-up chevron-left chevron-right arrow-right calendar-days clock magnifying-glass ellipsis-horizontal exclamation-circle)
          }
          class="docs-icon-cell"
        >
          <Icon.icon name={n} />
          <code>{n}</code>
        </span>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "state-glyph"} = assigns) do
    ~H"""
    <p>
      Status, priority, run, sync, and source sets for dense lists.
      <code>:selected_for_dev</code> draws the same empty ring as <code>:todo</code>.
    </p>
    <.demo_section
      title="Five sets"
      description="status / priority / run / sync / source side by side. Aliases (status_glyph, priority_glyph, …) take flicker-shaped assigns."
      code={~S'''
      <.status_glyph status={:in_progress} />
      <.priority_glyph priority={:high} />
      <.run_glyph state={:verifying} />
      <.sync_glyph state={:live} />
      <.source_glyph source={:repo} />
      '''}
    >
      <div class="docs-row docs-glyph-sets">
        <div class="docs-glyph-set">
          <code>status</code>
          <StateGlyph.status_glyph :for={s <- [:backlog, :todo, :in_progress, :done, :cancelled]} status={s} label={to_string(s)} />
        </div>
        <div class="docs-glyph-set">
          <code>priority</code>
          <StateGlyph.priority_glyph :for={p <- [:urgent, :high, :medium, :low, :none]} priority={p} label={to_string(p)} />
        </div>
        <div class="docs-glyph-set">
          <code>run</code>
          <StateGlyph.run_glyph
            :for={s <- [:queued, :claiming_env, :running, :verifying, :passed, :failed, :blocked]}
            state={s}
            label={to_string(s)}
          />
        </div>
        <div class="docs-glyph-set">
          <code>sync</code>
          <StateGlyph.sync_glyph :for={s <- [:empty, :syncing, :live, :failed]} state={s} label={to_string(s)} />
        </div>
        <div class="docs-glyph-set">
          <code>source</code>
          <StateGlyph.source_glyph :for={s <- [:repo, :doc, :ticket_memory, :upload]} source={s} label={to_string(s)} />
        </div>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "badge"} = assigns) do
    ~H"""
    <p>Status pills — colors × variants × sizes.</p>
    <.demo_section
      title="Colors"
      description="neutral, primary, accent, info, success, warning, danger."
      code={~S'''
      <.badge :for={c <- ~w(neutral primary accent success warning danger)} color={c}>
        {c}
      </.badge>
      '''}
    >
      <div class="docs-row">
        <Badge.badge :for={c <- ~w(neutral primary accent success warning danger)} color={c}>
          {c}
        </Badge.badge>
      </div>
    </.demo_section>
    <.demo_section
      title="Variants"
      description="soft (default), solid, and outline."
      code={~S'''
      <.badge :for={v <- ~w(soft solid outline)} variant={v} color="accent">{v}</.badge>
      '''}
    >
      <div class="docs-row">
        <Badge.badge :for={v <- ~w(soft solid outline)} variant={v} color="accent">
          {v}
        </Badge.badge>
      </div>
    </.demo_section>
    <.demo_section
      title="Sizes"
      description="sm, md (default), lg."
      code={~S'''
      <.badge size="sm" color="success">sm</.badge>
      <.badge size="md" color="success">md</.badge>
      <.badge size="lg" color="danger">lg</.badge>
      '''}
    >
      <div class="docs-row">
        <Badge.badge size="sm" color="success">sm</Badge.badge>
        <Badge.badge size="md" color="success">md</Badge.badge>
        <Badge.badge size="lg" color="danger">lg</Badge.badge>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "progress-meter"} = assigns) do
    ~H"""
    <p>Progress communicates task completion. Meter communicates a scalar measurement in a known range, with optional low, high, and optimum regions.</p>
    <.demo_section title="Task progress" description="Determinate and indeterminate progress use role=progressbar." code={~s"<.progress value={64} label=\"Upload\" /><.progress indeterminate label=\"Preparing\" />"}>
      <Progress.progress value={64} label="Upload" color="success" /><Progress.progress indeterminate label="Preparing" />
    </.demo_section>
    <.demo_section title="Measurements" description="Meter exposes min, max, value, and semantic range regions." code={~s"<.meter value={72} min={0} max={100} low={30} high={80} optimum={50} label=\"CPU load\" />"}>
      <Meter.meter value={72} min={0} max={100} low={30} high={80} optimum={50} label="CPU load" value_text="72 percent" />
    </.demo_section>
    <.demo_section
      title="Ring"
      description={~s(shape="ring" is an SVG completion circle. completed/scope is the flicker-shaped alias of value/max. The track uses --lantern-border-strong so 7/19 stays readable.)}
      code={~S'''
      <.progress shape="ring" value={7} max={19} label="Completion">7 / 19</.progress>
      <.progress shape="ring" completed={7} scope={19} size="sm" label="Progress" />
      '''}
    >
      <div class="docs-row">
        <Progress.progress shape="ring" value={7} max={19} label="Completion">
          7 / 19
        </Progress.progress>
        <Progress.progress shape="ring" completed={7} scope={19} size="sm" label="Progress" />
      </div>
    </.demo_section>
    """
  end
end
