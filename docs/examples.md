# Shell Starter - Script Examples

This document provides detailed examples and usage patterns for Shell Starter scripts. Use these examples as templates for creating new scripts or understanding existing ones.

## 🎯 Basic Script Examples

### 1. Hello World Script

The simplest possible Shell Starter script:

```bash
#!/bin/bash

# hello-world - A simple greeting script
# Demonstrates basic library usage and argument parsing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [NAME]

A simple greeting script that demonstrates Shell Starter features.

ARGUMENTS:
    NAME              Name to greet (default: World)

OPTIONS:
    -h, --help        Show this help message and exit
    -v, --version     Show version information and exit
    -q, --quiet       Suppress colorful output

EXAMPLES:
    $(basename "$0")                    # Greets "World"
    $(basename "$0") Alice              # Greets "Alice"
    $(basename "$0") --quiet Bob        # Greets "Bob" without colors
EOF
}

main() {
    local name="World"
    local quiet=false
    
    # Parse arguments
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
                quiet=true
                shift
                ;;
            -*)
                log::error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                name="$1"
                shift
                ;;
        esac
    done
    
    # Main logic
    if [[ "$quiet" == true ]]; then
        echo "Hello, $name!"
    else
        log::success "Hello, $name!"
        log::info "Welcome to Shell Starter!"
    fi
}

main "$@"
```

### 2. Color Showcase Script

Demonstrates all available colors and logging functions:

```bash
#!/bin/bash

# show-colors - Demonstrates Shell Starter color and logging capabilities
# This script showcases all available colors and logging functions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

main() {
    echo "${COLOR_BOLD}${COLOR_CYAN}Shell Starter - Color Library Showcase${COLOR_RESET}"
    echo "=========================================="
    
    echo "${COLOR_BOLD}Basic Colors:${COLOR_RESET}"
    echo "  ${COLOR_BLACK}COLOR_BLACK${COLOR_RESET}     - Black text"
    echo "  ${COLOR_RED}COLOR_RED${COLOR_RESET}       - Red text"
    echo "  ${COLOR_GREEN}COLOR_GREEN${COLOR_RESET}     - Green text"
    # ... more color examples
    
    echo
    echo "${COLOR_BOLD}${COLOR_UNDERLINE}Logging Function Examples:${COLOR_RESET}"
    echo
    
    log::success "✓ Success: Operation completed successfully!"
    log::warn "⚠ Warning: This is a warning message"
    log::error "✗ Error: Something went wrong"
    log::info "ℹ Info: Here's some information"
    log::debug "🐛 Debug: Debugging information"
}

main "$@"
```

### 3. Long-Running Task with Spinner

Shows how to use spinners for user feedback:

```bash
#!/bin/bash

# long-task - Demonstrates spinner usage for long-running operations
# This script simulates various long-running tasks with progress feedback

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

simulate_task() {
    local task_name="$1"
    local duration="$2"
    
    log::info "Starting: $task_name"
    spinner::start "$task_name"
    
    sleep "$duration"
    
    spinner::stop
    log::success "Completed: $task_name"
}

main() {
    log::info "Demonstrating spinner functionality..."
    echo
    
    simulate_task "Downloading files" 2
    simulate_task "Processing data" 3
    simulate_task "Uploading results" 1
    
    echo
    log::success "All tasks completed successfully!"
}

main "$@"
```

## 🔧 Advanced Script Patterns

### 4. Interactive User Input Script

Demonstrates input validation and interactive prompts:

```bash
#!/bin/bash

# greet-user - Interactive script with user input validation
# Shows advanced argument parsing and user interaction patterns

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

# Global configuration
GREETING_STYLE="casual"
USE_EMOJI=true
TIME_BASED=false

get_user_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " result
        result="${result:-$default}"
    else
        read -p "$prompt: " result
    fi
    
    echo "$result"
}

validate_name() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        log::error "Name cannot be empty"
        return 1
    fi
    
    if [[ ${#name} -lt 2 ]]; then
        log::error "Name must be at least 2 characters long"
        return 1
    fi
    
    if [[ ! "$name" =~ ^[A-Za-z][A-Za-z\ ]*$ ]]; then
        log::error "Name can only contain letters and spaces"
        return 1
    fi
    
    return 0
}

format_greeting() {
    local name="$1"
    local greeting
    
    case "$GREETING_STYLE" in
        formal)
            greeting="Good day, $name."
            ;;
        casual)
            greeting="Hey there, $name!"
            ;;
        *)
            greeting="Hello, $name!"
            ;;
    esac
    
    if [[ "$USE_EMOJI" == true ]]; then
        case "$GREETING_STYLE" in
            formal)
                greeting="🎩 $greeting"
                ;;
            casual)
                greeting="👋 $greeting"
                ;;
            *)
                greeting="😊 $greeting"
                ;;
        esac
    fi
    
    if [[ "$TIME_BASED" == true ]]; then
        local hour
        hour=$(date +%H)
        local time_greeting
        
        if (( hour < 12 )); then
            time_greeting="Good morning"
        elif (( hour < 17 )); then
            time_greeting="Good afternoon"
        else
            time_greeting="Good evening"
        fi
        
        greeting="$time_greeting! $greeting"
    fi
    
    echo "$greeting"
}

main() {
    local name=""
    local interactive=false
    
    # Parse arguments
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
            -i|--interactive)
                interactive=true
                shift
                ;;
            -f|--formal)
                GREETING_STYLE="formal"
                shift
                ;;
            -c|--casual)
                GREETING_STYLE="casual"
                shift
                ;;
            --no-emoji)
                USE_EMOJI=false
                shift
                ;;
            --time-based)
                TIME_BASED=true
                shift
                ;;
            -*)
                log::error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                name="$1"
                shift
                ;;
        esac
    done
    
    # Get name interactively if not provided or if interactive mode
    if [[ -z "$name" ]] || [[ "$interactive" == true ]]; then
        log::info "Interactive greeting mode"
        
        while true; do
            name=$(get_user_input "Enter your name" "")
            
            if validate_name "$name"; then
                break
            fi
            
            log::warn "Please try again with a valid name"
        done
    fi
    
    # Generate and display greeting
    local greeting
    greeting=$(format_greeting "$name")
    
    log::success "$greeting"
}

main "$@"
```

### 5. Multi-Command Dispatcher

Pattern for creating git-like subcommand interfaces:

```bash
#!/bin/bash

# my-cli - Multi-command CLI demonstrating subcommand patterns
# This script shows how to create git-like subcommand interfaces

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <command> [options]

A multi-command CLI tool demonstrating Shell Starter patterns.

COMMANDS:
    status          Show system status information
    config          Manage configuration settings
    deploy          Deploy applications or services
    backup          Create and manage backups
    monitor         System monitoring utilities

Use '$(basename "$0") <command> --help' for command-specific help.

EXAMPLES:
    $(basename "$0") status
    $(basename "$0") config list
    $(basename "$0") deploy --env prod app1
EOF
}

# Status command
cmd_status() {
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                status_help
                exit 0
                ;;
            *)
                log::error "Unknown option: $1"
                status_help
                exit 1
                ;;
        esac
    done
    
    log::info "Gathering system status information..."
    echo "${COLOR_BOLD}${COLOR_CYAN}System Status${COLOR_RESET}"
    echo "================================"
    printf "  ${COLOR_GREEN}Hostname:${COLOR_RESET} %s\n" "$(hostname)"
    printf "  ${COLOR_GREEN}Timestamp:${COLOR_RESET} %s\n" "$(date)"
    printf "  ${COLOR_GREEN}Uptime:${COLOR_RESET} %s\n" "$(uptime | awk -F'up ' '{print $2}' | awk -F', [0-9]* users' '{print $1}')"
    printf "  ${COLOR_GREEN}Load Average:${COLOR_RESET} %s\n" "$(uptime | awk -F'load average: ' '{print $2}')"
    
    if [[ "$verbose" == true ]]; then
        echo
        log::info "Detailed system information..."
        printf "  ${COLOR_GREEN}System:${COLOR_RESET} %s\n" "$(uname -s)"
        printf "  ${COLOR_GREEN}Release:${COLOR_RESET} %s\n" "$(uname -r)"
        printf "  ${COLOR_GREEN}Architecture:${COLOR_RESET} %s\n" "$(uname -m)"
    fi
    
    log::success "Status check completed"
}

# Configuration management subcommands
cmd_config() {
    case "${1:-}" in
        get)
            shift
            config_get "$@"
            ;;
        set)
            shift
            config_set "$@"
            ;;
        list|ls)
            shift
            config_list "$@"
            ;;
        --help|-h|help|"")
            config_help
            ;;
        *)
            log::error "Unknown config command: $1"
            config_help
            exit 1
            ;;
    esac
}

config_get() {
    local key="${1:-}"
    
    if [[ -z "$key" ]]; then
        log::error "Configuration key required"
        exit 1
    fi
    
    log::info "Getting configuration for: $key"
    echo "value_for_$key"
}

config_set() {
    local key="${1:-}"
    local value="${2:-}"
    
    if [[ -z "$key" ]] || [[ -z "$value" ]]; then
        log::error "Both key and value required"
        echo "Usage: $(basename "$0") config set <key> <value>"
        exit 1
    fi
    
    log::info "Setting $key = $value"
    log::success "Configuration updated"
}

config_list() {
    log::info "Current configuration:"
    echo "setting1 = value1"
    echo "setting2 = value2"
    echo "setting3 = value3"
}

config_help() {
    cat << EOF
Usage: $(basename "$0") config <subcommand> [options]

Configuration management commands.

SUBCOMMANDS:
    get <key>        Get configuration value
    set <key> <value> Set configuration value
    list, ls         List all configuration
    help             Show this help

EXAMPLES:
    $(basename "$0") config get timeout
    $(basename "$0") config set timeout 30
    $(basename "$0") config list
EOF
}

# Status command
cmd_status() {
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                status_help
                exit 0
                ;;
            *)
                log::error "Unknown option: $1"
                status_help
                exit 1
                ;;
        esac
    done
    
    log::info "System Status"
    echo "✓ Service A: Running"
    echo "✓ Service B: Running"
    echo "⚠ Service C: Warning"
    
    if [[ "$verbose" == true ]]; then
        echo
        log::info "Detailed Status:"
        echo "  Service A: Uptime 5 days, Memory 45%"
        echo "  Service B: Uptime 2 days, Memory 32%"
        echo "  Service C: Uptime 1 hour, Memory 78%"
    fi
}

status_help() {
    cat << EOF
Usage: $(basename "$0") status [options]

Show system status information.

OPTIONS:
    -v, --verbose    Show detailed status information
    -h, --help       Show this help

EXAMPLES:
    $(basename "$0") status
    $(basename "$0") status --verbose
EOF
}

main() {
    local verbose=false
    local quiet=false
    
    # Parse global options first
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
            --verbose)
                verbose=true
                shift
                ;;
            --quiet)
                quiet=true
                shift
                ;;
            -*)
                log::error "Unknown global option: $1"
                show_help
                exit 1
                ;;
            *)
                # First non-option argument is the command
                break
                ;;
        esac
    done
    
    # Must have a command
    if [[ $# -eq 0 ]]; then
        log::error "Command required"
        show_help
        exit 1
    fi
    
    local command="$1"
    shift
    
    # Dispatch to command handlers
    case "$command" in
        status)
            cmd_status "$@"
            ;;
        config)
            cmd_config "$@"
            ;;
        deploy)
            cmd_deploy "$@"
            ;;
        backup)
            cmd_backup "$@"
            ;;
        monitor)
            cmd_monitor "$@"
            ;;
        *)
            log::error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
```

## 🔗 Polyglot Integration Examples

### 6. Bash + Python Integration

Demonstrates calling Python scripts from Bash:

```bash
#!/bin/bash

# polyglot-example - Demonstrates Bash + Python integration
# This script shows how to seamlessly call Python scripts from Bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

main() {
    local input_file="${1:-}"
    
    if [[ -z "$input_file" ]]; then
        log::error "Input file required"
        echo "Usage: $(basename "$0") <input_file>"
        exit 1
    fi
    
    if [[ ! -r "$input_file" ]]; then
        log::error "Cannot read input file: $input_file"
        exit 1
    fi
    
    log::info "Processing file with Python script..."
    
    # Call Python script using the run::script utility
    if run::script "${SHELL_STARTER_ROOT}/scripts/analyze.py" "$input_file"; then
        log::success "Python analysis completed successfully"
    else
        log::error "Python analysis failed"
        exit 1
    fi
    
    log::info "Bash post-processing..."
    # Additional bash processing here
    
    log::success "All processing completed!"
}

main "$@"
```

### 7. API Integration Script

Example of calling external APIs with error handling:

```bash
#!/bin/bash

# ai-action - Template for AI API integration
# Demonstrates secure API key handling and JSON response processing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

# Configuration
API_URL="${API_URL:-https://api.openai.com/v1/chat/completions}"
CONFIG_FILE="$HOME/.config/shell-starter/ai-config"

check_dependencies() {
    local deps=("curl" "jq")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log::error "Required dependencies missing: ${missing[*]}"
        log::info "Please install them and try again"
        exit 1
    fi
}

get_api_key() {
    local api_key
    
    # Try environment variable first
    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
        echo "$OPENAI_API_KEY"
        return 0
    fi
    
    # Try config file
    if [[ -r "$CONFIG_FILE" ]]; then
        api_key=$(grep "^api_key=" "$CONFIG_FILE" | cut -d'=' -f2-)
        if [[ -n "$api_key" ]]; then
            echo "$api_key"
            return 0
        fi
    fi
    
    log::error "API key not found"
    log::info "Set OPENAI_API_KEY environment variable or add to $CONFIG_FILE"
    return 1
}

call_ai_api() {
    local prompt="$1"
    local api_key="$2"
    local response
    local http_code
    
    log::info "Calling AI API..."
    spinner::start "Processing request"
    
    # Prepare JSON payload
    local json_payload
    json_payload=$(jq -n \
        --arg model "gpt-3.5-turbo" \
        --arg prompt "$prompt" \
        '{
            model: $model,
            messages: [
                {
                    role: "user",
                    content: $prompt
                }
            ],
            max_tokens: 150,
            temperature: 0.7
        }')
    
    # Make API call
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$API_URL")
    
    spinner::stop
    
    # Parse response and HTTP code
    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')
    
    if [[ "$http_code" -ne 200 ]]; then
        log::error "API call failed with HTTP $http_code"
        echo "$response" | jq -r '.error.message // "Unknown error"' >&2
        return 1
    fi
    
    # Extract and display the response
    local ai_response
    ai_response=$(echo "$response" | jq -r '.choices[0].message.content')
    
    log::success "AI Response:"
    echo "$ai_response"
}

main() {
    local prompt="${1:-}"
    
    if [[ -z "$prompt" ]]; then
        log::error "Prompt required"
        echo "Usage: $(basename "$0") \"<your prompt>\""
        exit 1
    fi
    
    check_dependencies
    
    local api_key
    if ! api_key=$(get_api_key); then
        exit 1
    fi
    
    call_ai_api "$prompt" "$api_key"
}

main "$@"
```

## 🧪 Testing Examples

### 8. Bats Test File

Example test file structure:

```bash
#!/usr/bin/env bats

# tests/hello-world.bats - Tests for the hello-world script

# Setup function runs before each test
setup() {
    # Add the bin directory to PATH for testing
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
    
    # Create temporary directory for test files
    export BATS_TMPDIR="$(mktemp -d)"
}

# Teardown function runs after each test
teardown() {
    # Clean up temporary files
    [[ -n "$BATS_TMPDIR" ]] && rm -rf "$BATS_TMPDIR"
}

@test "hello-world shows help when --help flag is used" {
    run hello-world --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "hello-world" ]]
}

@test "hello-world shows version when --version flag is used" {
    run hello-world --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "hello-world" ]]
    [[ "$output" =~ "0.1.0" ]]
}

@test "hello-world greets World by default" {
    run hello-world --quiet
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Hello, World!" ]]
}

@test "hello-world greets custom name" {
    run hello-world --quiet "Alice"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Hello, Alice!" ]]
}

@test "hello-world fails with unknown option" {
    run hello-world --unknown-option
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown option" ]]
}

@test "hello-world accepts multiple arguments (uses first)" {
    run hello-world --quiet "Alice" "Bob" "Charlie"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Hello, Alice!" ]]
}
```

These examples demonstrate the full range of Shell Starter capabilities and provide templates for creating robust, maintainable bash scripts. Each example includes proper error handling, user feedback, and follows the established conventions.