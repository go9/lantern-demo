defmodule LanternDemoWeb.Docs.Page do
  @moduledoc """
  The consistent docs page template: eyebrow (section), title, one-line
  description, then the live previews + code, then the props table, then
  prev/next. Also the landing pages made of cards.
  """
  use Phoenix.Component

  alias LanternDemoWeb.Docs.Kit
  alias LanternDemoWeb.Docs.Nav
  alias LanternUI.Components.Icon

  attr(:section, :map, required: true)
  attr(:page, :map, required: true)
  slot(:inner_block, required: true)
  slot(:toc)

  def frame(assigns) do
    ~H"""
    <article class="docs-page" id={"page-#{@section.id}-#{@page.id}"}>
      <header class="docs-page-head">
        <p class="docs-eyebrow">{@section.title}</p>
        <h1 class="docs-page-title">{@page.title}</h1>
        <p class="docs-page-desc">{@page.desc}</p>
        <nav :if={@toc != []} class="docs-toc" aria-label="On this page">{render_slot(@toc)}</nav>
      </header>
      {render_slot(@inner_block)}
      <.pager section={@section} page={@page} />
    </article>
    """
  end

  attr(:section, :map, required: true)
  attr(:page, :map, required: true)
  attr(:titles, :map, required: true)
  attr(:render_member, :any, required: true, doc: "fn member -> rendered body")

  def members(assigns) do
    assigns = assign(assigns, :members, assigns.page.members)

    ~H"""
    <.frame section={@section} page={@page}>
      <:toc :if={length(@members) > 1}>
        <a :for={m <- @members} href={"##{m}"}>{@titles[m]}</a>
      </:toc>
      <%= if length(@members) == 1 do %>
        <% m = hd(@members) %>
        <div class="docs-body">{@render_member.(m)}</div>
        <Kit.api_section member={m} />
      <% else %>
        <section :for={m <- @members} id={m} class="docs-member">
          <h2 class="docs-member-title">{@titles[m]}</h2>
          <div class="docs-body">{@render_member.(m)}</div>
          <Kit.api_section member={m} />
        </section>
      <% end %>
    </.frame>
    """
  end

  attr(:section, :map, required: true)
  attr(:page, :map, required: true)

  def pager(assigns) do
    pages = Enum.map(assigns.section.pages, &{&1, Nav.path(&1, assigns.section)})
    idx = Enum.find_index(pages, fn {p, _} -> p.id == assigns.page.id end) || 0

    assigns =
      assign(assigns, prev: idx > 0 && Enum.at(pages, idx - 1), next: Enum.at(pages, idx + 1))

    ~H"""
    <nav :if={@prev || @next} class="docs-pager" aria-label="Pages in this section">
      <.link :if={@prev} navigate={elem(@prev, 1)}><small>Previous</small>{elem(@prev, 0).title}</.link>
      <.link :if={@next} navigate={elem(@next, 1)}><small>Next</small>{elem(@next, 0).title}</.link>
    </nav>
    """
  end

  attr(:section, :map, required: true)

  def section_landing(assigns) do
    ~H"""
    <article class="docs-page" id={"section-#{@section.id}"}>
      <header class="docs-page-head">
        <p class="docs-eyebrow">Docs</p>
        <h1 class="docs-page-title">{@section.title}</h1>
        <p class="docs-page-desc">{@section.desc}</p>
      </header>
      <div class="docs-cards">
        <.link :for={p <- @section.pages} navigate={Nav.path(p, @section)} class="docs-card">
          <span class="docs-card-title">{p.title}</span>
          <p class="docs-card-desc">{p.desc}</p>
        </.link>
      </div>
    </article>
    """
  end

  def index_landing(assigns) do
    assigns = assign(assigns, :sections, Nav.sections())

    ~H"""
    <article class="docs-page" id="docs-index">
      <header class="docs-page-head">
        <p class="docs-eyebrow">lantern-ui</p>
        <h1 class="docs-page-title">Documentation</h1>
        <p class="docs-page-desc">
          Components, blocks and patterns for Phoenix LiveView — every page has a live preview, the code, and the props.
          Press <kbd>⌘K</kbd> to search.
        </p>
      </header>
      <div class="docs-cards">
        <.link :for={s <- @sections} navigate={Nav.path(s)} class="docs-card">
          <span class="docs-card-title"><Icon.icon name={s.icon} /> {s.title}</span>
          <p class="docs-card-desc">{s.desc}</p>
          <span class="docs-card-meta">{length(s.pages)} {if length(s.pages) == 1, do: "page", else: "pages"}</span>
        </.link>
      </div>
    </article>
    """
  end
end
