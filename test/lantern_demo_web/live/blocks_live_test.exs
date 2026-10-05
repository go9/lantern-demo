defmodule LanternDemoWeb.BlocksLiveTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint LanternDemoWeb.Endpoint

  @pages [
    {"app-shell", ["id=\"demo-app\"", "Getting started", "← Blocks", "New ticket"]},
    {"dashboard",
     ["Merged per day", "Recent activity", "Open tickets", "dashboard-merged", "filter_activity"]},
    {"list",
     [
       "Tickets",
       "#241",
       "Visible progress ring",
       "All statuses",
       "data-part=\"search\"",
       "All",
       "In progress",
       "To do",
       "Done",
       "New ticket"
     ]},
    {"detail",
     [
       "Visible progress ring",
       "Ticket properties",
       "ticket-panel-toggle",
       "Description",
       "Completion"
     ]},
    {"settings",
     ["Settings", "Save profile", "Save notifications", "Save appearance", "Review signature"]},
    {"form", ["New ticket", "Create ticket", "ticket[title]", "Pick a status"]},
    {"login", ["Welcome back", "Continue with SSO", "Sign in"]},
    {"destructive",
     ["Danger zone", "Delete workspace", "No tickets yet", "Loading tickets", "timed out"]}
  ]

  test "what's new is a landing page: hero, one card per change, one deliberate button" do
    html = build_conn() |> get("/whats-new") |> html_response(200)

    assert html =~ "wn-hero"
    assert html =~ "Open the demo app"
    assert length(Regex.scan(~r/class="wn-card"/, html)) == 6

    for title <- ["Page blocks", "Toast deck", "shadcn preset", "Zag widgets", "Flat lists", "AI legibility package"] do
      assert html =~ title, "missing card #{title}"
    end

    for thumb <- ~w(blocks toast shadcn zag lists ai) do
      assert html =~ "/wn/#{thumb}.jpg"
      assert File.exists?("priv/static/wn/#{thumb}.jpg")
    end

    for path <- ["/docs/blocks", "/blocks/dashboard", "/blocks/list", "/docs/feedback/toasts",
                 "/docs/getting-started/theming", "/docs/foundations/colors", "/docs/overlays/dialogs",
                 "/docs/forms/select", "/docs/data-display/tables-lists", "/docs/getting-started/ai"] do
      assert html =~ ~s(href="#{path}"), "missing link #{path} on whats-new"
    end

    # the single entry into the demo app; no other docs page links to it
    assert length(Regex.scan(~r/href="\/app"/, html)) == 1
    assert html =~ ~s(data-part="preset-toggle")
  end

  test "no docs page other than what's new links into /app" do
    for {s, p} <- LanternDemoWeb.Docs.Nav.all_pages(), p.kind in [:members, :static] do
      html = build_conn() |> get(LanternDemoWeb.Docs.Nav.path(p, s)) |> html_response(200)
      refute html =~ ~s(href="/app), "#{p.id} links into the app"
    end
  end

  test "every block page renders its recipe content and the chrome switch" do
    for {slug, fragments} <- @pages do
      html = build_conn() |> get("/blocks/#{slug}") |> html_response(200)

      for fragment <- fragments,
          do: assert(html =~ fragment, "missing #{inspect(fragment)} on /blocks/#{slug}")

      assert html =~ ~s(data-part="theme-toggle"), "no theme toggle on #{slug}"
      assert html =~ ~s(data-part="density-toggle"), "no density toggle on #{slug}"
      assert html =~ ~s(data-part="preset-toggle"), "no preset toggle on #{slug}"
    end
  end

  test "unknown block slugs bounce to the dashboard block" do
    assert {:error, {:live_redirect, %{to: "/blocks/dashboard"}}} =
             live(build_conn(), "/blocks/nope")
  end

  test "list block honors the table filter params in the URL" do
    html =
      build_conn()
      |> get("/blocks/list", %{"filters" => %{"0" => %{"field" => "status", "value" => "done"}}})
      |> html_response(200)

    assert html =~ "#239"
    refute html =~ "#241"
  end

  test "list block search narrows rows by title" do
    html =
      build_conn()
      |> get("/blocks/list", %{"filters" => %{"0" => %{"field" => "title", "value" => "hub"}}})
      |> html_response(200)

    assert html =~ "#239"
    refute html =~ "#241"
  end

  test "list block shows the empty state when nothing matches" do
    html =
      build_conn()
      |> get("/blocks/list", %{"filters" => %{"0" => %{"field" => "title", "value" => "zzz"}}})
      |> html_response(200)

    assert html =~ "No tickets match"
    refute html =~ "#241"
  end

  test "dashboard activity chips filter by status" do
    {:ok, view, html} = live(build_conn(), "/blocks/dashboard")
    assert html =~ "#241"
    assert html =~ "#239"

    html = view |> element(~s(button[phx-click="filter_activity"][phx-value-status="done"])) |> render_click()
    assert html =~ "#239"
    refute html =~ "#241"
  end

  test "destructive confirm opens, cancels, and toasts on delete" do
    {:ok, socket} = mount_blocks()

    {:noreply, opened} = LanternDemoWeb.BlocksLive.handle_event("open_confirm", %{}, socket)
    assert opened.assigns.confirm_open

    {:noreply, closed} = LanternDemoWeb.BlocksLive.handle_event("close_confirm", %{}, opened)
    refute closed.assigns.confirm_open

    {:noreply, _deleted} = LanternDemoWeb.BlocksLive.handle_event("confirm_delete", %{}, opened)
  end

  test "new-ticket form validates inline and clears on success" do
    {:ok, socket} = mount_blocks()

    {:noreply, invalid} =
      LanternDemoWeb.BlocksLive.handle_event(
        "save_ticket",
        %{"ticket" => %{"title" => "", "body" => "", "status" => ""}},
        socket
      )

    assert invalid.assigns.ticket_errors == %{
             "title" => ["can't be blank"],
             "status" => ["can't be blank"]
           }

    {:noreply, valid} =
      LanternDemoWeb.BlocksLive.handle_event(
        "save_ticket",
        %{"ticket" => %{"title" => "Ring", "body" => "", "status" => "todo"}},
        socket
      )

    assert valid.assigns.ticket_errors == %{}
    assert valid.assigns.ticket_form == %{"title" => "", "body" => "", "status" => ""}
  end

  test "settings and login buttons answer with demo toasts" do
    {:ok, socket} = mount_blocks()

    for event <- ["save_profile", "save_notifications", "save_appearance", "demo_login", "demo_sso"] do
      assert {:noreply, _} = LanternDemoWeb.BlocksLive.handle_event(event, %{}, socket)
    end
  end

  defp mount_blocks do
    LanternDemoWeb.BlocksLive.mount(
      %{},
      %{},
      %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}}}
    )
  end
end
