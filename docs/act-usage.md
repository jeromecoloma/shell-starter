# Local CI Testing with Act

This document provides instructions for running GitHub Actions locally using `act`.

## Installation

`act` is already installed and configured on this system with an alias for Apple M-series compatibility:
```bash
act -P ubuntu-latest=shivammathur/node:latest
```

## Usage

### List available jobs
```bash
act --list
```

### Run all CI jobs (push event)
```bash
act push --container-architecture linux/amd64
```

### Run specific job
```bash
act -j test --container-architecture linux/amd64
```

### Run for pull request event
```bash
act pull_request --container-architecture linux/amd64
```

## Notes

- Use `--container-architecture linux/amd64` for Apple M-series compatibility
- The CI will fail on shellcheck warnings until tasks SHS-28, SHS-29, SHS-30 are completed
- This is expected behavior and validates that the CI pipeline is working correctly