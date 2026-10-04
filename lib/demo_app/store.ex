defmodule DemoApp.Store do
  @moduledoc """
  Seeded in-memory store for the /app demo (Acme). One Agent holds an
  independent copy of the workspace per visitor session (`sid`, from the
  session cookie), so a public demo never lets one visitor's deletes show up
  for another. Idle sessions are pruned. Nothing touches Postgres.
  `reset!/1` reseeds one session (the settings danger zone and the tests).
  """
  use Agent

  @statuses ~w(todo in_progress done)
  @priorities ~w(low medium high urgent)
  @roles ~w(admin member viewer)
  @ttl_ms :timer.hours(2)
  @max_sessions 400

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def statuses, do: @statuses
  def priorities, do: @priorities
  def roles, do: @roles

  # State access ---------------------------------------------------------

  defp get(sid, fun) do
    Agent.get_and_update(__MODULE__, fn sessions ->
      {state, sessions} = fetch(sessions, sid)
      {fun.(state), sessions}
    end)
  end

  defp update(sid, fun) do
    Agent.get_and_update(__MODULE__, fn sessions ->
      {state, sessions} = fetch(sessions, sid)
      {reply, new_state} = fun.(state)
      {reply, put_in(sessions[sid], %{state: new_state, ts: now()})}
    end)
  end

  defp fetch(sessions, sid) do
    sessions = prune(sessions)

    case sessions do
      %{^sid => %{state: state}} ->
        {state, put_in(sessions[sid].ts, now())}

      _ ->
        state = seed()
        {state, Map.put(sessions, sid, %{state: state, ts: now()})}
    end
  end

  defp prune(sessions) do
    cutoff = now() - @ttl_ms
    sessions = sessions |> Enum.reject(fn {_, %{ts: ts}} -> ts < cutoff end) |> Map.new()

    if map_size(sessions) > @max_sessions do
      sessions
      |> Enum.sort_by(fn {_, %{ts: ts}} -> -ts end)
      |> Enum.take(@max_sessions)
      |> Map.new()
    else
      sessions
    end
  end

  defp now, do: System.monotonic_time(:millisecond)

  def reset!(sid) do
    signed_in = get(sid, & &1.signed_in)
    update(sid, fn _ -> {:ok, %{seed() | signed_in: signed_in}} end)
  end

  # Auth -----------------------------------------------------------------

  @password "lantern"

  def demo_credentials, do: %{email: "ada@acme.test", password: @password}

  def signed_in?(sid), do: get(sid, & &1.signed_in)

  def sign_in(sid, email, password) do
    update(sid, fn s ->
      email = String.downcase(String.trim(email))

      cond do
        Enum.any?(s.members, &(&1.email == email)) and password == @password ->
          {{:ok, Enum.find(s.members, &(&1.email == email))}, %{s | signed_in: true}}

        true ->
          {:error, s}
      end
    end)
  end

  def sign_out(sid), do: update(sid, fn s -> {:ok, %{s | signed_in: false}} end)

  # Tickets --------------------------------------------------------------

  def list_tickets(sid), do: get(sid, &Enum.sort_by(&1.tickets, fn t -> -t.id end))

  def get_ticket(sid, id) do
    case parse_id(id) do
      nil -> nil
      n -> get(sid, fn s -> Enum.find(s.tickets, &(&1.id == n)) end)
    end
  end

  def counts(sid) do
    tickets = list_tickets(sid)

    %{
      all: length(tickets),
      todo: Enum.count(tickets, &(&1.status == :todo)),
      in_progress: Enum.count(tickets, &(&1.status == :in_progress)),
      done: Enum.count(tickets, &(&1.status == :done)),
      urgent: Enum.count(tickets, &(&1.priority == :urgent and &1.status != :done))
    }
  end

  # Per-visitor caps keep a public demo from growing without bound.
  @max_tickets 300
  @max_projects 30
  @max_members 50

  def create_ticket(sid, attrs) do
    update(sid, fn
      %{tickets: tickets} = s when length(tickets) >= @max_tickets -> {nil, s}
      s -> do_create_ticket(s, attrs)
    end)
  end

  defp do_create_ticket(s, attrs) do
    id = s.seq.ticket + 1

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
      date: Date.utc_today(),
      comments: [],
      activity: [%{text: "Ticket created", at: "just now"}]
    }

    {ticket, %{s | tickets: [ticket | s.tickets], seq: %{s.seq | ticket: id}}}
  end

  @ticket_fields [:title, :body, :status, :priority, :tag, :assignee, :project_id]

  def update_ticket(sid, id, attrs) do
    update(sid, fn s ->
      case Enum.split_with(s.tickets, &(&1.id == id)) do
        {[ticket], rest} ->
          note = Map.get(attrs, :note, "Ticket updated")
          updated = ticket |> Map.merge(Map.take(attrs, @ticket_fields)) |> touch(note)
          {updated, %{s | tickets: [updated | rest]}}

        _ ->
          {nil, s}
      end
    end)
  end

  def delete_ticket(sid, id) do
    update(sid, fn s ->
      case Enum.split_with(s.tickets, &(&1.id == id)) do
        {[ticket], rest} -> {ticket, %{s | tickets: rest, trash: [ticket | s.trash]}}
        _ -> {nil, s}
      end
    end)
  end

  def restore_ticket(sid, id) do
    update(sid, fn s ->
      case Enum.split_with(s.trash, &(&1.id == id)) do
        {[ticket], trash} -> {ticket, %{s | tickets: [ticket | s.tickets], trash: trash}}
        _ -> {nil, s}
      end
    end)
  end

  def add_comment(sid, id, %{author: author, body: body}) do
    update(sid, fn s ->
      case Enum.split_with(s.tickets, &(&1.id == id)) do
        {[ticket], rest} ->
          comment = %{
            author: author,
            initials: initials(author),
            body: String.slice(body, 0, 2000),
            at: "just now"
          }

          updated = ticket |> Map.update!(:comments, &(&1 ++ [comment])) |> touch("Comment added")
          {comment, %{s | tickets: [updated | rest]}}

        _ ->
          {nil, s}
      end
    end)
  end

  defp touch(ticket, text) do
    Map.update!(ticket, :activity, &[%{text: text, at: "just now"} | &1])
  end

  # Projects -------------------------------------------------------------

  def list_projects(sid), do: get(sid, & &1.projects)

  def get_project(sid, id) do
    case parse_id(id) do
      nil -> nil
      n -> get(sid, fn s -> Enum.find(s.projects, &(&1.id == n)) end)
    end
  end

  def project_tickets(sid, project_id) do
    get(sid, fn s ->
      s.tickets |> Enum.filter(&(&1.project_id == project_id)) |> Enum.sort_by(&(-&1.id))
    end)
  end

  def create_project(sid, attrs) do
    update(sid, fn
      %{projects: projects} = s when length(projects) >= @max_projects -> {nil, s}
      s -> do_create_project(s, attrs)
    end)
  end

  defp do_create_project(s, %{name: name, summary: summary}) do
    id = s.seq.project + 1

    project = %{
      id: id,
      name: name,
      summary: summary,
      completed: 0,
      scope: 0,
      status: :active
    }

    {project, %{s | projects: s.projects ++ [project], seq: %{s.seq | project: id}}}
  end

  # Members --------------------------------------------------------------

  def list_members(sid), do: get(sid, & &1.members)

  def update_member_role(sid, email, role) when role in @roles do
    update(sid, fn s ->
      members =
        Enum.map(s.members, fn m -> if m.email == email, do: %{m | role: role}, else: m end)

      {:ok, %{s | members: members}}
    end)
  end

  def invite_member(sid, %{name: name, email: email, role: role}) do
    update(sid, fn s ->
      cond do
        Enum.any?(s.members, &(&1.email == email)) ->
          {{:error, :taken}, s}

        length(s.members) >= @max_members ->
          {{:error, :limit}, s}

        true ->
          member = %{name: name, email: email, role: role, initials: initials(name)}
          {{:ok, member}, %{s | members: s.members ++ [member]}}
      end
    end)
  end

  def remove_member(sid, email) do
    update(sid, fn s ->
      case Enum.split_with(s.members, &(&1.email == email)) do
        {[member], rest} -> {member, %{s | members: rest}}
        _ -> {nil, s}
      end
    end)
  end

  def restore_member(sid, member) do
    update(sid, fn s ->
      if Enum.any?(s.members, &(&1.email == member.email)),
        do: {:ok, s},
        else: {:ok, %{s | members: s.members ++ [member]}}
    end)
  end

  def member_name(sid, email) do
    get(sid, fn s ->
      case Enum.find(s.members, &(&1.email == email)) do
        nil -> email
        m -> m.name
      end
    end)
  end

  # Notifications --------------------------------------------------------

  def list_notifications(sid), do: get(sid, & &1.notifications)

  def unread_count(sid), do: get(sid, fn s -> Enum.count(s.notifications, &(!&1.read)) end)

  def mark_read(sid, id) do
    update(sid, fn s ->
      notes = Enum.map(s.notifications, fn n -> if n.id == id, do: %{n | read: true}, else: n end)
      {:ok, %{s | notifications: notes}}
    end)
  end

  def mark_all_read(sid) do
    update(sid, fn s ->
      {:ok, %{s | notifications: Enum.map(s.notifications, &%{&1 | read: true})}}
    end)
  end

  def clear_notifications(sid) do
    update(sid, fn s -> {s.notifications, %{s | notifications: []}} end)
  end

  def restore_notifications(sid, notes) do
    update(sid, fn s -> {:ok, %{s | notifications: notes}} end)
  end

  # Settings -------------------------------------------------------------

  def get_settings(sid), do: get(sid, & &1.settings)

  def update_settings(sid, patch) do
    update(sid, fn s -> {:ok, %{s | settings: Map.merge(s.settings, patch)}} end)
  end

  def update_prefs(sid, patch) do
    update(sid, fn s ->
      {:ok, %{s | settings: %{s.settings | prefs: Map.merge(s.settings.prefs, patch)}}}
    end)
  end

  def update_appearance(sid, patch) do
    update(sid, fn s ->
      {:ok, %{s | settings: %{s.settings | appearance: Map.merge(s.settings.appearance, patch)}}}
    end)
  end

  # Helpers --------------------------------------------------------------

  defp parse_id(n) when is_integer(n), do: n

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp parse_id(_), do: nil

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
          %{
            author: "Grace Hopper",
            initials: "GH",
            body: "Ring renders in the list row now — check the hub next.",
            at: "3h ago"
          },
          %{
            author: "Ada Lovelace",
            initials: "AL",
            body: "Hub updated. 7/19 visible at a glance.",
            at: "1h ago"
          }
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
        comments: [
          %{
            author: "Ada Lovelace",
            initials: "AL",
            body: "Shipped with the new stat grid.",
            at: "4d ago"
          }
        ],
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
        comments: [
          %{
            author: "Alan Turing",
            initials: "AT",
            body: "Reproduced on iOS 26 — looks cookie-related.",
            at: "1d ago"
          }
        ],
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
      %{
        id: 1,
        name: "lantern-ui",
        summary: "Dense-app primitives for Linear-shaped pages",
        completed: 7,
        scope: 19,
        status: :active
      },
      %{
        id: 2,
        name: "Acme hub",
        summary: "Dashboard, inbox, and review flows",
        completed: 12,
        scope: 20,
        status: :active
      },
      %{
        id: 3,
        name: "Auth & billing",
        summary: "SSO, invites, and receipts",
        completed: 3,
        scope: 11,
        status: :paused
      }
    ]

    notifications = [
      %{
        id: 1,
        kind: "mention",
        title: "Grace mentioned you in #241",
        body: "“Ring renders in the list row now — check the hub next.”",
        read: false,
        at: "3h ago",
        link: "/app/tickets/241"
      },
      %{
        id: 2,
        kind: "review",
        title: "Review requested on #235",
        body: "Alan asked for a review of the SSO fix.",
        read: false,
        at: "5h ago",
        link: "/app/tickets/235"
      },
      %{
        id: 3,
        kind: "status",
        title: "#239 moved to Done",
        body: "Hub dashboard grouping is finished.",
        read: false,
        at: "1d ago",
        link: "/app/tickets/239"
      },
      %{
        id: 4,
        kind: "invite",
        title: "Barbara joined Acme",
        body: "Grace invited barbara@acme.test as viewer.",
        read: true,
        at: "2d ago",
        link: "/app/team"
      },
      %{
        id: 5,
        kind: "mention",
        title: "Alan mentioned you in #235",
        body: "“Reproduced on iOS 26 — looks cookie-related.”",
        read: true,
        at: "3d ago",
        link: "/app/tickets/235"
      },
      %{
        id: 6,
        kind: "system",
        title: "Weekly digest is live",
        body: "Monday summaries are on for every owner.",
        read: true,
        at: "1w ago",
        link: "/app/settings"
      }
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
        prefs: %{mentions: true, review_requests: true, weekly_digest: false},
        appearance: %{theme: "system", preset: nil, density: "compact"}
      },
      seq: %{ticket: 241, project: 3, notification: 6},
      signed_in: false
    }
  end
end
