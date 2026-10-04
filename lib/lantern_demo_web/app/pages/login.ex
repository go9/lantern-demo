defmodule LanternDemoWeb.App.Pages.Login do
  @moduledoc "Sign-in card (login block recipe), with validation and a demo-credentials hint."
  use Phoenix.Component
  use LanternUI

  alias DemoApp.Store
  alias LanternDemoWeb.App.Shell
  alias LanternUI.Components.Theme

  def mount_page(socket, _params) do
    Phoenix.Component.assign(socket,
      login_form: %{"email" => "", "password" => ""},
      login_errors: %{},
      login_failed: false
    )
  end

  def crumbs(_), do: [%{label: "Sign in", path: nil}]
  def actions(_), do: []

  def handle_event("login_change", %{"login" => params}, socket) do
    {:noreply, Phoenix.Component.assign(socket, login_form: params)}
  end

  def handle_event("fill_demo", _params, socket) do
    creds = Store.demo_credentials()

    {:noreply,
     Phoenix.Component.assign(socket,
       login_form: %{"email" => creds.email, "password" => creds.password},
       login_errors: %{},
       login_failed: false
     )}
  end

  def handle_event("login", %{"login" => %{"email" => email, "password" => pw} = params}, socket) do
    errors =
      %{}
      |> then(fn e ->
        if String.trim(email) == "", do: Map.put(e, "email", ["can't be blank"]), else: e
      end)
      |> then(fn e -> if pw == "", do: Map.put(e, "password", ["can't be blank"]), else: e end)

    if errors != %{} do
      {:noreply,
       Phoenix.Component.assign(socket,
         login_form: params,
         login_errors: errors,
         login_failed: false
       )}
    else
      case Store.sign_in(socket.assigns.sid, email, pw) do
        {:ok, member} ->
          {:noreply,
           socket
           |> Phoenix.LiveView.put_flash(:info, "Welcome back, #{hd(String.split(member.name))}.")
           |> Phoenix.LiveView.push_patch(to: "/app")}

        :error ->
          {:noreply,
           Phoenix.Component.assign(socket,
             login_form: params,
             login_errors: %{},
             login_failed: true
           )}
      end
    end
  end

  def handle_event("sso", _params, socket) do
    {:noreply,
     LanternUI.send_toast(socket, :info, "SSO isn't wired in this demo — use the demo account.",
       title: "Single sign-on"
     )}
  end

  def handle_event(_event, _params, _socket), do: :unhandled

  def render(assigns) do
    ~H"""
    <div class={["acme-auth", Shell.theme_class(@appearance)]} id="acme-auth">
      <Theme.theme preset={@appearance.preset} id="acme-theme" />
      <.toast_group id="acme-toasts" placement="bottom-right" flash={@flash} />
      <div class="acme-auth-card">
        <.card>
          <.stack gap="md">
            <div class="acme-auth-brand">
              <.icon name="sparkles" /> <span class="lui-brand-name">Acme</span>
            </div>
            <.page_header title="Welcome back" description="Sign in to your workspace." />
            <.alert :if={@login_failed} color="danger" title="Couldn't sign you in">
              That email and password don't match. Try the demo account below.
            </.alert>
            <form id="login-form" phx-change="login_change" phx-submit="login" class="acme-form">
              <.stack gap="md">
                <.input
                  id="login-email"
                  name="login[email]"
                  type="email"
                  label="Email"
                  placeholder="ada@acme.test"
                  autocomplete="email"
                  value={@login_form["email"]}
                  errors={Map.get(@login_errors, "email", [])}
                />
                <.input
                  id="login-password"
                  name="login[password]"
                  type="password"
                  label="Password"
                  autocomplete="current-password"
                  value={@login_form["password"]}
                  errors={Map.get(@login_errors, "password", [])}
                />
                <.button variant="solid" type="submit" class="acme-block-btn">Sign in</.button>
              </.stack>
            </form>
            <.separator />
            <.stack gap="sm">
              <.button variant="outline" type="button" phx-click="sso" class="acme-block-btn">
                Continue with SSO
              </.button>
              <.button variant="ghost" type="button" phx-click="fill_demo" class="acme-block-btn">
                Use the demo account
              </.button>
            </.stack>
          </.stack>
          <:footer>Demo credentials: ada@acme.test / lantern</:footer>
        </.card>
      </div>
    </div>
    """
  end
end
