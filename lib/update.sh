#!/bin/bash

# Shell Starter - Update Management Functions
# Provides version comparison and GitHub API functions for update management

# Source logging if not already sourced
if [[ -z "${COLOR_RESET:-}" ]]; then
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	source "${SCRIPT_DIR}/colors.sh"
	source "${SCRIPT_DIR}/logging.sh"
fi

# GitHub repository configuration
GITHUB_REPO="${GITHUB_REPO:-shell-starter/shell-starter}"
GITHUB_API_URL="https://api.github.com"

# Function to compare semantic versions
# Returns: 0 if v1 == v2, 1 if v1 > v2, 2 if v1 < v2
version_compare() {
	local v1="$1"
	local v2="$2"

	# Remove 'v' prefix if present
	v1="${v1#v}"
	v2="${v2#v}"

	# Split versions into arrays
	IFS='.' read -ra V1_PARTS <<<"$v1"
	IFS='.' read -ra V2_PARTS <<<"$v2"

	# Pad arrays to same length
	local max_length=$((${#V1_PARTS[@]} > ${#V2_PARTS[@]} ? ${#V1_PARTS[@]} : ${#V2_PARTS[@]}))

	for ((i = 0; i < max_length; i++)); do
		local part1="${V1_PARTS[i]:-0}"
		local part2="${V2_PARTS[i]:-0}"

		# Remove leading zeros and handle empty parts
		part1=$((10#${part1:-0}))
		part2=$((10#${part2:-0}))

		if ((part1 > part2)); then
			return 1 # v1 > v2
		elif ((part1 < part2)); then
			return 2 # v1 < v2
		fi
	done

	return 0 # v1 == v2
}

# Function to get the latest release from GitHub
get_latest_release() {
	local repo="${1:-$GITHUB_REPO}"
	local api_url="${GITHUB_API_URL}/repos/${repo}/releases/latest"

	log::debug "Fetching latest release from: $api_url"

	# Use curl to fetch the latest release info
	local response
	if command -v curl >/dev/null 2>&1; then
		response=$(curl -s "$api_url" 2>/dev/null)
		local curl_exit_code=$?

		if [[ $curl_exit_code -ne 0 ]]; then
			log::error "Failed to fetch release information (curl exit code: $curl_exit_code)"
			return 1
		fi
	else
		log::error "curl is required but not installed"
		return 1
	fi

	# Parse the JSON response to extract tag_name
	local tag_name
	if command -v jq >/dev/null 2>&1; then
		tag_name=$(echo "$response" | jq -r '.tag_name' 2>/dev/null)
	else
		# Fallback parsing without jq
		tag_name=$(echo "$response" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
	fi

	if [[ -z "$tag_name" || "$tag_name" == "null" ]]; then
		log::error "Could not parse release information"
		return 1
	fi

	echo "$tag_name"
	return 0
}

# Function to check if an update is available
check_for_update() {
	local current_version="${1:-$(get_version)}"
	local repo="${2:-$GITHUB_REPO}"

	log::debug "Checking for updates. Current version: $current_version"

	local latest_version
	latest_version=$(get_latest_release "$repo")
	local fetch_exit_code=$?

	if [[ $fetch_exit_code -ne 0 ]]; then
		log::error "Failed to check for updates"
		return 1
	fi

	log::debug "Latest version: $latest_version"

	# Compare versions
	version_compare "$current_version" "$latest_version"
	local comparison_result=$?

	case $comparison_result in
	0)
		log::info "You are running the latest version ($current_version)"
		return 1 # No update available
		;;
	1)
		log::info "You are running a newer version ($current_version) than the latest release ($latest_version)"
		return 1 # No update needed
		;;
	2)
		log::info "Update available: $current_version → $latest_version"
		echo "$latest_version"
		return 0 # Update available
		;;
	esac
}

# Function to get download URL for a specific release
get_release_download_url() {
	local repo="${1:-$GITHUB_REPO}"
	local tag="${2:-latest}"
	local api_url

	if [[ "$tag" == "latest" ]]; then
		api_url="${GITHUB_API_URL}/repos/${repo}/releases/latest"
	else
		api_url="${GITHUB_API_URL}/repos/${repo}/releases/tags/${tag}"
	fi

	log::debug "Fetching release download URL from: $api_url"

	local response
	if command -v curl >/dev/null 2>&1; then
		response=$(curl -s "$api_url" 2>/dev/null)
		local curl_exit_code=$?

		if [[ $curl_exit_code -ne 0 ]]; then
			log::error "Failed to fetch release information (curl exit code: $curl_exit_code)"
			return 1
		fi
	else
		log::error "curl is required but not installed"
		return 1
	fi

	# Parse the JSON response to extract tarball_url
	local download_url
	if command -v jq >/dev/null 2>&1; then
		download_url=$(echo "$response" | jq -r '.tarball_url' 2>/dev/null)
	else
		# Fallback parsing without jq
		download_url=$(echo "$response" | grep -o '"tarball_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"tarball_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
	fi

	if [[ -z "$download_url" || "$download_url" == "null" ]]; then
		log::error "Could not parse download URL from release information"
		return 1
	fi

	echo "$download_url"
	return 0
}

# Function to display update information
update::info() {
	local current_version="${1:-$(get_version)}"
	local repo="${2:-$GITHUB_REPO}"

	echo "Update Check for $repo"
	echo "Current version: $current_version"

	local latest_version
	latest_version=$(check_for_update "$current_version" "$repo")
	local check_exit_code=$?

	if [[ $check_exit_code -eq 0 ]]; then
		echo "Latest version: $latest_version"
		echo "Update available!"
		return 0
	else
		echo "No update available."
		return 1
	fi
}
