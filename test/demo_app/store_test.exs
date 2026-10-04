defmodule DemoApp.StoreTest do
  use ExUnit.Case, async: true

  alias DemoApp.Store

  defp sid, do: "test-" <> Integer.to_string(System.unique_integer([:positive]))

  test "each session gets its own seeded copy" do
    a = sid()
    b = sid()
    assert length(Store.list_tickets(a)) == 10

    Store.delete_ticket(a, 241)
    assert length(Store.list_tickets(a)) == 9
    assert length(Store.list_tickets(b)) == 10
  end

  test "delete then restore round-trips a ticket" do
    s = sid()
    t = Store.delete_ticket(s, 240)
    assert t.id == 240
    assert Store.get_ticket(s, 240) == nil
    assert Store.restore_ticket(s, 240).id == 240
    assert Store.get_ticket(s, "240").title == t.title
  end

  test "sign in needs a known member and the demo password" do
    s = sid()
    refute Store.signed_in?(s)
    assert Store.sign_in(s, "ada@acme.test", "nope") == :error
    assert Store.sign_in(s, "nobody@acme.test", "lantern") == :error
    assert {:ok, %{name: "Ada Lovelace"}} = Store.sign_in(s, " ADA@acme.test ", "lantern")
    assert Store.signed_in?(s)
    Store.sign_out(s)
    refute Store.signed_in?(s)
  end

  test "reset! reseeds data but keeps the sign-in" do
    s = sid()
    Store.sign_in(s, "ada@acme.test", "lantern")
    Store.delete_ticket(s, 241)
    Store.update_appearance(s, %{theme: "dark"})
    Store.reset!(s)
    assert Store.get_ticket(s, 241)
    assert Store.signed_in?(s)
    assert Store.get_settings(s).appearance.theme == "system"
  end

  test "counts, comments, status changes and invites" do
    s = sid()
    assert %{all: 10, todo: 4, in_progress: 3, done: 3} = Store.counts(s)

    Store.update_ticket(s, 240, %{status: :done, note: "Status changed to Done"})
    assert Store.counts(s).done == 4
    assert hd(Store.get_ticket(s, 240).activity).text == "Status changed to Done"

    Store.add_comment(s, 240, %{author: "Ada Lovelace", body: "Nice."})
    assert [%{body: "Nice.", initials: "AL"}] = Store.get_ticket(s, 240).comments

    assert {:ok, _} = Store.invite_member(s, %{name: "Margaret H", email: "m@acme.test", role: "member"})
    assert {:error, :taken} = Store.invite_member(s, %{name: "Margaret H", email: "m@acme.test", role: "member"})
    assert Store.remove_member(s, "m@acme.test").name == "Margaret H"
  end

  test "creating tickets and projects assigns ids" do
    s = sid()
    t = Store.create_ticket(s, %{title: "New one"})
    assert t.id == 242 and t.identifier == "#242"
    p = Store.create_project(s, %{name: "Mobile", summary: ""})
    assert p.id == 4
    assert Enum.any?(Store.project_tickets(s, 1), &(&1.project_id == 1))
  end
end
