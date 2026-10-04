defmodule LanternDemoWeb.App.Helpers do
  @moduledoc "Small formatting and lookup helpers shared by the /app pages."

  def status_label(:todo), do: "To do"
  def status_label(:in_progress), do: "In progress"
  def status_label(:done), do: "Done"
  def status_label(s) when is_binary(s), do: s |> String.to_existing_atom() |> status_label()

  def priority_label(p), do: p |> to_string() |> String.capitalize()

  def status_options,
    do: [{"To do", "todo"}, {"In progress", "in_progress"}, {"Done", "done"}]

  def priority_options,
    do: [{"Low", "low"}, {"Medium", "medium"}, {"High", "high"}, {"Urgent", "urgent"}]

  def member_options(members), do: Enum.map(members, &{&1.name, &1.email})

  def project_options(projects), do: Enum.map(projects, &{&1.name, to_string(&1.id)})

  def role_options, do: [{"Admin", "admin"}, {"Member", "member"}, {"Viewer", "viewer"}]

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  def fmt_date(%Date{month: m, day: d}), do: "#{Enum.at(@months, m - 1)} #{d}"

  def initials_for(members, email) do
    case Enum.find(members, &(&1.email == email)) do
      nil -> "?"
      m -> m.initials
    end
  end

  def name_for(members, email) do
    case Enum.find(members, &(&1.email == email)) do
      nil -> email
      m -> m.name
    end
  end

  def project_name(projects, id) do
    case Enum.find(projects, &(&1.id == id)) do
      nil -> "—"
      p -> p.name
    end
  end

  def status_rank(:todo), do: 0
  def status_rank(:in_progress), do: 1
  def status_rank(:done), do: 2

  def priority_rank(:urgent), do: 0
  def priority_rank(:high), do: 1
  def priority_rank(:medium), do: 2
  def priority_rank(:low), do: 3

  def parse_int(nil, default), do: default

  def parse_int(value, default) do
    case Integer.parse(to_string(value)) do
      {n, _} when n > 0 -> n
      _ -> default
    end
  end

  def to_atom_in(value, allowed, default) do
    value = to_string(value)
    Enum.find(allowed, default, &(Atom.to_string(&1) == value))
  end

  @doc "First value of a Zag select's `on_change` payload (list or scalar)."
  def pick(%{"value" => v}), do: v |> List.wrap() |> List.first()
  def pick(_), do: nil
end
