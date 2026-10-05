defmodule LanternDemoWeb.Docs.Search do
  @moduledoc """
  The docs search index, served as JSON (`/docs/search.json`) and fetched once by
  the `DocsSearch` hook. One entry per page, plus one per component inside a merged
  page. Keywords carry the function and attribute names introspected from the
  components (so `toast_group`, `row_navigate`, `state_glyph`, `stack` all find
  their page) plus a few hand-written aliases.
  """
  alias LanternDemoWeb.Docs.{Kit, Nav}

  @live_api %{
    "data-display/data-table" => [{LanternUI.Components.DataTable, :data_table}],
    "getting-started/theming" => [{LanternUI.Components.Theme, :theme}],
    "foundations/spacing" => [{LanternUI.Components.Layout, :stack}],
    "layout/app-shell" => [
      {LanternUI.Components.Layout, :breadcrumb_bar},
      {LanternUI.Components.Layout, :page_header}
    ]
  }

  @aliases %{
    "foundations/status" =>
      ~w(progress ring progress_ring meter badge glyph status priority run sync indicator),
    "foundations/spacing" => ~w(stack gap density radius radii space),
    "foundations/colors" => ~w(token tokens color colour palette dark light),
    "foundations/typography" => ~w(font text type heading),
    "feedback/toasts" => ~w(toast notification snackbar flash send_toast),
    "overlays/dialogs" => ~w(modal dialog popup confirm),
    "overlays/command" => ~w(palette cmdk spotlight),
    "forms/choice" => ~w(checkbox radio switch toggle),
    "data-display/data-table" =>
      ~w(table grid filter sort pagination row_navigate row_patch row_click),
    "data-display/tables-lists" => ~w(table list row description resource),
    "getting-started/ai" => ~w(llms agents lint skills),
    "getting-started/installation" => ~w(install setup mix hex deps)
  }

  def json do
    case :persistent_term.get({__MODULE__, :json}, nil) do
      nil ->
        json = Jason.encode!(entries())
        :persistent_term.put({__MODULE__, :json}, json)
        json

      json ->
        json
    end
  end

  def entries do
    for {s, p} <- Nav.all_pages(), entry <- page_entries(s, p), do: entry
  end

  defp page_entries(s, p) do
    id = "#{s.id}/#{p.id}"
    base = Nav.path(p, s)
    members = Map.get(p, :members, [])

    page_api =
      Map.get(@live_api, id, []) ++ Enum.flat_map(members, &Map.get(Kit.api_map(), &1, []))

    page_kw =
      [p.desc, s.title | Enum.map(members, &Nav.member_title/1)] ++
        api_words(page_api) ++ Map.get(@aliases, id, [])

    page = %{t: p.title, c: s.title, h: base, k: kw(page_kw), p: (s.id == "tools" && 0) || 1}

    sub =
      if length(members) > 1 do
        for m <- members do
          %{
            t: Nav.member_title(m),
            c: "#{s.title} › #{p.title}",
            h: "#{base}##{m}",
            k: kw([m | api_words(Map.get(Kit.api_map(), m, []))]),
            p: 0
          }
        end
      else
        []
      end

    [page | sub]
  end

  defp api_words(api) do
    Enum.flat_map(api, fn {mod, fun} ->
      info = mod.__components__()[fun]
      attrs = if info, do: Enum.map(info.attrs, & &1.name), else: []
      slots = if info, do: Enum.map(info.slots, & &1.name), else: []
      [fun | attrs ++ slots]
    end)
  end

  defp kw(words) do
    words
    |> Enum.map(&(to_string(&1) |> String.downcase()))
    |> Enum.uniq()
    |> Enum.join(" ")
  end
end
