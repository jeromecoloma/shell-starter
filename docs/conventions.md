# Shell Starter - Coding Conventions

This document outlines the coding standards and conventions used in Shell Starter. Following these conventions ensures consistency, maintainability, and compatibility with the project's architecture.

## 📁 File Organization

### Directory Structure
```
shell-starter/
├── bin/                # Executable scripts (no .sh extension)
├── lib/                # Shared library functions (.sh extension)
├── scripts/            # Helper scripts in other languages
├── tests/              # Bats test files (.bats extension)
├── docs/               # Documentation files (.md extension)
└── .development/       # Internal development files
```

### Naming Conventions

- **Executable Scripts** (`bin/`): Use kebab-case without file extensions
  - ✅ `hello-world`, `my-cli`, `greet-user`
  - ❌ `hello_world.sh`, `myScript`, `greet-user.bash`

- **Library Files** (`lib/`): Use kebab-case with `.sh` extension
  - ✅ `colors.sh`, `logging.sh`, `spinner.sh`
  - ❌ `Colors.sh`, `logging_utils.sh`, `spinner`

- **Test Files** (`tests/`): Use kebab-case with `.bats` extension
  - ✅ `hello-world.bats`, `library-functions.bats`
  - ❌ `test_hello.bats`, `HelloWorld.bats`

## 📜 Script Structure

### Standard Header Template
Every script should start with this template:

```bash
#!/bin/bash

# script-name - Brief description of what the script does
# Optional: Longer description with usage examples

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"
```

### Error Handling
- Always use `set -euo pipefail` for strict error handling
- Use the logging functions for consistent error reporting
- Exit with appropriate codes (0 for success, non-zero for errors)

### Function Definitions
```bash
# Use snake_case for function names
function show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]
...
EOF
}

# Functions should have descriptive names
function validate_input() {
    local input="$1"
    # validation logic
}
```

## 🎨 Styling Guidelines

### Colors and Logging
- Use the provided logging functions instead of raw `echo`
- Prefer semantic colors over direct color codes

```bash
# ✅ Good
log::info "Processing data..."
log::warn "Configuration file not found, using defaults"
log::error "Failed to connect to server"

# ❌ Avoid
echo -e "${BLUE}Processing data...${RESET}"
echo "Warning: Configuration file not found"
```

### Variables
- Use UPPERCASE for environment variables and constants
- Use lowercase for local variables
- Quote variables to prevent word splitting

```bash
# ✅ Good
readonly DEFAULT_CONFIG_PATH="/etc/myapp/config"
local user_input="$1"
local file_count="${#files[@]}"

# ❌ Avoid
default_config_path="/etc/myapp/config"
USERINPUT="$1"
echo $user_input  # Unquoted variable
```

### Command Substitution
- Prefer `$()` over backticks for command substitution

```bash
# ✅ Good
current_date="$(date +%Y-%m-%d)"
file_count="$(ls -1 | wc -l)"

# ❌ Avoid
current_date=`date +%Y-%m-%d`
```

## 🔧 Argument Parsing

### Standard Pattern
Use this pattern for consistent argument parsing:

```bash
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [ARGS]

ARGUMENTS:
    ARG1              Description of first argument

OPTIONS:
    -h, --help        Show this help message and exit
    -v, --version     Show version information and exit
    -q, --quiet       Suppress verbose output
    -f, --force       Force operation without confirmation

EXAMPLES:
    $(basename "$0") --help
    $(basename "$0") --version
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$(basename "$0") $(get_version)"
            exit 0
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -*)
            log::error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # Positional argument
            break
            ;;
    esac
done
```

## 📚 Library Usage

### Sourcing Libraries
Always source `lib/main.sh` which includes all other libraries:

```bash
source "${SHELL_STARTER_ROOT}/lib/main.sh"
```

### Available Functions

#### Logging Functions
```bash
log::info "Informational message"
log::warn "Warning message" 
log::error "Error message"
log::debug "Debug message" # Only shown if DEBUG=1
log::success "Success message"
```

#### Spinner Functions
```bash
spinner::start "Loading data..."
# Long running operation
spinner::stop
```

#### Utility Functions
```bash
# Get version from VERSION file
version="$(get_version)"

# Execute scripts in other languages
run::script "scripts/analyze.py" "$input_file"
```

## 🧪 Testing Conventions

### Bats Test Structure
```bash
#!/usr/bin/env bats

# Test file should be named after the script being tested
# Example: tests/hello-world.bats

setup() {
    # Common setup for all tests
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
}

@test "script shows help when --help flag is used" {
    run hello-world --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "script shows version when --version flag is used" {
    run hello-world --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "hello-world" ]]
}
```

## 🔐 Security Best Practices

### Input Validation
```bash
# Always validate user input
validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log::error "Invalid email format: $email"
        return 1
    fi
}
```

### File Operations
```bash
# Check if file exists and is readable
if [[ ! -r "$config_file" ]]; then
    log::error "Cannot read configuration file: $config_file"
    exit 1
fi

# Use absolute paths when possible
config_file="$(realpath "$config_file")"
```

### Environment Variables
```bash
# Provide defaults for environment variables
API_URL="${API_URL:-https://api.example.com}"
TIMEOUT="${TIMEOUT:-30}"

# Never log sensitive information
log::debug "Connecting to API at $API_URL"
# Don't log: log::debug "Using API key: $API_KEY"
```

## 📦 Dependencies

### Optional Dependencies
Handle optional dependencies gracefully:

```bash
check_dependencies() {
    local missing_deps=()
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log::warn "Optional dependencies missing: ${missing_deps[*]}"
        log::info "Some features may be unavailable"
    fi
}
```

### Required Dependencies
```bash
require_dependencies() {
    local deps=("git" "bash")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log::error "Required dependencies missing: ${missing_deps[*]}"
        log::error "Please install them and try again"
        exit 1
    fi
}
```

## 📖 Documentation

### Inline Comments
- Use comments sparingly and only when necessary
- Focus on explaining "why" rather than "what"
- Keep comments up-to-date with code changes

```bash
# Good: Explains why this is necessary
# We need to sleep here because the API rate limits requests
sleep 1

# Avoid: States the obvious
# Increment counter by 1
((counter++))
```

### Help Text
- Always provide comprehensive help text
- Include examples in help output
- Keep help text concise but informative

Following these conventions ensures that all Shell Starter scripts are consistent, maintainable, and follow bash best practices.