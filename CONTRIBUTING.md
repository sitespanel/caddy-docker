# Contributing

Thanks for your interest in improving this Caddy Docker image!

## How to Contribute

### Request a New Plugin
1. Open an issue with the title `Plugin request: <name>`
2. Provide the Go module path (e.g., `github.com/org/repo`)
3. Explain the use case — why should it be included for everyone?

### Report a Bug
1. Open an issue with details: image tag, error message, steps to reproduce
2. If the bug is about a plugin not working, include your `Caddyfile` config (redact secrets)

### Submit a Pull Request
1. Fork the repo and create a feature branch
2. Add your plugin to the `xcaddy build` command in the `Dockerfile`
3. Test locally:
   ```bash
   docker build -t test-caddy .
   docker run --rm test-caddy version
   ```
4. Open a PR against `master` with a clear description

## Project Structure

```
.
├── Dockerfile                 # Multi-stage Caddy build
├── .github/workflows/image.yml   # GitHub Actions: lint, build, scan, push to ghcr.io, attest (BUILD.md)
├── README.md                  # GitHub README
```

## Version Upgrades

To upgrade the Caddy version:
1. Update the version in both `FROM` lines in the `Dockerfile`
2. Test the build locally
3. The CI pipeline will auto-detect the new version for tagging
