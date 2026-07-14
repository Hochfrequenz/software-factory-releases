# Hochfrequenz Software Factory — Releases

Binary releases for the **Hochfrequenz Software Factory (hsf)**. The source lives in the private [`hochfrequenz/software-factory`](https://github.com/hochfrequenz/software-factory) repository; this repo carries only the release artifacts (tar.gz archives + `checksums.txt`) and the install scripts.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install.sh | bash
```

Installs `hsf` and `hsf-mcp` to `~/.local/bin` with SHA-256 verification against the release's `checksums.txt`. For the standalone build agent:

```bash
curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install-hsf-agent.sh | bash
```

Runner-mode hosts also need `hsf-runner` — download its archive from the latest release, verify against `checksums.txt`, and install it next to `hsf`.

The `scripts/` directory is synced automatically from the source repo on every release.
