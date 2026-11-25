# StarNet Nexus

Run the StarNet pixel-art station on a Linux server and assign each crew member a model on its own inference machine. Endpoints with the same model ID have separate identities, credentials and concurrency limits.

## Install on Linux

Use Git, Node.js 22 with npm, and a regular Linux user with a systemd user manager. Run these commands on the station host.

```sh
git clone https://github.com/vbeee/starnet-f-multi.git
cd starnet-f-multi
bash checkout.sh
cd station
bash deploy/install-linux.sh
loginctl enable-linger "$(id -un)"
systemctl --user status starnet-nexus
```

The installer creates a private password file. Open **http://localhost:8787** and sign in as **commander** using the contents of `~/.config/starnet-nexus/password`. For a first remote login, run `ssh -L 8787:localhost:8787 YOUR_USER@YOUR_SERVER` on your computer, then open that same localhost address. Linux distributions may require an administrator to enable lingering once.

In setup, advance from the title screen to **Connect a brain → Inference Network → Add endpoint**. Enter the inference API URL as reachable **from the station host**, including its port and API prefix. Save, test the connection, select **Use this endpoint**, and wake the Overseer. After onboarding, open **Settings → Inference Network** to manage machines. Open an agent's model dock to choose its endpoint and model.

## Source and deployment

This repository distributes an ordered Git patch series. `checkout.sh` creates the complete buildable `station/` checkout on branch `nexus` from the pinned upstream commit, applies the Nexus changes and configures both remotes. The source checkout retains Andrew Sims's original attribution, MIT license and Git history. The GitHub repository itself has independent history. Running checkout requires network access to upstream.

[Linux, Docker, Tailscale, endpoints, security and backup guide](NEXUS.md) · [Tests, release status and remaining work](PROGRESS.md) · [Original StarNet](https://github.com/androoAGI/starnet)
