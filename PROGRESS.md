# StarNet Nexus preview status

The release is ready for a private home-network trial. Follow README.md to construct the source checkout from upstream e316231d70610aac7b181c4efd1a10b3fc833cdc and the ordered patches. NEXUS.md covers the service, Docker, authentication, remote access and backups. This is a standalone GitHub distribution. The reconstructed local branch contains upstream history.

## Implemented

The patches add a persistent endpoint registry, legacy custom import, per-agent provider identities, endpoint management during onboarding and in Settings, manual and authorized alternative routing, measured model discovery, and bounded endpoint concurrency. The Linux entry point wraps the existing station listener and keeps runs alive after the requesting client disconnects. Browser boot reconciles with the server save.

## Executed checks

Five focused Node 22 tests passed. They exercised 100 endpoints, migration, revision conflicts, private persistence, restart, overlapping agents selecting separate machines with the same model name, disconnect during a task, streamed tool calls and authorized failover, redirect refusal and listener security. The Chromium integration test passed with two isolated profiles using a local mock server. The second profile recovered NOVA and opened COMMS. These checks preceded the final settings-pane change. Linux installer shell syntax and systemd unit verification passed.

Both npm run test:fast and npm run test:http were launched and reported failures. A final clean run has not been established. Upstream browser-launch tests encountered a missing executable, marketplace tests encountered unavailable DNS, and a clean upstream checkout reproduced the prompt-composition digest mismatch. Credential-redaction, credential-census, update-drain, OAuth genesis and determinism checks passed on individual reruns after fixes. The frontend fetch-path guard and Ollama onboarding source assertion still need attention. Re-run the focused tests and both upstream suites on the completed source checkout.

## Pending validation

Test with real LM Studio and Lemonade machines, an Android browser over Tailscale, unattended systemd operation after logout/reboot, and a Docker Compose build including volume restore. The full desktop/native matrix, all auxiliary inference paths, approval recovery after reconnect and the complete security audit remain open. No physical inference host was available for live validation. Failover probes before sending a request and does not replay a partly completed inference or tool action.

## Reproducible commands

From the reconstructed station directory with dependencies installed:

```sh
node --test test/nexus-server.test.js
NEXUS_CHROMIUM=/path/to/chromium python3 test/nexus-browser.py
npm run test:fast
npm run test:http
```

The browser test needs Python Playwright. It uses temporary station data, synthetic credentials and loopback inference.
