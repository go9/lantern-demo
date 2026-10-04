defmodule LanternDemoWeb.App.Pages.Settings do
  @moduledoc """
  Settings (settings recipe — separate cards, no tabs): profile with validation,
  notification switches, appearance (theme, density, shadcn preset) that applies
  live, and a danger zone behind a confirm dialog.
  """
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store

  def mount_page(socket, _params) do
    s = socket.assigns.settings

    Phoenix.Component.assign(socket,
      profile_form: %{"name" => s.name, "email" => s.email, "signature" => s.signature},
      profile_errors: %{}
    )
  end

  def crumbs(_), do: [%{label: "Acme", path: "/app"}, %{label: "Settings", path: nil}]
  def actions(_), do: []

  # ── profile ──

  def handle_event("profile_change", %{"profile" => p}, socket) do
    {:noreply,
     Phoenix.Component.assign(socket, profile_form: Map.merge(socket.assigns.profile_form, p))}
  end

  def handle_event("save_profile", %{"profile" => p}, socket) do
    name = String.trim(p["name"])
    email = String.trim(p["email"])

    errors =
      %{}
      |> then(fn e -> if name == "", do: Map.put(e, "name", ["can't be blank"]), else: e end)
      |> then(fn e ->
        if Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email),
          do: e,
          else: Map.put(e, "email", ["must be a valid email"])
      end)

    if errors == %{} do
      Store.update_settings(socket.assigns.sid, %{
        name: name,
        email: email,
        signature: p["signature"]
      })

      {:noreply,
       socket
       |> Phoenix.Component.assign(
         profile_form: %{p | "name" => name, "email" => email},
         profile_errors: %{}
       )
       |> LanternDemoWeb.AppLive.toast(:success, "Your profile was saved.",
         title: "Profile saved"
       )}
    else
      {:noreply, Phoenix.Component.assign(socket, profile_form: p, profile_errors: errors)}
    end
  end

  # ── notifications ──

  def handle_event("save_prefs", %{"prefs" => p}, socket) do
    prefs = %{
      mentions: p["mentions"] == "true",
      review_requests: p["review_requests"] == "true",
      weekly_digest: p["weekly_digest"] == "true"
    }

    if prefs == socket.assigns.settings.prefs do
      {:noreply, socket}
    else
      Store.update_prefs(socket.assigns.sid, prefs)

      {:noreply,
       LanternDemoWeb.AppLive.toast(socket, :success, "Notification preferences saved.",
         title: "Saved"
       )}
    end
  end

  # ── appearance ──

  def handle_event("set_theme", params, socket) do
    value = LanternDemoWeb.App.Helpers.pick(params)
    appearance(socket, %{theme: value}, "Theme set to #{value}.")
  end

  def handle_event("set_density", params, socket) do
    value = LanternDemoWeb.App.Helpers.pick(params)
    appearance(socket, %{density: value}, "Density set to #{value}.")
  end

  def handle_event("set_preset", %{"checked" => on?}, socket) do
    if on?,
      do: appearance(socket, %{preset: "shadcn"}, "shadcn preset on."),
      else: appearance(socket, %{preset: nil}, "Default preset on.")
  end

  # ── danger zone ──

  def handle_event("confirm_reset", _params, socket) do
    Store.reset!(socket.assigns.sid)

    {:noreply,
     socket
     |> LanternUI.close_dialog("reset-dialog")
     |> LanternDemoWeb.AppLive.toast(
       :success,
       "Tickets, projects and the team are back to the seed data.", title: "Workspace reset")
     |> Phoenix.LiveView.push_patch(to: "/app")}
  end

  def handle_event(_, _, _), do: :unhandled

  defp appearance(socket, patch, message) do
    Store.update_appearance(socket.assigns.sid, patch)
    {:noreply, LanternDemoWeb.AppLive.toast(socket, :success, message, title: "Appearance")}
  end

  def render(assigns) do
    ~H"""
    <div class="acme-narrow">
      <.stack gap="lg">
        <.card title="Profile" description="How your name appears on tickets and reviews.">
          <form id="profile-form" phx-change="profile_change" phx-submit="save_profile" class="acme-form" novalidate>
            <.stack gap="md">
              <.input id="settings-name" name="profile[name]" label="Display name" value={@profile_form["name"]} errors={Map.get(@profile_errors, "name", [])} />
              <.input id="settings-email" name="profile[email]" type="email" label="Email" value={@profile_form["email"]} help_text="Receipts and review requests land here." errors={Map.get(@profile_errors, "email", [])} />
              <.textarea id="settings-signature" name="profile[signature]" label="Review signature" rows={2} value={@profile_form["signature"]} help_text="Appended to approvals you write." />
            </.stack>
          </form>
          <:footer>
            <span class="acme-muted">Visible to your team</span>
            <.button size="sm" variant="solid" type="submit" form="profile-form">Save profile</.button>
          </:footer>
        </.card>

        <.card title="Notifications" description="Pick which pings are worth interrupting you. Saved as you flip them.">
          <form id="prefs-form" phx-change="save_prefs">
            <.stack gap="md">
              <.switch id="pref-mentions" name="prefs[mentions]" label="Mentions" description="When someone @-mentions you." checked={@settings.prefs.mentions} />
              <.switch id="pref-reviews" name="prefs[review_requests]" label="Review requests" description="When you're asked to review a ticket." checked={@settings.prefs.review_requests} />
              <.switch id="pref-digest" name="prefs[weekly_digest]" label="Weekly digest" description="A Monday summary of your open tickets." checked={@settings.prefs.weekly_digest} />
            </.stack>
          </form>
        </.card>

        <.card title="Appearance" description="Applies instantly, for you only.">
          <.stack gap="md">
            <.select
              id="appearance-theme"
              name="theme"
              label="Theme"
              controlled
              on_change="set_theme"
              value={@appearance.theme}
              options={[{"System", "system"}, {"Light", "light"}, {"Dark", "dark"}]}
            />
            <.select
              id="appearance-density"
              name="density"
              label="Density"
              controlled
              on_change="set_density"
              value={@appearance.density}
              options={[{"Compact", "compact"}, {"Comfortable", "comfortable"}]}
            />
            <.switch
              id="appearance-preset"
              name="preset"
              label="shadcn preset"
              description="Swap lantern's tokens onto shadcn's neutral palette and proportions."
              checked={@appearance.preset == "shadcn"}
              checked_value="shadcn"
              unchecked_value="default"
              controlled
              on_change="set_preset"
            />
          </.stack>
        </.card>

        <.card title="Danger zone" description="These actions can't be taken back.">
          <div class="acme-danger">
            <div>
              <strong>Reset workspace data</strong>
              <p class="acme-muted">Restores the seed tickets, projects, team and notifications. Your sign-in stays.</p>
            </div>
            <.button variant="solid" color="danger" size="sm" phx-click={LanternUI.open_dialog("reset-dialog")}>Reset workspace…</.button>
          </div>
        </.card>
      </.stack>
    </div>

    <.alert_dialog id="reset-dialog">
      <:title>Reset this workspace?</:title>
      <:description>
        Every ticket, project, comment and team change you made is replaced with the seed data. This can't be undone.
      </:description>
      <:cancel><.button variant="outline" phx-click={LanternUI.close_dialog("reset-dialog")}>Cancel</.button></:cancel>
      <:action><.button variant="solid" color="danger" phx-click="confirm_reset">Reset workspace</.button></:action>
    </.alert_dialog>
    """
  end
end
