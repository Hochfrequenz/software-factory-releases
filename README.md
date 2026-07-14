# Hochfrequenz Software Factory — Releases

Binary releases for the **Hochfrequenz Software Factory (hsf)**. The source lives in the private [`hochfrequenz/software-factory`](https://github.com/hochfrequenz/software-factory) repository; this repo carries only the release artifacts (tar.gz archives + `checksums.txt`) and the install scripts.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install.sh | bash
```

Installs `hsf`, `hsf-mcp`, and `hsf-runner` to `~/.local/bin` (co-located, so the self-updater keeps all three fresh), each verified against the release's `checksums.txt`. For the standalone build agent:

```bash
curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install-hsf-agent.sh | bash
```

The `scripts/` directory is synced automatically from the source repo on every release.
