# lantern-demo

Live demo and [lantern-ui](https://github.com/go9/lantern-ui) components reference for [lantern](https://github.com/go9/lantern). Public deployment: <https://lantern-demo.flickercloud.com>.

This used to live in `examples/demo` inside `go9/lantern`. It is now its own repo so lantern-ui releases can update the catalog without touching the library.

## Run locally

```bash
docker compose up -d
mix setup
mix phx.server
```

Open <http://localhost:4001>. The docs start at <http://localhost:4001/docs>; the demo app (a ticket tracker built only from lantern components) is at <http://localhost:4001/app> — sign in with `ada@acme.test` / `lantern`.

## Layout

| Where | What |
|---|---|
| `lib/lantern_demo_web/docs/nav.ex` | The docs information architecture: sections → pages → component members |
| `lib/lantern_demo_web/docs/*.ex` | One module per section (`Forms`, `Overlays`, `DataDisplay`, …) holding the page bodies, plus `Page` (template + landing cards), `Kit` (example/code/API-table building blocks) and `Guides` (hand-written pages) |
| `lib/lantern_demo_web/live/docs_live.ex` | The one LiveView behind `/docs/:section/:page`; owns the shared demo state and the event handlers the previews fire |
| `lib/lantern_demo_web/components/docs_shell.ex` | Docs chrome: collapsible section groups, breadcrumb, Cmd+K search |
| `lib/lantern_demo_web/app/` | The `/app` demo: `app_live.ex` (routing, auth gate, palette, toasts), `shell.ex` (Acme chrome) and `pages/*` |
| `lib/demo_app/store.ex` | In-memory, per-visitor seeded data for `/app` (keyed by a session cookie, pruned after 2 idle hours, capped) |

`/components/:slug` URLs from the old flat catalog redirect to the new pages.

Default database URL:

```text
postgres://postgres:postgres@localhost:5432/lantern_demo
```

Override if needed:

```bash
export LANTERN_DEMO_DATABASE_URL=postgres://postgres:postgres@localhost:5432/lantern_demo
mix lantern_demo.seed
mix phx.server
```

Requires Elixir 1.18.4 / OTP 28 (see `.tool-versions`).

## Deploy

Push to `main`. GitHub Actions compiles, builds `ghcr.io/go9/lantern-demo-app`, and deploys the flicker app `lantern-demo` (project `lantern-demo`).

The repo needs a `FLICKER_TOKEN` GitHub Actions secret (flicker API token). Without it the deploy step fails after the image push.
