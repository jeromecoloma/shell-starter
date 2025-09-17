#!/usr/bin/env bash
#
# CI-optimized test runner for Bats tests
# This script runs tests with better timeout handling and progress reporting

set -euo pipefail

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if Bats is available, auto-setup if missing
if [ ! -f "$PROJECT_ROOT/tests/bats-core/bin/bats" ]; then
	echo "⚠️  Bats-core not found. Attempting automatic setup..."

	# Try to run setup script if it exists
	if [ -f "$PROJECT_ROOT/scripts/setup-bats.sh" ]; then
		echo "Running scripts/setup-bats.sh..."
		if "$PROJECT_ROOT/scripts/setup-bats.sh"; then
			echo "✅ Bats-core setup completed successfully"
		else
			echo "❌ Bats setup failed. Skipping tests." >&2
			echo "   This is expected for user projects that don't need testing." >&2
			echo "   To manually set up testing, run: ./scripts/setup-bats.sh" >&2
			exit 0
		fi
	else
		echo "⚠️  No setup script found. Skipping tests." >&2
		echo "   This is expected for user projects that don't need testing." >&2
		echo "   To set up testing, ensure scripts/setup-bats.sh exists and run it." >&2
		exit 0
	fi

	# Verify setup worked
	if [ ! -f "$PROJECT_ROOT/tests/bats-core/bin/bats" ]; then
		echo "❌ Bats-core still not found after setup attempt. Skipping tests." >&2
		exit 0
	fi
fi

# Set up comprehensive CI environment
if [[ -f "$PROJECT_ROOT/tests/setup-ci-environment.sh" ]]; then
	echo "🔧 Setting up CI environment..."
	# shellcheck source=tests/setup-ci-environment.sh
	source "$PROJECT_ROOT/tests/setup-ci-environment.sh"
else
	echo "⚠️  CI environment setup script not found, using basic setup"
	export CI=true
	export SHELL_STARTER_CI_MODE=true
fi

# Check if we should run integration tests
RUN_INTEGRATION_TESTS=false
if [[ -z "${ACT:-}" ]] && [[ -z "${GITHUB_ACTIONS:-}" ]] && [[ "${SHELL_STARTER_RUN_INTEGRATION_TESTS:-}" == "true" ]]; then
	RUN_INTEGRATION_TESTS=true
fi

echo "Running tests in CI mode with individual file execution..."
echo "======================================================="

# Show information about integration tests
if [[ "$RUN_INTEGRATION_TESTS" == "false" ]]; then
	echo "ℹ️  Integration tests are skipped in containerized CI environments"
	echo "   To run integration tests locally, set: SHELL_STARTER_RUN_INTEGRATION_TESTS=true"
	echo ""
fi

# Test files in a specific order to isolate problematic tests
test_files=(
	"tests/framework.bats"
	"tests/lib-colors.bats"
	"tests/lib-logging.bats"
	"tests/lib-utils.bats"
	"tests/lib-main.bats"
	"tests/hello-world.bats"
	"tests/lib-spinner.bats"
	"tests/lib-integration.bats"
)

total_tests=0
passed_tests=0
failed_files=()

for test_file in "${test_files[@]}"; do
	if [ ! -f "$PROJECT_ROOT/$test_file" ]; then
		echo "⚠️  Test file not found: $test_file"
		continue
	fi

	echo ""
	echo "Running: $test_file"
	echo "$(printf '%.50s' "------------------------------------------------")"

	# Run each test file with timeout (if available)
	if command -v timeout >/dev/null 2>&1; then
		# Use timeout if available (most Linux systems)
		if timeout 120s "$PROJECT_ROOT/tests/bats-core/bin/bats" "$PROJECT_ROOT/$test_file"; then
			file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
			echo "✅ Passed: $test_file ($file_tests tests)"
			total_tests=$((total_tests + file_tests))
			passed_tests=$((passed_tests + file_tests))
		else
			exit_code=$?
			echo "❌ Failed: $test_file (exit code: $exit_code)"
			failed_files+=("$test_file")
			if [ $exit_code -eq 124 ]; then
				echo "   Reason: Test timed out after 2 minutes"
			fi
			file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
			total_tests=$((total_tests + file_tests))
		fi
	else
		# Run without timeout in containers that don't support it
		echo "⚠️  Running without timeout (not available in this environment)"
		if "$PROJECT_ROOT/tests/bats-core/bin/bats" "$PROJECT_ROOT/$test_file"; then
			file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
			echo "✅ Passed: $test_file ($file_tests tests)"
			total_tests=$((total_tests + file_tests))
			passed_tests=$((passed_tests + file_tests))
		else
			exit_code=$?
			echo "❌ Failed: $test_file (exit code: $exit_code)"
			failed_files+=("$test_file")
			file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
			total_tests=$((total_tests + file_tests))
		fi
	fi
done

# Run integration tests with longer timeouts and special handling
if [[ "$RUN_INTEGRATION_TESTS" == "true" ]]; then
	echo ""
	echo "Running Integration Tests..."
	echo "============================"

	integration_test_files=(
		"tests/integration-workflow.bats"
		"tests/e2e-installation.bats"
		"tests/network-mocking.bats"
	)

	for test_file in "${integration_test_files[@]}"; do
		if [ ! -f "$PROJECT_ROOT/$test_file" ]; then
			echo "⚠️  Integration test file not found: $test_file"
			continue
		fi

		echo ""
		echo "Running: $test_file"
		echo "$(printf '%.50s' "------------------------------------------------")"

		# Set integration test environment
		export SHELL_STARTER_INTEGRATION_TEST=true

		# Run integration tests with extended timeout
		if command -v timeout >/dev/null 2>&1; then
			# Use longer timeout for integration tests (5 minutes)
			if timeout 300s "$PROJECT_ROOT/tests/bats-core/bin/bats" "$PROJECT_ROOT/$test_file"; then
				file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
				echo "✅ Passed: $test_file ($file_tests integration tests)"
				total_tests=$((total_tests + file_tests))
				passed_tests=$((passed_tests + file_tests))
			else
				exit_code=$?
				echo "❌ Failed: $test_file (exit code: $exit_code)"
				failed_files+=("$test_file")
				if [ $exit_code -eq 124 ]; then
					echo "   Reason: Integration test timed out after 5 minutes"
				fi
				file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
				total_tests=$((total_tests + file_tests))
			fi
		else
			# Run without timeout but with warning
			echo "⚠️  Running integration tests without timeout (may take longer)"
			if "$PROJECT_ROOT/tests/bats-core/bin/bats" "$PROJECT_ROOT/$test_file"; then
				file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
				echo "✅ Passed: $test_file ($file_tests integration tests)"
				total_tests=$((total_tests + file_tests))
				passed_tests=$((passed_tests + file_tests))
			else
				exit_code=$?
				echo "❌ Failed: $test_file (exit code: $exit_code)"
				failed_files+=("$test_file")
				file_tests=$(grep -c "^@test" "$PROJECT_ROOT/$test_file" 2>/dev/null || echo 0)
				total_tests=$((total_tests + file_tests))
			fi
		fi

		# Clean up integration test environment
		unset SHELL_STARTER_INTEGRATION_TEST
	done
fi

echo ""
echo "Test Summary"
echo "============"
echo "Total tests: $total_tests"
echo "Passed tests: $passed_tests"
echo "Failed tests: $((total_tests - passed_tests))"

if [ ${#failed_files[@]} -gt 0 ]; then
	echo ""
	echo "Failed test files:"
	for file in "${failed_files[@]}"; do
		echo "  - $file"
	done
	echo ""
	echo "❌ Some tests failed"
	exit 1
else
	echo ""
	echo "✅ All tests passed!"
	exit 0
fi
