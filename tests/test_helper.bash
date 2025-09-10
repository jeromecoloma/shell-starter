#!/usr/bin/env bash

# Bats test helper functions
# This file is sourced by all test files

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source the main library
source "${PROJECT_ROOT}/lib/main.sh"

# Test utilities
setup() {
    # Common setup for all tests
    export SHELL_STARTER_TEST=1
}

teardown() {
    # Common cleanup for all tests
    unset SHELL_STARTER_TEST
}

# Helper function to run scripts and capture output
run_script() {
    local script_name="$1"
    shift
    run "${PROJECT_ROOT}/bin/${script_name}" "$@"
}

# Helper function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}