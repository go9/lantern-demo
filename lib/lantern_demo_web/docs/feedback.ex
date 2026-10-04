defmodule LanternDemoWeb.Docs.Feedback do
  @moduledoc false
  use LanternDemoWeb.Docs.Section

  def member(%{member: "alert"} = assigns) do
    ~H"""
    <p>
      Inline status alerts — colors, optional close button, and hideable icon.
    </p>
    <.demo_section
      title="Colors"
      description="neutral, info, success, warning, danger — each with a default icon."
      code={~S'''
      <.alert color="neutral" title="Note">A neutral status message.</.alert>
      <.alert color="info" title="Info">Something you should know.</.alert>
      <.alert color="success" title="Saved">Your changes were stored.</.alert>
      <.alert color="warning" title="Careful">Review before continuing.</.alert>
      <.alert color="danger" title="Failed">The request could not be completed.</.alert>
      '''}
    >
      <Alert.alert color="neutral" title="Note">A neutral status message.</Alert.alert>
      <Alert.alert color="info" title="Info">Something you should know.</Alert.alert>
      <Alert.alert color="success" title="Saved">Your changes were stored.</Alert.alert>
      <Alert.alert color="warning" title="Careful">Review before continuing.</Alert.alert>
      <Alert.alert color="danger" title="Failed">The request could not be completed.</Alert.alert>
    </.demo_section>
    <.demo_section
      title="Title & close"
      description="hide_close={false} shows a dismiss button (JS.hide on the alert id)."
      code={~S'''
      <.alert id="alert-close" color="warning" title="Unsaved" hide_close={false}>
        Discard or save before leaving.
      </.alert>
      '''}
    >
      <Alert.alert id="alert-close" color="warning" title="Unsaved" hide_close={false}>
        Discard or save before leaving.
      </Alert.alert>
    </.demo_section>
    <.demo_section
      title="Hide icon"
      description="hide_icon removes the leading icon entirely."
      code={~S'''
      <.alert color="info" title="No icon" hide_icon>
        Icon hidden via hide_icon.
      </.alert>
      '''}
    >
      <Alert.alert color="info" title="No icon" hide_icon>
        Icon hidden via <code>hide_icon</code>.
      </Alert.alert>
    </.demo_section>
    <.demo_section
      title="Custom icon"
      description="Pass an :icon slot to replace the default glyph."
      code={~S'''
      <.alert color="info" title="Custom icon">
        <:icon><.icon name="sparkles" /></:icon>
        Using the icon slot.
      </.alert>
      '''}
    >
      <Alert.alert color="info" title="Custom icon">
        <:icon><Icon.icon name="sparkles" /></:icon>
        Using the <code>:icon</code> slot.
      </Alert.alert>
    </.demo_section>
    """
  end

  def member(%{member: "toast"} = assigns) do
    ~H"""
    <p>
      Stacked notifications via <code>toast_group</code> and
      <code>LanternUI.send_toast/4</code>. Fire one of each kind below.
    </p>
    <.demo_section
      title="Playground"
      description="Mount toast_group once, then send_toast from the LiveView."
      code={~S'''
      <Toast.toast_group id="demo-toasts" />

      <.button phx-click="demo_toast" phx-value-kind="info">Info</.button>
      <.button phx-click="demo_toast" phx-value-kind="success">Success</.button>
      <.button phx-click="demo_toast" phx-value-kind="warning">Warning</.button>
      <.button phx-click="demo_toast" phx-value-kind="danger">Danger</.button>
      '''}
    >
      <Toast.toast_group id="demo-toasts" placement={@toast_placement} flash={@flash} />
      <div class="docs-row">
        <Button.button phx-click="demo_toast" phx-value-kind="info">Info</Button.button>
        <Button.button phx-click="demo_toast" phx-value-kind="success" color="success">
          Success
        </Button.button>
        <Button.button phx-click="demo_toast" phx-value-kind="warning" color="warning">
          Warning
        </Button.button>
        <Button.button phx-click="demo_toast" phx-value-kind="danger" color="danger">
          Danger
        </Button.button>
      </div>
    </.demo_section>

    <.demo_section
      title="Stack, actions, flash"
      description="Fire several to see the collapsed deck; hover or tab into it to fan out and pause timers."
      code={~S'''
      <Toast.toast_group flash={@flash} max={3} />

      LanternUI.send_toast(socket, :success, "Saved", action: %{label: "Undo", event: "undo"})
      LanternUI.send_toast(socket, :info, "Sticky", duration: 0)
      '''}
    >
      <div class="docs-row">
        <Button.button phx-click="demo_toast_burst">Burst of 6</Button.button>
        <Button.button phx-click="demo_toast_action" variant="outline">With Undo action</Button.button>
        <Button.button phx-click="demo_toast_sticky" variant="outline">Sticky</Button.button>
        <Button.button phx-click="demo_toast_flash" variant="outline">put_flash info</Button.button>
        <Button.button phx-click="demo_toast_flash_error" variant="outline">put_flash error</Button.button>
        <Button.button phx-click="demo_toast_patch" variant="outline">Toast then re-render</Button.button>
      </div>
    </.demo_section>

    <.demo_section
      title="Placement"
      description="Any corner or edge-center. Pick one, then fire a toast — it enters from the nearest edge."
      code={~S'''
      <Toast.toast_group placement="bottom-center" />
      '''}
    >
      <div class="docs-row">
        <Button.button
          :for={p <- ~w(top-left top-center top-right bottom-left bottom-center bottom-right)}
          size="sm"
          variant={if @toast_placement == p, do: "solid", else: "outline"}
          phx-click="set_toast_placement"
          phx-value-placement={p}
        >
          {p}
        </Button.button>
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "loading"} = assigns) do
    ~H"""
    <p>
      Inline loading indicator — a rotating ring or three staggered dots
      (bounce/fade/scale), in five sizes. CSS-only, no JS. Mirrors Fluxon's
      <code>loading/1</code>.
    </p>
    <.demo_section
      title="Variants"
      description="ring plus the three dot styles."
      code={~S'''
      <.loading variant="ring" />
      <.loading variant="dots-bounce" />
      <.loading variant="dots-fade" />
      <.loading variant="dots-scale" />
      '''}
    >
      <div style="display:flex; align-items:center; gap:2rem;">
        <Loading.loading variant="ring" />
        <Loading.loading variant="dots-bounce" />
        <Loading.loading variant="dots-fade" />
        <Loading.loading variant="dots-scale" />
      </div>
    </.demo_section>
    <.demo_section
      title="Sizes"
      description="xs through xl scale ring diameter and dot size."
      code={~S'''
      <.loading size="xs" />
      <.loading size="sm" />
      <.loading size="md" />
      <.loading size="lg" />
      <.loading size="xl" />
      '''}
    >
      <div style="display:flex; align-items:center; gap:2rem;">
        <Loading.loading size="xs" />
        <Loading.loading size="sm" />
        <Loading.loading size="md" />
        <Loading.loading size="lg" />
        <Loading.loading size="xl" />
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "skeleton"} = assigns) do
    ~H"""
    <p>
      A decorative, dependency-free loading placeholder. Match the geometry of the
      content it replaces, hide the placeholder from assistive technology, and put
      <code>aria-busy="true"</code> plus an accessible label on the surrounding region.
      Animation is disabled automatically when reduced motion is requested.
    </p>
    <.demo_section
      title="Profile loading state"
      description="Compose the same primitive into avatar, title, metadata, and body shapes."
      code={~S'''
      <section aria-busy="true" aria-label="Loading profile">
        <.skeleton style="width: 3rem; height: 3rem; border-radius: 999px;" />
        <.skeleton style="width: 12rem; height: 1rem;" />
        <.skeleton style="width: 8rem; height: .75rem;" />
        <.skeleton style="height: 5rem;" />
      </section>
      '''}
    >
      <section class="docs-skeleton-card" aria-busy="true" aria-label="Loading profile">
        <Skeleton.skeleton class="docs-skeleton-avatar" />
        <div class="docs-skeleton-copy">
          <Skeleton.skeleton style="width: 12rem; height: 1rem;" />
          <Skeleton.skeleton style="width: 8rem; height: .75rem;" />
        </div>
        <Skeleton.skeleton class="docs-skeleton-block" />
      </section>
    </.demo_section>

    <.demo_section
      title="Inline geometry"
      description="class and style are intentionally the only geometry controls; content and timing remain caller-owned."
      code={~S'''
      <.skeleton />
      <.skeleton style="width: 65%;" />
      <.skeleton style="width: 35%; height: .75rem;" />
      '''}
    >
      <div class="docs-skeleton-lines" aria-busy="true" aria-label="Loading article summary">
        <Skeleton.skeleton />
        <Skeleton.skeleton style="width: 65%;" />
        <Skeleton.skeleton style="width: 35%; height: .75rem;" />
      </div>
    </.demo_section>
    """
  end

  def member(%{member: "empty-state"} = assigns) do
    ~H"""
    <p>Quiet zero states for tables, lists, and panels — a lantern-ui extension.</p>
    <.demo_section
      title="With actions"
      description="icon, title, body copy, and one or more :action slots."
      code={~S'''
      <.empty_state icon="folder-open" title="No objects">
        Drop files here to upload them, or create a folder to get organized.
        <:action><.button size="sm">Upload</.button></:action>
        <:action><.button size="sm" variant="ghost">New folder</.button></:action>
      </.empty_state>
      '''}
    >
      <EmptyState.empty_state icon="folder-open" title="No objects">
        Drop files here to upload them, or create a folder to get organized.
        <:action><Button.button size="sm">Upload</Button.button></:action>
        <:action><Button.button size="sm" variant="ghost">New folder</Button.button></:action>
      </EmptyState.empty_state>
    </.demo_section>
    """
  end
end
