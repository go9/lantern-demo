# lantern-demo

Live demo and [lantern-ui](https://github.com/go9/lantern-ui) components reference for [lantern](https://github.com/go9/lantern). Public deployment: <https://lantern-demo.flickercloud.com>.

This used to live in `examples/demo` inside `go9/lantern`. It is now its own repo so lantern-ui releases can update the catalog without touching the library.

## Run locally

```bash
docker compose up -d
mix setup
mix phx.server
```

Open <http://localhost:4001>. Component documentation starts at <http://localhost:4001/components>.

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
