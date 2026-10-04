import { Socket } from "https://cdn.jsdelivr.net/npm/phoenix@1.8.7/+esm"
import { LiveSocket } from "/js/phoenix_live_view.esm.js"
import { LanternGrid } from "/lantern/hooks.js"
import { LiveCode } from "/livecode/livecode.js"
import LanternUIHooks from "/lantern_ui_hooks.js"
import { S3, LanternS3Download } from "/lantern_s3_uploader.js"

const TurnstileWidget = {
  mounted() {
    const sitekey = this.el.dataset.sitekey
    const hook = this

    const render = () => {
      if (window.turnstile) {
        window.turnstile.render(this.el, {
          sitekey,
          callback: (token) => hook.pushEvent("sandbox_token", { token }),
        })
      } else {
        // Script not ready yet — retry
        setTimeout(render, 100)
      }
    }

    render()
  },
}

const THEME_STORAGE_KEY = "lui-theme"
const SIDEBAR_SCROLL_STORAGE_KEY = "lui-demo-sidebar-scroll"

const DocsExample = {
  mounted() {
    this.active = "preview"
    this.el.addEventListener("click", (e) => {
      const tab = e.target.closest("[data-tab]")
      if (!tab) return
      this.active = tab.dataset.tab
      this.apply()
    })
    this.apply()
  },
  apply() {
    this.el.querySelectorAll("[data-tab]").forEach((t) =>
      t.setAttribute("aria-selected", String(t.dataset.tab === this.active))
    )
    this.el.querySelectorAll("[data-panel]").forEach((p) => {
      p.hidden = p.dataset.panel !== this.active
    })
  },
  updated() {
    this.apply()
  },
}

const DemoChrome = {
  // Theme, density, and sidebar position belong to the persistent demo shell,
  // not an individual component page. Re-apply them after LiveView patches and
  // full route changes so navigating a long catalog never loses the reader's place.
  shell() {
    return document.getElementById(this.el.dataset.shell)
  },

  sidebarNav() {
    return this.shell()?.querySelector(".lui-app-nav")
  },

  saveSidebarScroll() {
    const nav = this.sidebarNavEl || this.sidebarNav()
    if (!nav) return
    try {
      sessionStorage.setItem(
        SIDEBAR_SCROLL_STORAGE_KEY,
        JSON.stringify({ top: nav.scrollTop, left: nav.scrollLeft })
      )
    } catch (_) {}
  },

  restoreSidebarScroll() {
    requestAnimationFrame(() => {
      const nav = this.sidebarNav()
      if (!nav) return
      try {
        const saved = JSON.parse(sessionStorage.getItem(SIDEBAR_SCROLL_STORAGE_KEY) || "null")
        if (saved) {
          nav.scrollTop = Number(saved.top) || 0
          nav.scrollLeft = Number(saved.left) || 0
        }
      } catch (_) {}
    })
  },

  bindSidebarScroll() {
    const nav = this.sidebarNav()
    if (nav === this.sidebarNavEl) return
    this.sidebarNavEl?.removeEventListener("scroll", this.onSidebarScroll)
    this.sidebarNavEl = nav
    this.sidebarNavEl?.addEventListener("scroll", this.onSidebarScroll, { passive: true })
  },

  restore() {
    try {
      this.state = JSON.parse(localStorage.getItem("lui-demo-chrome") || "null")
    } catch (_) {
      this.state = null
    }
    if (!this.state) {
      const dark = window.matchMedia("(prefers-color-scheme: dark)").matches
      this.state = { theme: dark ? "dark" : "light", density: "compact", preset: null }
    }
    if (!("preset" in this.state)) this.state.preset = null
  },

  apply() {
    const shell = this.shell()
    if (shell) {
      shell.classList.toggle("dark", this.state.theme === "dark")
      shell.classList.toggle("light", this.state.theme === "light")
      shell.setAttribute("data-lantern-density", this.state.density)
    }
    const t = this.el.querySelector('[data-part="theme-label"]')
    if (t) t.textContent = this.state.theme === "dark" ? "Light" : "Dark"
    const d = this.el.querySelector('[data-part="density-label"]')
    if (d) d.textContent = this.state.density === "compact" ? "Compact" : "Comfortable"
    const p = this.el.querySelector('[data-part="preset-label"]')
    if (p) p.textContent = this.state.preset === "shadcn" ? "shadcn" : "Default"
    this.applyPreset()
  },

  // Preset flows through <Theme.theme preset=>: the LanternTheme hook reads
  // data-preset off #lantern-theme and mirrors it onto <html> as
  // data-lantern-theme. Drive both from here so the switch survives patches
  // and navigation regardless of hook mount order.
  applyPreset() {
    const themeEl = document.getElementById("lantern-theme")
    if (themeEl) {
      if (this.state.preset) themeEl.setAttribute("data-preset", this.state.preset)
      else themeEl.removeAttribute("data-preset")
    }
    const html = document.documentElement
    if (this.state.preset) html.setAttribute("data-lantern-theme", this.state.preset)
    else html.removeAttribute("data-lantern-theme")
  },

  setPreset(preset) {
    this.state.preset = preset === "shadcn" ? "shadcn" : null
    this.save()
    this.apply()
  },

  save() {
    try {
      localStorage.setItem("lui-demo-chrome", JSON.stringify(this.state))
    } catch (_) {}
  },

  mounted() {
    this.restore()
    this.apply()
    this.onSidebarScroll = () => this.saveSidebarScroll()
    this.bindSidebarScroll()
    this.restoreSidebarScroll()
    this.el.addEventListener("click", (e) => {
      if (e.target.closest('[data-part="theme-toggle"]')) {
        this.state.theme = this.state.theme === "dark" ? "light" : "dark"
        this.save()
        this.apply()
      } else if (e.target.closest('[data-part="density-toggle"]')) {
        this.state.density = this.state.density === "compact" ? "comfortable" : "compact"
        this.save()
        this.apply()
      } else if (e.target.closest('[data-part="preset-toggle"]')) {
        this.setPreset(this.state.preset === "shadcn" ? null : "shadcn")
      }
    })
    this.onPreset = (e) => this.setPreset(e.detail && e.detail.preset)
    window.addEventListener("demo:set-preset", this.onPreset)
  },

  updated() {
    this.apply()
    this.bindSidebarScroll()
    this.restoreSidebarScroll()
  },

  destroyed() {
    this.saveSidebarScroll()
    window.removeEventListener("demo:set-preset", this.onPreset)
    this.sidebarNavEl?.removeEventListener("scroll", this.onSidebarScroll)
  },
}

const DemoTheming = {
  mounted() {
    // Inject the active theme CSS the server pushes, and persist / restore the
    // active light+dark theme ids to localStorage (client-side stand-in for
    // flicker's DB-backed themes).
    this.styleEl = document.getElementById("lui-demo-theme-css")
    if (!this.styleEl) {
      this.styleEl = document.createElement("style")
      this.styleEl.id = "lui-demo-theme-css"
      document.head.appendChild(this.styleEl)
    }

    this.handleEvent("demo:inject-theme", ({ css }) => {
      this.styleEl.textContent = css
    })
    this.handleEvent("demo:persist-theme", (ids) => {
      try {
        localStorage.setItem("lui-demo-theme", JSON.stringify(ids))
      } catch (_) {}
    })

    let stored = null
    try {
      stored = JSON.parse(localStorage.getItem("lui-demo-theme") || "null")
    } catch (_) {}
    this.pushEvent("restore", stored || {})
  },

  destroyed() {
    // Leave the injected theme in place across navigations within the demo.
  },
}


// Cmd/Ctrl+K docs search. A plain overlay (not <dialog>) so it behaves the same in every
// browser; the index comes from /docs/search.json (one entry per page and per component
// inside a merged page, with introspected function/attr names as keywords).
let docsIndex = null
const loadDocsIndex = (url) =>
  (docsIndex ||= fetch(url).then((r) => r.json()).catch(() => { docsIndex = null; return [] }))

const RECENT_KEY = "lui-docs-search-recent"

const scoreEntry = (e, terms) => {
  const title = e.t.toLowerCase()
  const words = title.split(/[^a-z0-9_]+/)
  let total = 0
  for (const t of terms) {
    let s = 0
    if (title === t) s = 100
    else if (title.startsWith(t)) s = 80
    else if (words.some((w) => w.startsWith(t))) s = 65
    else if (title.includes(t)) s = 45
    else if (e.k.split(" ").includes(t)) s = 38
    else if (e.k.split(" ").some((w) => w.startsWith(t))) s = 28
    else if (e.k.includes(t)) s = 16
    else if (t.length > 2 && isSubsequence(t, title)) s = 8
    if (!s) return 0
    total += s
  }
  return total + (e.p || 0) * 3 - e.t.length / 100
}

const isSubsequence = (needle, hay) => {
  let i = 0
  for (const ch of hay) if (ch === needle[i]) i++
  return i === needle.length
}

const DocsSearch = {
  mounted() {
    const el = this.el
    this.input = el.querySelector("input")
    this.list = el.querySelector(".docs-search-list")
    this.active = 0
    this.shown = []
    this.opener = null

    this.onKey = (e) => {
      const k = e.key.toLowerCase()
      if ((e.metaKey || e.ctrlKey) && k === "k") {
        e.preventDefault()
        this.isOpen() ? this.close() : this.open()
      } else if (k === "/" && !this.isOpen() && !/^(input|textarea|select)$/i.test(e.target.tagName) && !e.target.isContentEditable) {
        e.preventDefault()
        this.open()
      } else if (k === "escape" && this.isOpen()) {
        e.preventDefault()
        this.close()
      }
    }
    this.onDocClick = (e) => {
      if (e.target.closest("[data-docs-search-open]")) {
        e.preventDefault()
        this.open(e.target.closest("[data-docs-search-open]"))
      }
    }
    window.addEventListener("keydown", this.onKey)
    document.addEventListener("click", this.onDocClick)

    el.addEventListener("click", (e) => {
      if (e.target.closest("[data-close]")) return this.close()
      const a = e.target.closest("a[data-result]")
      if (a) this.choose(a)
    })
    this.list.addEventListener("mousemove", (e) => {
      const a = e.target.closest("a[data-result]")
      if (a && Number(a.dataset.i) !== this.active) this.setActive(Number(a.dataset.i), false)
    })
    this.input.addEventListener("input", () => this.render())
    this.input.addEventListener("keydown", (e) => {
      if (e.key === "ArrowDown") { e.preventDefault(); this.setActive(Math.min(this.active + 1, this.shown.length - 1)) }
      else if (e.key === "ArrowUp") { e.preventDefault(); this.setActive(Math.max(this.active - 1, 0)) }
      else if (e.key === "Home") { e.preventDefault(); this.setActive(0) }
      else if (e.key === "End") { e.preventDefault(); this.setActive(this.shown.length - 1) }
      else if (e.key === "Enter") {
        e.preventDefault()
        const a = this.list.querySelector(`a[data-i="${this.active}"]`)
        if (a) { this.choose(a); a.click() }
      } else if (e.key === "Tab") e.preventDefault() // focus trap: the input is the only stop
    })
    loadDocsIndex(el.dataset.index) // warm the cache
  },

  destroyed() {
    window.removeEventListener("keydown", this.onKey)
    document.removeEventListener("click", this.onDocClick)
    document.documentElement.classList.remove("docs-search-open")
  },

  isOpen() { return !this.el.hidden },

  open(opener) {
    if (this.isOpen()) return
    // Safari doesn't focus a button on click, so activeElement would be <body>
    this.opener = opener || document.activeElement
    this.el.hidden = false
    document.documentElement.classList.add("docs-search-open")
    this.input.value = ""
    this.render()
    this.input.focus()
  },

  close() {
    if (!this.isOpen()) return
    this.el.hidden = true
    document.documentElement.classList.remove("docs-search-open")
    if (this.opener && document.contains(this.opener) && this.opener.focus) this.opener.focus()
  },

  choose(a) {
    const href = a.getAttribute("href")
    try {
      const recent = JSON.parse(localStorage.getItem(RECENT_KEY) || "[]").filter((h) => h !== href)
      recent.unshift(href)
      localStorage.setItem(RECENT_KEY, JSON.stringify(recent.slice(0, 5)))
    } catch (_) {}
    this.opener = null // navigation moves focus; don't pull it back
    this.close()
    const hash = href.split("#")[1]
    if (hash) setTimeout(() => document.getElementById(hash)?.scrollIntoView(), 450)
  },

  async render() {
    const index = await loadDocsIndex(this.el.dataset.index)
    const q = this.input.value.trim().toLowerCase()
    let groups
    if (!q) {
      const byHref = new Map(index.map((e) => [e.h, e]))
      let recent = []
      try { recent = JSON.parse(localStorage.getItem(RECENT_KEY) || "[]") } catch (_) {}
      const sug = JSON.parse(this.el.dataset.suggest || "[]")
      groups = [
        ["Recent", recent.map((h) => byHref.get(h)).filter(Boolean)],
        ["Suggested", sug.map((h) => byHref.get(h)).filter(Boolean)],
      ].filter(([, items]) => items.length)
    } else {
      const terms = q.split(/\s+/)
      const hits = index
        .map((e) => [scoreEntry(e, terms), e])
        .filter(([s]) => s > 0)
        .sort((a, b) => b[0] - a[0])
        .slice(0, 30)
        .map(([, e]) => e)
      groups = hits.length ? [["Results", hits]] : []
    }
    this.shown = groups.flatMap(([, items]) => items)
    this.active = 0
    const esc = (s) => s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]))
    if (!this.shown.length) {
      this.list.innerHTML = `<div class="docs-search-empty">No results for “${esc(q)}”.<br><small>Try a component name (“badge”), a prop (“row_navigate”) or a function (“toast_group”).</small></div>`
      this.input.removeAttribute("aria-activedescendant")
      return
    }
    let i = 0
    this.list.innerHTML = groups
      .map(([label, items]) =>
        `<div class="docs-search-group" role="presentation">${label}</div>` +
        items.map((e) => `<a id="docs-search-r${i}" role="option" tabindex="-1" data-result data-i="${i++}" href="${esc(e.h)}" data-phx-link="redirect" data-phx-link-state="push"><span>${esc(e.t)}</span><small>${esc(e.c)}</small></a>`).join("")
      )
      .join("")
    this.setActive(0)
  },

  setActive(i, scroll = true) {
    this.active = i
    this.list.querySelectorAll("a[data-result]").forEach((a) => {
      const on = Number(a.dataset.i) === i
      a.setAttribute("aria-selected", on ? "true" : "false")
      if (on) {
        this.input.setAttribute("aria-activedescendant", a.id)
        if (scroll) a.scrollIntoView({ block: "nearest" })
      }
    })
  },
}


const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...LanternUIHooks, LanternGrid, LiveCode, LanternS3Download, TurnstileWidget, DemoTheming, DemoChrome, DocsExample, DocsSearch },
  uploaders: { S3 },
  params: { _csrf_token: csrfToken },
})

liveSocket.connect()
window.liveSocket = liveSocket
