#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
root="$PWD"
git clone --origin upstream https://github.com/androoAGI/starnet.git station
cd station
git switch -c nexus e316231d70610aac7b181c4efd1a10b3fc833cdc
git -c user.name='StarNet Nexus' -c user.email='nexus@localhost' am "$root"/patches/*.patch
git remote add origin https://github.com/vbeee/starnet-f-multi.git
