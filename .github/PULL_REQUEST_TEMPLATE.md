## Description
<!-- What does this PR do? -->

## Type of change
- [ ] New Caddy plugin added
- [ ] Version upgrade
- [ ] Bug fix
- [ ] Configuration change
- [ ] Documentation update

## Testing
<!-- How did you test this change? -->
```bash
docker build -t test-caddy .
docker run --rm test-caddy version
```

## Checklist
- [ ] I have tested the Docker build locally
- [ ] Plugin is added to the `xcaddy build` command
- [ ] No unrelated changes are included
