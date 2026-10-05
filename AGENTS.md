# AGENTS.md

## Running the app (Base44 dev environment)

- `docker compose -f docker-compose.base44.yml up -d --build` builds `Dockerfile.base44`
  (Rust nightly-2024-04-20 + wasm32 target + trunk 0.21.7 — toolchain only, no app code)
  and starts one `game` service.
- The startup command replicates `make run_debug` from `makefiles/game.mk`:
  1. `trunk build ... index.dev.html` compiles the WASM client into `client/dist`
     (renamed to `index.html`).
  2. `cargo run` (debug server) serves `client/dist` over plain HTTP on port 8000,
     mapped to host port 3000. Websocket is same-origin.
- In **debug** builds, kodiak serves the client from disk (minicdn debug mode), so a
  trunk rebuild is picked up without restarting the server. In release builds the client
  is embedded in the binary at compile time — always build the client first.
- First boot compiles everything (expect ~10–25 min); `cargo-cache`, `client-target`
  and `server-target` volumes persist builds so later restarts are fast.

## No live reload

Rust/WASM has no hot reload here. After editing:
- **client code**: `docker compose -f docker-compose.base44.yml exec game sh -c "cd /app/client && trunk build --minify --no-sri --skip-version-check --filehash false index.dev.html && mv dist/index.dev.html dist/index.html"` then hard-refresh the preview.
- **server/common code**: `docker compose -f docker-compose.base44.yml restart game` (it recompiles automatically), then `reload_preview`.

## Gotchas

- Server must run on the **debug** profile: only the debug build binds a plain-HTTP port
  that serves the game; release builds redirect HTTP→HTTPS and embed the client.
- Run as root in the container and the server defaults to ports 80/443 — compose passes
  `--http-port 8000 --https-port 8443` explicitly.
- The `engine/` git submodule (gitlab, SSH URL) is NOT needed to build: kodiak comes from
  the public GitHub git dependency pinned by tag `0.2.0` in `server/Cargo.toml` /
  `client/Cargo.toml`.
- Repo-root `.cargo` sets `--cfg=web_sys_unstable_apis`; cargo picks it up from the
  client/ and server/ working dirs via ancestor search.
- No credentials/DB required. The admin bearer token is auto-generated and logged as
  "no plasma bearer token" in dev — harmless.
- Verify with: `curl -fsS http://localhost:3000/` (serves the mk48 index page).

## Test commands

- Server unit tests: `docker compose -f docker-compose.base44.yml exec game cargo test --manifest-path server/Cargo.toml`
