# Homebrew tap for upcheckr

Install [upcheckr](https://upcheckr.co) — the self-hosted, push-based live metrics wall — with Homebrew:

```sh
brew install laurentiud/tap/upcheckr
```

That pulls the prebuilt native binary (no Java needed) and puts `upcheckr` on your PATH. Then:

```sh
UPCHECKR_ADMIN_PASSWORD=secret upcheckr
```

Open <http://localhost:8080>. Data lives in SQLite at `~/.upcheckr/upcheckr.db` (override with `UPCHECKR_DB`).

## Platforms

| Platform | Supported |
|---|---|
| macOS (Apple Silicon) | yes — native arm64 |
| Linux x86-64 / arm64 | yes — static native |
| macOS (Intel) | no native build — use the JVM jar: `java -jar upcheckr.jar` |

Binaries come from the [public releases](https://github.com/laurentiud/upcheckr-public-releases) repo.

## Upgrade

```sh
brew update && brew upgrade upcheckr
```
