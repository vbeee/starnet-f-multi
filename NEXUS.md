# Operating StarNet Nexus

## Process and credentials

Use a dedicated, unprivileged Linux service account. A single station process owns the data directory. Each signed-in browser controls that same privileged station as commander. Give its password only to trusted operators. The upstream permissions, file jail, project approvals and command consent still apply. Approved shell and MCP tools can exercise the service account's own privileges. Keep other private user data outside that account.

The service installer creates a systemd user unit and a mode-0600 password file. `loginctl enable-linger "$(id -un)"` keeps the user service available after logout and starts it at boot. Inspect the log with `journalctl --user -u starnet-nexus`. After editing configuration use `systemctl --user restart starnet-nexus`.

To launch the source checkout in the foreground instead, with Node 22 installed:

```sh
ONNXRUNTIME_NODE_INSTALL=skip ONNXRUNTIME_NODE_INSTALL_CUDA=skip npm ci --omit=dev
umask 077
mkdir -p "$HOME/.config/starnet-nexus"
test -e "$HOME/.config/starnet-nexus/password" || openssl rand -hex 32 > "$HOME/.config/starnet-nexus/password"
NEXUS_PASSWORD_FILE="$HOME/.config/starnet-nexus/password" npm run server
```

| Variable | Meaning |
|---|---|
| NEXUS_LISTEN, NEXUS_PORT | Default 127.0.0.1 and 8787 |
| NEXUS_DATA_DIR | Persistent station workspace, default ~/.local/share/starnet-nexus/data |
| NEXUS_PASSWORD_FILE, NEXUS_PASSWORD | File takes precedence. Minimum 24 characters. Login name is commander. |
| NEXUS_PUBLIC_URL | Exact browser origin including scheme and nonstandard port. Default http://localhost:8787 for the default port. |
| NEXUS_ALLOWED_ORIGINS | Comma-separated additional trusted browser origins |
| NEXUS_TLS_KEY, NEXUS_TLS_CERT | PEM files required for a direct network listener |
| NEXUS_LOG_LEVEL | Default normal logging, or error to suppress routine output |

## Tailnet and reverse proxy

With Tailscale already connected on both devices, enable HTTPS for the tailnet and run the following on the station host. This is an explicit administrator action.

```sh
tailscale serve --bg http://127.0.0.1:8787
tailscale serve status
```

Set `NEXUS_PUBLIC_URL` in `~/.config/starnet-nexus/service.env` to the exact HTTPS origin printed by Serve. Restart the service. Restrict access with tailnet policy. Visit the HTTPS URL on your phone or computer and enter the station password. To retain local SSH-forward access, add `NEXUS_ALLOWED_ORIGINS=http://localhost:8787`. Use Serve for private tailnet access. See [Tailscale Serve](https://tailscale.com/docs/reference/tailscale-cli/serve).

For a private Caddy deployment with an existing trusted certificate, replace the hostname, private interface address and PEM paths:

```caddyfile
station.example.internal {
    bind 192.168.1.100
    tls /path/station.crt /path/station.key
    reverse_proxy 127.0.0.1:8787 {
        flush_interval -1
    }
}
```

Set the matching HTTPS public URL in the station config. The reverse proxy must preserve the browser Host and Authorization headers. Browser origins, Host and cross-site context are checked before the sidecar gets a request. Its launch token and scoped file/event tickets remain in use. The regular health URL is /health and also requires authentication. See [Caddy reverse proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy).

## Docker Compose on Linux

Run in the source checkout. Keep nexus.env private. The service uses Linux host networking and a loopback listener by default. A named volume stores /var/lib/starnet.

```sh
umask 077
test -e nexus.env || printf 'NEXUS_PASSWORD=%s\n' "$(openssl rand -hex 32)" > nexus.env
docker compose up --build -d
docker compose ps
```

## Connecting inference machines

Enable each inference server's API and allow connections from the station host. Enter the machine's LAN or Tailscale address. For LM Studio, Ollama's compatibility API, Lemonade, llama.cpp, KoboldCpp, vLLM, LocalAI or LiteLLM, use the OpenAI-compatible base URL reported by that server, typically ending in /v1. Ollama also supports the Ollama protocol setting for native chat. Test queries GET models under the base URL. Set the manual model ID if the server omits it or has no catalog. Disabled, edited or deleted destinations fail closed. A URL change clears the existing key. Duplicate copies the credential only for the same destination.

Use manual selection initially. Alternative routing requires naming each authorized alternative in the endpoint editor. Set the model ID, tools, vision, context, output limit and priority explicitly where known. Alternative servers must support the requested model. Priority selects the highest configured compatible priority. Balance distributes run adapters by load. Failover selects an available destination before inference starts. Local mode accepts literal private, loopback or Tailscale IP addresses. A private address must point at a trusted local inference service; its operator controls whether that service forwards requests. Midstream failure stops that stream. Generation speed, when upstream usage is available, is completion tokens divided by elapsed request time.

## Architecture, persistence and recovery

The existing station frontend and sidecar run without Tauri. Each dynamic provider carries a stable UUID prefixed with nexus-. The adapter factory resolves that ID from the agent's provider field. The registry, its revision checks, transport, queues and health probes live in sidecar/nexus-network.js. sidecar/nexus-access.js authenticates the headless listener. The existing guarded inference, permission broker, run ledger, save conflict resolution and channel stream remain in use. Endpoint configuration persists under .secrets/inference-network.json, written atomically with mode 0600. Stored credentials are readable to the service user and are not encrypted at rest. Use encrypted storage if required. Browser settings send new provider keys to the server.

The existing custom configuration stays available during import. URLs containing embedded credentials, secret-shaped path fields or query parameters remain usable through the original provider. Re-enter these in the new registry with credentials in a header when supported. The browser resumes the authoritative server save on entry. Agent tasks continue on client disconnect. Pending approvals retain the upstream timeout and consent rules.

For a complete offline backup of a user-service install, stop the writer and copy both the data and configuration. Protect the archive like a credential.

```sh
umask 077
systemctl --user stop starnet-nexus
tar -czf "$HOME/starnet-$(date +%Y%m%d-%H%M%S).tgz" -C "$HOME" .local/share/starnet-nexus/data .config/starnet-nexus
systemctl --user start starnet-nexus
```

Restore as the service owner to a fresh account or empty destination with the service stopped, using `tar -xzf /path/to/backup.tgz -C "$HOME"`. Inspect service.env for machine-specific paths, then run the installer for the new checkout. For containers, stop Compose and archive the named volume and nexus.env together. Never share the same writable data directory across running instances.
