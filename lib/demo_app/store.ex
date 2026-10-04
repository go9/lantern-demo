defmodule DemoApp.Store do
  @moduledoc """
  Seeded in-memory store for the /app demo (Acme). An Agent holding plain
  maps — everything persists while the server runs, nothing touches Postgres.
  `reset!/0` reseeds (used by tests and the settings danger zone).
  """
  use Agent

  @statuses ~w(todo in_progress done)
  @priorities ~w(low medium high urgent)

  def start_link(_opts) do
    Agent.start_link(fn -> seed() end, name: __MODULE__)
  end

  def reset! do
    Agent.update(__MODULE__, fn _ -> seed() end)
  end

  # ── tickets ──

  def list_tickets, do: Agent.get(__MODULE__, & &1.tickets)

  def get_ticket(id) when is_integer(id) do
    Agent.get(__MODULE__, fn s -> Enum.find(s.tickets, &(&1.id == id)) end)
  end

  def get_ticket(id) when is_binary(id) do
    case Integer.parse(id) do
      {n, _} -> get_ticket(n)
      :error -> nil
    end
  end

  def counts do
    tickets = list_tickets()

    %{
      all: length(tickets),
      todo: Enum.count(tickets, &(&1.status == :todo)),
      in_progress: Enum.count(tickets, &(&1.status == :in_progress)),
      done: Enum.count(tickets, &(&1.status == :done))
    }
  end

  def create_ticket(attrs) do
    Agent.get_and_update(__MODULE__, fn s ->
      id = s.seq.ticket + 1
      now = Date.utc_today()

      ticket = %{
        id: id,
        identifier: "##{id}",
        title: attrs.title,
        body: Map.get(attrs, :body, ""),
        status: Map.get(attrs, :status, :todo),
        priority: Map.get(attrs, :priority, :medium),
        tag: Map.get(attrs, :tag, "ui"),
        assignee: Map.get(attrs, :assignee, "ada@acme.test"),
        project_id: Map.get(attrs, :project_id, 1),
        date: now,
        comments: [],
        activity: [%{text: "Ticket created", at: "just now"}]
      }

      {%{ticket: ticket}, %{s | tickets: [ticket | s.tickets], seq: %{s.seq | ticket: id}}}
    end)
  end

  def update_ticket(id, attrs) do
    Agent.get_and_update(__MODULE__, fn s ->
      {found, rest} = Enum.split_with(s.tickets, &(&1.id == id))

      case found do
        [ticket] ->
          updated =
            ticket
            |> Map.merge(Map.take(attrs, [:title, :body, :status, :priority, :tag, :assignee, :project_id]))
            |> touch(Map.get(attrs, :note, "Ticket updated"))

          {updated, %{s | tickets: [updated | rest]}}

        [] ->
          {nil, s}
      end
    end)
  end

  def delete_ticket(id) do
    Agent.get_and_update(__MODULE__, fn s ->
      {found, rest} = Enum.split_with(s.tickets, &(&1.id == id))

      case found do
        [ticket] -> {ticket, %{s | tickets: rest, trash: [ticket | s.trash]}}
        [] -> {nil, s}
      end
    end)
  end

  def restore_ticket(id) do
    Agent.get_and_update(__MODULE__, fn s ->
      {found, trash} = Enum.split_with(s.trash, &(&1.id == id))

      case found do
        [ticket] -> {ticket, %{s | tickets: [ticket | s.tickets], trash: trash}}
        [] -> {nil, s}
      end
    end)
  end

  def add_comment(id, %{author: author, body: body}) do
    Agent.get_and_update(__MODULE__, fn s ->
      {found, rest} = Enum.split_with(s.tickets, &(&1.id == id))

      case found do
        [ticket] ->
          comment = %{author: author, initials: initials(author), body: body, at: "just now"}

          updated =
            ticket
            |> Map.update!(:comments, &(&1 ++ [comment]))
            |> touch("Comment added")

          {comment, %{s | tickets: [updated | rest]}}

        [] ->
          {nil, s}
      end
    end)
  end

  defp touch(ticket, text) do
    Map.update!(ticket, :activity, &[%{text: text, at: "just now"} | &1])
  end

  # ── projects ──

  def list_projects, do: Agent.get(__MODULE__, & &1.projects)

  def get_project(id) when is_integer(id) do
    Agent.get(__MODULE__, fn s -> Enum.find(s.projects, &(&1.id == id)) end)
  end

  def get_project(id) when is_binary(id) do
    case Integer.parse(id) do
      {n, _} -> get_project(n)
      :error -> nil
    end
  end

  def project_tickets(project_id) do
    Agent.get(__MODULE__, fn s -> Enum.filter(s.tickets, &(&1.project_id == project_id)) end)
  end

  # ── members ──

  def list_members, do: Agent.get(__MODULE__, & &1.members)

  def update_member_role(email, role) do
    Agent.update(__MODULE__, fn s ->
      members = Enum.map(s.members, fn m -> if m.email == email, do: %{m | role: role}, else: m end)
      %{s | members: members}
    end)
  end

  def invite_member(%{name: name, email: email, role: role}) do
    Agent.get_and_update(__MODULE__, fn s ->
      if Enum.any?(s.members, &(&1.email == email)) do
        {{:error, :taken}, s}
      else
        member = %{name: name, email: email, role: role, initials: initials(name)}
        {{:ok, member}, %{s | members: s.members ++ [member]}}
      end
    end)
  end

  def member_name(email) do
    Agent.get(__MODULE__, fn s ->
      case Enum.find(s.members, &(&1.email == email)) do
        nil -> email
        m -> m.name
      end
    end)
  end

  # ── notifications ──

  def list_notifications, do: Agent.get(__MODULE__, & &1.notifications)

  def unread_count do
    Agent.get(__MODULE__, fn s -> Enum.count(s.notifications, &(!&1.read)) end)
  end

  def mark_read(id) do
    Agent.update(__MODULE__, fn s ->
      notes = Enum.map(s.notifications, fn n -> if n.id == id, do: %{n | read: true}, else: n end)
      %{s | notifications: notes}
    end)
  end

  def mark_all_read do
    Agent.update(__MODULE__, fn s ->
      %{s | notifications: Enum.map(s.notifications, &%{&1 | read: true})}
    end)
  end

  # ── settings ──

  def get_settings, do: Agent.get(__MODULE__, & &1.settings)

  def update_settings(patch) do
    Agent.update(__MODULE__, fn s -> %{s | settings: Map.merge(s.settings, patch)} end)
  end

  def update_prefs(patch) do
    Agent.update(__MODULE__, fn s ->
      %{s | settings: %{s.settings | prefs: Map.merge(s.settings.prefs, patch)}}
    end)
  end

  def statuses, do: @statuses
  def priorities, do: @priorities

  # ── seed ──

  defp initials(name) do
    name |> String.split() |> Enum.map(&String.first/1) |> Enum.join() |> String.upcase()
  end

  defp seed do
    members = [
      %{name: "Ada Lovelace", email: "ada@acme.test", role: "admin", initials: "AL"},
      %{name: "Grace Hopper", email: "grace@acme.test", role: "admin", initials: "GH"},
      %{name: "Alan Turing", email: "alan@acme.test", role: "member", initials: "AT"},
      %{name: "Barbara Liskov", email: "barbara@acme.test", role: "viewer", initials: "BL"}
    ]

    tickets = [
      %{
        id: 241,
        identifier: "#241",
        title: "Visible progress ring",
        body: "Extract the ring from flicker so 7/19 stays visible on the hub.",
        status: :in_progress,
        priority: :high,
        tag: "ui",
        assignee: "ada@acme.test",
        project_id: 1,
        date: ~D[2026-10-02],
        comments: [
          %{author: "Grace Hopper", initials: "GH", body: "Ring renders in the list row now — check the hub next.", at: "3h ago"},
          %{author: "Ada Lovelace", initials: "AL", body: "Hub updated. 7/19 visible at a glance.", at: "1h ago"}
        ],
        activity: [
          %{text: "Grace Hopper commented", at: "3h ago"},
          %{text: "Status changed to In progress", at: "5h ago"},
          %{text: "Ticket created", at: "2d ago"}
        ]
      },
      %{
        id: 240,
        identifier: "#240",
        title: "Extract eight primitives",
        body: "Pull the dense primitives out of the app shell into lantern-ui.",
        status: :todo,
        priority: :medium,
        tag: "hex",
        assignee: "alan@acme.test",
        project_id: 1,
        date: ~D[2026-10-01],
        comments: [],
        activity: [%{text: "Ticket created", at: "3d ago"}]
      },
      %{
        id: 239,
        identifier: "#239",
        title: "Hub dashboard grouping",
        body: "Group the hub dashboard by project with counts.",
        status: :done,
        priority: :medium,
        tag: "ui",
        assignee: "grace@acme.test",
        project_id: 2,
        date: ~D[2026-09-28],
        comments: [%{author: "Ada Lovelace", initials: "AL", body: "Shipped with the new stat grid.", at: "4d ago"}],
        activity: [
          %{text: "Status changed to Done", at: "4d ago"},
          %{text: "Ticket created", at: "1w ago"}
        ]
      },
      %{
        id: 238,
        identifier: "#238",
        title: "Inspector rail",
        body: "Sticky right rail with property rows for the ticket page.",
        status: :todo,
        priority: :low,
        tag: "docs",
        assignee: "barbara@acme.test",
        project_id: 1,
        date: ~D[2026-09-26],
        comments: [],
        activity: [%{text: "Ticket created", at: "1w ago"}]
      },
      %{
        id: 237,
        identifier: "#237",
        title: "Dark mode contrast pass",
        body: "Audit muted text contrast in dark mode across dense pages.",
        status: :in_progress,
        priority: :high,
        tag: "ui",
        assignee: "grace@acme.test",
        project_id: 2,
        date: ~D[2026-09-25],
        comments: [],
        activity: [%{text: "Status changed to In progress", at: "2d ago"}]
      },
      %{
        id: 236,
        identifier: "#236",
        title: "Release notes for 0.8",
        body: "Write up the toast deck, Zag rollout, and preset for the release.",
        status: :todo,
        priority: :low,
        tag: "docs",
        assignee: "alan@acme.test",
        project_id: 3,
        date: ~D[2026-09-24],
        comments: [],
        activity: [%{text: "Ticket created", at: "1w ago"}]
      },
      %{
        id: 235,
        identifier: "#235",
        title: "SSO sign-in loop",
        body: "Users get bounced back to login after SSO on Safari.",
        status: :in_progress,
        priority: :urgent,
        tag: "auth",
        assignee: "ada@acme.test",
        project_id: 3,
        date: ~D[2026-09-23],
        comments: [%{author: "Alan Turing", initials: "AT", body: "Reproduced on iOS 26 — looks cookie-related.", at: "1d ago"}],
        activity: [
          %{text: "Priority raised to urgent", at: "1d ago"},
          %{text: "Ticket created", at: "2w ago"}
        ]
      },
      %{
        id: 234,
        identifier: "#234",
        title: "Weekly digest email",
        body: "Send owners a Monday summary of their open tickets.",
        status: :done,
        priority: :low,
        tag: "email",
        assignee: "barbara@acme.test",
        project_id: 2,
        date: ~D[2026-09-20],
        comments: [],
        activity: [%{text: "Status changed to Done", at: "1w ago"}]
      },
      %{
        id: 233,
        identifier: "#233",
        title: "Bulk triage actions",
        body: "Select many tickets and change status or assignee at once.",
        status: :todo,
        priority: :medium,
        tag: "ui",
        assignee: "alan@acme.test",
        project_id: 1,
        date: ~D[2026-09-18],
        comments: [],
        activity: [%{text: "Ticket created", at: "2w ago"}]
      },
      %{
        id: 232,
        identifier: "#232",
        title: "Empty-state illustrations",
        body: "Friendly empty states for inbox, search, and projects.",
        status: :done,
        priority: :low,
        tag: "ui",
        assignee: "grace@acme.test",
        project_id: 3,
        date: ~D[2026-09-15],
        comments: [],
        activity: [%{text: "Status changed to Done", at: "2w ago"}]
      }
    ]

    projects = [
      %{id: 1, name: "lantern-ui", summary: "Dense-app primitives for Linear-shaped pages", completed: 7, scope: 19, status: :active},
      %{id: 2, name: "Acme hub", summary: "Dashboard, inbox, and review flows", completed: 12, scope: 20, status: :active},
      %{id: 3, name: "Auth & billing", summary: "SSO, invites, and receipts", completed: 3, scope: 11, status: :paused}
    ]

    notifications = [
      %{id: 1, kind: "mention", title: "Grace mentioned you in #241", body: "“Ring renders in the list row now — check the hub next.”", read: false, at: "3h ago", link: "/app/tickets/241"},
      %{id: 2, kind: "review", title: "Review requested on #235", body: "Alan asked for a review of the SSO fix.", read: false, at: "5h ago", link: "/app/tickets/235"},
      %{id: 3, kind: "status", title: "#239 moved to Done", body: "Hub dashboard grouping is finished.", read: false, at: "1d ago", link: "/app/tickets/239"},
      %{id: 4, kind: "invite", title: "Barbara joined Acme", body: "Grace invited barbara@acme.test as viewer.", read: true, at: "2d ago", link: "/app/team"},
      %{id: 5, kind: "mention", title: "Alan mentioned you in #235", body: "“Reproduced on iOS 26 — looks cookie-related.”", read: true, at: "3d ago", link: "/app/tickets/235"},
      %{id: 6, kind: "system", title: "Weekly digest is live", body: "Monday summaries are on for every owner.", read: true, at: "1w ago", link: "/app/settings"}
    ]

    %{
      tickets: tickets,
      trash: [],
      projects: projects,
      members: members,
      notifications: notifications,
      settings: %{
        name: "Ada Lovelace",
        email: "ada@acme.test",
        signature: "Ship it.",
        prefs: %{mentions: true, review_requests: true, weekly_digest: false}
      },
      seq: %{ticket: 241, notification: 6}
    }
  end
end
