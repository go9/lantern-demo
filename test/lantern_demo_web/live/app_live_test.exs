defmodule LanternDemoWeb.AppLiveTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias DemoApp.Store

  @endpoint LanternDemoWeb.Endpoint

  defp new_sid, do: "t-" <> Integer.to_string(System.unique_integer([:positive]))

  defp conn_for(sid), do: build_conn() |> Plug.Test.init_test_session(%{"app_sid" => sid})

  # Signed-in connection with its own store copy.
  defp signed_in do
    sid = new_sid()
    {:ok, _} = Store.sign_in(sid, "ada@acme.test", "lantern")
    {sid, conn_for(sid)}
  end

  defp page(path) do
    {sid, conn} = signed_in()
    {:ok, view, html} = live(conn, path)
    {sid, view, html}
  end

  describe "auth" do
    test "signed-out visitors land on the login card" do
      assert {:error, {:live_redirect, %{to: "/app/login"}}} = live(conn_for(new_sid()), "/app")
      {:ok, view, html} = live(conn_for(new_sid()), "/app/login")
      assert html =~ "Welcome back"
      assert html =~ "ada@acme.test / lantern"

      html = render_submit(view, "login", %{"login" => %{"email" => "", "password" => ""}})
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"

      html = render_submit(view, "login", %{"login" => %{"email" => "ada@acme.test", "password" => "wrong"}})
      assert html =~ "don&#39;t match" or html =~ "don't match"

      render_submit(view, "login", %{"login" => %{"email" => "ada@acme.test", "password" => "lantern"}})
      assert_patch(view, "/app")
      assert render(view) =~ "Open tickets"
    end

    test "signing out returns to login, and a signed-in visitor skips login" do
      {_sid, view, _} = page("/app")
      render_click(view, "sign_out", %{})
      assert_patch(view, "/app/login")

      {_sid, conn} = signed_in()
      assert {:error, {:live_redirect, %{to: "/app"}}} = live(conn, "/app/login")
    end
  end

  describe "pages render inside the Acme shell, never linking into the docs" do
    for path <- ~w(/app /app/tickets /app/tickets/241 /app/tickets/new /app/tickets/241/edit /app/projects /app/projects/1 /app/team /app/settings /app/notifications /app/nope) do
      test "GET #{path}" do
        {_sid, _view, html} = page(unquote(path))
        assert html =~ ~s(id="acme-shell")
        assert html =~ "Acme"
        assert html =~ ~s(id="acme-palette")
        refute html =~ ~s(href="/docs/)
        refute html =~ ~s(href="/docs")
        refute html =~ ~s(href="/whats-new)
        refute html =~ ~s(href="/components)
        refute html =~ ~s(id="lantern-demo-shell")
      end
    end

    test "title and actions live in the breadcrumb bar, with no tabs or group bands" do
      {_sid, _view, html} = page("/app/tickets")
      assert html =~ "lui-app-breadcrumb"
      assert html =~ "New ticket"
      refute html =~ "lui-group-band"
      # the only tablist is the data_table's own filter-chip row; no tab panels anywhere
      refute html =~ ~s(role="tabpanel")
      assert length(Regex.scan(~r/role="tablist"/, html)) <= 1
    end
  end

  describe "tickets list" do
    test "status chips carry counts and filter through the URL" do
      {_sid, view, html} = page("/app/tickets")
      assert html =~ "In progress"
      assert length(Regex.scan(~r/<tr class="lui-tr/, html)) == 8

      html = render(view |> live_patch_to("/app/tickets?filters[0][field]=status&filters[0][value]=in_progress"))
      assert length(Regex.scan(~r/<tr class="lui-tr/, html)) == 3
    end

    test "search, sort and pagination are read from the URL" do
      {_sid, view, _} = page("/app/tickets")

      html = render(live_patch_to(view, "/app/tickets?filters[0][field]=title&filters[0][op]=ilike&filters[0][value]=sso"))
      assert html =~ "SSO sign-in loop"
      assert length(Regex.scan(~r/<tr class="lui-tr/, html)) == 1

      html = render(live_patch_to(view, "/app/tickets?order_by[]=title&order_directions[]=asc"))
      [first | _] = Regex.scan(~r/acme-rowtitle">([^<]+)</, html, capture: :all_but_first) |> List.flatten()
      assert first == "Bulk triage actions"

      html = render(live_patch_to(view, "/app/tickets?page=2"))
      assert length(Regex.scan(~r/<tr class="lui-tr/, html)) == 2
    end

    test "whole rows link to the ticket (row_navigate)" do
      {_sid, _view, html} = page("/app/tickets")
      assert html =~ ~s(href="/app/tickets/241")
      assert html =~ "lui-row-link"
    end

    test "simulated loading, error and empty states" do
      {_sid, _view, html} = page("/app/tickets?state=loading")
      assert html =~ ~s(aria-busy="true")
      {_sid, _view, html} = page("/app/tickets?state=error")
      assert html =~ "Couldn&#39;t load tickets" or html =~ "Couldn't load tickets"
      {_sid, _view, html} = page("/app/tickets?state=empty")
      assert html =~ "No tickets yet"
    end

    test "a search with no hits shows the empty state with a way out" do
      {_sid, view, _} = page("/app/tickets")
      html = render(live_patch_to(view, "/app/tickets?filters[0][field]=title&filters[0][op]=ilike&filters[0][value]=zzzz"))
      assert html =~ "No tickets match"
      assert html =~ "Clear filters"
    end
  end

  describe "ticket detail" do
    test "status, priority and assignee selects write through and log activity" do
      {sid, view, _} = page("/app/tickets/241")

      render_hook(view, "set_field", %{"id" => "ticket-status-select", "value" => ["done"]})
      assert Store.get_ticket(sid, 241).status == :done
      assert render(view) =~ "Status changed to Done"

      render_hook(view, "set_field", %{"id" => "ticket-priority-select", "value" => ["urgent"]})
      assert Store.get_ticket(sid, 241).priority == :urgent

      render_hook(view, "set_field", %{"id" => "ticket-assignee-select", "value" => ["grace@acme.test"]})
      assert Store.get_ticket(sid, 241).assignee == "grace@acme.test"
    end

    test "comments validate and post" do
      {sid, view, _} = page("/app/tickets/241")
      html = render_submit(view, "add_comment", %{"comment" => %{"body" => "   "}})
      assert html =~ "Write something first"

      html = render_submit(view, "add_comment", %{"comment" => %{"body" => "Looks good"}})
      assert html =~ "Looks good"
      assert length(Store.get_ticket(sid, 241).comments) == 3
    end

    test "delete returns to the list and undo restores" do
      {sid, view, _} = page("/app/tickets/241")
      render_click(view, "delete_ticket", %{})
      assert_patch(view, "/app/tickets")
      assert Store.get_ticket(sid, 241) == nil

      render_click(view, "undo", %{})
      assert Store.get_ticket(sid, 241)
    end

    test "unknown ticket shows not-found inside the shell" do
      {_sid, _view, html} = page("/app/tickets/9999")
      assert html =~ "Ticket not found"
    end
  end

  describe "ticket form" do
    test "validates, then creates and opens the new ticket" do
      {sid, view, _} = page("/app/tickets/new")

      html = render_submit(view, "save", %{"ticket" => form(%{"title" => ""})})
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
      html = render_submit(view, "save", %{"ticket" => form(%{"title" => "ab"})})
      assert html =~ "too short"

      render_submit(view, "save", %{"ticket" => form(%{"title" => "Brand new ticket"})})
      assert_patch(view, "/app/tickets/242")
      assert Store.get_ticket(sid, 242).title == "Brand new ticket"
    end

    test "edit saves changes" do
      {sid, view, _} = page("/app/tickets/240/edit")
      render_submit(view, "save", %{"ticket" => form(%{"title" => "Renamed primitives", "status" => "done"})})
      assert_patch(view, "/app/tickets/240")
      assert %{title: "Renamed primitives", status: :done} = Store.get_ticket(sid, 240)
    end
  end

  describe "projects" do
    test "table rows link to project pages; project page filters its flat list" do
      {_sid, view, html} = page("/app/projects")
      assert html =~ ~s(href="/app/projects/1")
      assert html =~ "lantern-ui"
      refute html =~ "lui-group-band"

      render_click(view, "open_new_project", %{})
      assert render(view) =~ "data-open"

      {_sid, view, html} = page("/app/projects/1")
      assert html =~ "Visible progress ring"
      html = render_click(view, "project_filter", %{"status" => "done"})
      assert html =~ "No tickets here"
    end

    test "creating a project through the dialog" do
      {sid, view, _} = page("/app/projects")
      render_click(view, "open_new_project", %{})
      render_hook(view, "create_project", %{"name" => "Mobile", "summary" => "iOS"})
      assert Enum.any?(Store.list_projects(sid), &(&1.name == "Mobile"))
      assert render(view) =~ "Mobile"

      # duplicate names are refused
      render_hook(view, "create_project", %{"name" => "mobile", "summary" => ""})
      assert length(Store.list_projects(sid)) == 4
    end
  end

  describe "team" do
    test "invite, role change, remove and undo" do
      {sid, view, html} = page("/app/team")
      assert html =~ "Barbara Liskov"

      render_hook(view, "send_invite", %{"name" => "Margaret", "email" => "nope", "role" => "member"})
      assert length(Store.list_members(sid)) == 4

      render_hook(view, "send_invite", %{"name" => "Margaret", "email" => "grace@acme.test", "role" => "member"})
      assert length(Store.list_members(sid)) == 4

      render_hook(view, "send_invite", %{"name" => "Margaret", "email" => "m@acme.test", "role" => "viewer"})
      assert Enum.any?(Store.list_members(sid), &(&1.email == "m@acme.test" and &1.role == "viewer"))

      render_hook(view, "set_role", %{"id" => "role-2-select", "value" => ["admin"]})
      assert Enum.find(Store.list_members(sid), &(&1.email == "alan@acme.test")).role == "admin"

      render_click(view, "remove_member", %{"email" => "m@acme.test"})
      assert length(Store.list_members(sid)) == 4
      render_click(view, "undo", %{})
      assert length(Store.list_members(sid)) == 5
    end
  end

  describe "notifications" do
    test "filter, mark all read, clear and undo" do
      {sid, view, html} = page("/app/notifications")
      assert html =~ "Grace mentioned you"

      html = render_click(view, "n_filter", %{"f" => "unread"})
      refute html =~ "Weekly digest is live"

      render_click(view, "mark_all_read", %{})
      assert Store.unread_count(sid) == 0

      render_click(view, "clear_all", %{})
      assert Store.list_notifications(sid) == []
      assert render(view) =~ "Nothing here"
      render_click(view, "undo", %{})
      assert length(Store.list_notifications(sid)) == 6
    end

    test "opening a notification marks it read" do
      {sid, view, _} = page("/app/notifications")
      render_click(view, "open_note", %{"id" => "1"})
      assert Store.unread_count(sid) == 2
    end
  end

  describe "settings" do
    test "profile validates and saves" do
      {sid, view, _} = page("/app/settings")
      html = render_submit(view, "save_profile", %{"profile" => %{"name" => "", "email" => "bad", "signature" => ""}})
      assert html =~ "must be a valid email"

      render_submit(view, "save_profile", %{"profile" => %{"name" => "Ada L", "email" => "ada@acme.test", "signature" => "Ship."}})
      assert Store.get_settings(sid).name == "Ada L"
    end

    test "notification switches persist" do
      {sid, view, _} = page("/app/settings")
      render_change(view, "save_prefs", %{"prefs" => %{"mentions" => "false", "review_requests" => "true", "weekly_digest" => "true"}})
      assert %{mentions: false, review_requests: true, weekly_digest: true} = Store.get_settings(sid).prefs
    end

    test "appearance applies to the shell: dark theme and the shadcn preset" do
      {sid, view, _} = page("/app/settings")
      render_hook(view, "set_theme", %{"id" => "appearance-theme-select", "value" => ["dark"]})
      assert render(view) =~ ~r/id="acme-shell"[^>]*class="[^"]*dark/ or render(view) =~ ~r/class="[^"]*dark[^"]*"[^>]*id="acme-shell"/

      render_hook(view, "set_preset", %{"id" => "appearance-preset-switch", "checked" => true, "value" => true})
      assert Store.get_settings(sid).appearance.preset == "shadcn"
      assert render(view) =~ ~s(data-preset="shadcn")

      render_hook(view, "set_density", %{"id" => "appearance-density-select", "value" => ["comfortable"]})
      assert render(view) =~ ~s(data-lantern-density="comfortable")
    end

    test "the danger zone resets the workspace" do
      {sid, view, _} = page("/app/settings")
      Store.delete_ticket(sid, 241)
      render_click(view, "confirm_reset", %{})
      assert_patch(view, "/app")
      assert Store.get_ticket(sid, 241)
    end
  end

  describe "hostile client input" do
    test "garbage select values and ids never crash the view" do
      {sid, view, _} = page("/app/tickets/241")
      render_hook(view, "set_field", %{"id" => "ticket-status-select", "value" => ["not-a-status"]})
      render_hook(view, "set_field", %{"id" => "ticket-priority-select", "value" => ["x"]})
      render_hook(view, "set_field", %{"id" => "ticket-assignee-select", "value" => ["nobody@x.test"]})
      assert %{status: :in_progress, priority: :high, assignee: "ada@acme.test"} = Store.get_ticket(sid, 241)

      {_sid, team, _} = page("/app/team")
      render_hook(team, "set_role", %{"id" => "role-zz-select", "value" => ["admin"]})
      render_hook(team, "set_role", %{"id" => "role-9-select", "value" => ["admin"]})
      render_hook(team, "set_role", %{"id" => "role-1-select", "value" => ["superuser"]})
      assert render(team) =~ "Grace Hopper"

      {_sid, notes, _} = page("/app/notifications")
      render_click(notes, "open_note", %{"id" => "abc"})
      assert render(notes) =~ "Inbox"
    end

    test "the demo workspace is capped" do
      sid = new_sid()
      for i <- 1..400, do: Store.create_ticket(sid, %{title: "t#{i}"})
      assert length(Store.list_tickets(sid)) == 300
      assert Store.create_ticket(sid, %{title: "one more"}) == nil
    end
  end

  describe "command palette" do
    test "searches tickets and navigates" do
      {_sid, view, _} = page("/app")
      html = render_hook(view, "palette_search", %{"query" => "sso"})
      assert html =~ "SSO sign-in loop"

      render_hook(view, "palette_select", %{"value" => "ticket:235"})
      assert_patch(view, "/app/tickets/235")

      render_hook(view, "palette_select", %{"value" => "go:/app/team"})
      assert_patch(view, "/app/team")

      render_hook(view, "palette_select", %{"value" => "act:error"})
      assert_patch(view, "/app/tickets?state=error")
    end

    test "empty query lists navigation and actions" do
      {_sid, view, _} = page("/app")
      html = render_hook(view, "palette_search", %{"query" => ""})
      assert html =~ "Go to Tickets"
      assert html =~ "Toggle dark mode"
      html = render_hook(view, "palette_search", %{"query" => "qqqq"})
      assert html =~ "Nothing matches"
    end
  end

  defp form(overrides) do
    Map.merge(
      %{
        "title" => "A title",
        "body" => "",
        "status" => "todo",
        "priority" => "medium",
        "assignee" => "ada@acme.test",
        "project_id" => "1",
        "tag" => "ui"
      },
      overrides
    )
  end

  defp live_patch_to(view, path) do
    Phoenix.LiveViewTest.render_patch(view, path)
    view
  end
end
