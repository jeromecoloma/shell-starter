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
act -j shellcheck --container-architecture linux/amd64
act -j shfmt --container-architecture linux/amd64
```

### Run for pull request event
```bash
act pull_request --container-architecture linux/amd64
```

## Notes

- Use `--container-architecture linux/amd64` for Apple M-series compatibility
- **Expected shellcheck output**:
  - `SC2034` warnings for unused color variables in `lib/colors.sh` - **Expected** (library variables meant for external use)
  - `SC1091` info about not following sourced files - **Expected** (normal shellcheck behavior when analyzing files individually)  
  - `SC2317` info about unreachable code - **False positive** (can be ignored)
- **Expected shfmt output**:
  - Formatting differences will be shown as diffs if code doesn't match shfmt's formatting rules
  - Job fails with non-zero exit code when formatting issues are found - **Expected** (enforces consistent formatting)
- The CI validates that linting, formatting, and testing tools are working correctly