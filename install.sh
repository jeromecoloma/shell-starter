#!/bin/bash

set -euo pipefail

# Shell Starter Installer
# This script installs CLI scripts from the bin/ directory to a specified location

# Configuration
DEFAULT_PREFIX="$HOME/.config/shell-starter/bin"
MANIFEST_DIR="${MANIFEST_DIR:-$HOME/.config/shell-starter}"
MANIFEST_FILE="${MANIFEST_FILE:-$MANIFEST_DIR/install-manifest.txt}"

# GitHub repository configuration
GITHUB_REPO="${GITHUB_REPO:-shell-starter/shell-starter}"
GITHUB_API_URL="https://api.github.com"
TEMP_DIR="${TMPDIR:-/tmp}/shell-starter-install-$$"

# Network configuration for fallback mechanisms
CURL_TIMEOUT="${CURL_TIMEOUT:-30}"
CURL_RETRY_COUNT="${CURL_RETRY_COUNT:-3}"
CURL_RETRY_DELAY="${CURL_RETRY_DELAY:-2}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Detect user's shell configuration file
detect_shell_config() {
	local shell_name
	shell_name=$(basename "$SHELL")

	case "$shell_name" in
	zsh)
		echo "$HOME/.zshrc"
		;;
	bash)
		# Check for .bashrc first, then .bash_profile
		if [[ -f "$HOME/.bashrc" ]]; then
			echo "$HOME/.bashrc"
		else
			echo "$HOME/.bash_profile"
		fi
		;;
	fish)
		echo "$HOME/.config/fish/config.fish"
		;;
	*)
		# Default to .bashrc for unknown shells
		echo "$HOME/.bashrc"
		;;
	esac
}

# Add directory to PATH in shell configuration
add_to_path() {
	local config_file="$1"
	local path_to_add="$2"

	# Check if PATH entry already exists
	if grep -q "export PATH.*$path_to_add" "$config_file" 2>/dev/null; then
		log_info "PATH entry already exists in $config_file"
		return 0
	fi

	log_info "Adding $path_to_add to PATH in $config_file"

	# Create config file if it doesn't exist
	if [[ ! -f "$config_file" ]]; then
		touch "$config_file"
		log_info "Created new config file: $config_file"
	fi

	# Add PATH export to the end of the file
	echo "" >>"$config_file"
	echo "# Added by shell-starter installer" >>"$config_file"
	echo "export PATH=\"$path_to_add:\$PATH\"" >>"$config_file"

	log_success "Added PATH entry to $config_file"
}

# Show usage information
show_help() {
	cat <<EOF
Shell Starter Installer

Usage: $0 [OPTIONS]

DESCRIPTION:
    This installer copies CLI scripts from the bin/ directory to your system
    and automatically adds the installation directory to your PATH environment
    variable so you can run the scripts from anywhere.

    The installer can work in two modes:
    1. Local mode: Install from current directory (default)
    2. Remote mode: Download and install from GitHub releases

OPTIONS:
    --prefix PATH         Install scripts to PATH (default: $DEFAULT_PREFIX)
    --from-github         Download and install from GitHub releases (latest)
    --version VERSION     Install specific version from GitHub (automatically enables --from-github)
    --help, -h            Show this help message

EXAMPLES:
    $0                                    # Install from current directory
    $0 --prefix /home/user/bin            # Install to custom location
    $0 --from-github                      # Install latest release from GitHub
    $0 --version v1.2.3                   # Install specific version from GitHub
    $0 --from-github --version v1.2.3     # Install specific version (explicit GitHub mode)

    # Remote installation via curl
    curl -fsSL https://raw.githubusercontent.com/user/repo/main/install.sh | bash
    curl -fsSL https://raw.githubusercontent.com/user/repo/main/install.sh | bash -s -- --from-github
    curl -fsSL https://raw.githubusercontent.com/user/repo/main/install.sh | bash -s -- --version v1.2.3

NETWORK CONFIGURATION:
    The following environment variables can be set to configure network behavior:

    CURL_TIMEOUT=30          # Connection timeout in seconds (default: 30)
    CURL_RETRY_COUNT=3       # Number of retry attempts (default: 3)
    CURL_RETRY_DELAY=2       # Initial delay between retries in seconds (default: 2)

    Example with custom network settings:
    CURL_TIMEOUT=60 CURL_RETRY_COUNT=5 $0 --from-github

SECURITY NOTE:
    This installer can be run via 'curl | bash' for convenience, but be aware
    this poses security risks. Always review scripts before executing them.

EOF
}

# Parse command line arguments
parse_args() {
	PREFIX="$DEFAULT_PREFIX"
	FROM_GITHUB=false
	VERSION=""

	while [[ $# -gt 0 ]]; do
		case $1 in
		--prefix)
			PREFIX="$2"
			shift 2
			;;
		--from-github)
			FROM_GITHUB=true
			shift
			;;
		--version)
			VERSION="$2"
			shift 2
			;;
		--help | -h)
			show_help
			exit 0
			;;
		*)
			log_error "Unknown option: $1"
			show_help
			exit 1
			;;
		esac
	done

	# Validate arguments and auto-enable GitHub mode when version is specified
	if [[ -n "$VERSION" ]]; then
		FROM_GITHUB=true
		log_info "Version specified, automatically enabling GitHub release download"

		# Basic version format validation (allows v1.2.3, 1.2.3, latest, etc.)
		if [[ ! "$VERSION" =~ ^(v?[0-9]+\.[0-9]+\.[0-9]+|latest|main|master)$ ]]; then
			log_warn "Version format '$VERSION' may not be recognized. Expected formats: v1.2.3, 1.2.3, latest"
		fi
	fi
}

# Robust HTTP request function with retry logic and fallback mechanisms
http_request() {
	local url="$1"
	local output_file="${2:-}"
	local max_retries="${CURL_RETRY_COUNT}"
	local retry_delay="${CURL_RETRY_DELAY}"
	local timeout="${CURL_TIMEOUT}"

	# Check if curl is available
	if ! command -v curl >/dev/null 2>&1; then
		log_error "curl is required but not installed"
		return 1
	fi

	log_info "Making HTTP request to: $url"

	local attempt=1
	while [[ $attempt -le $max_retries ]]; do
		log_info "Attempt $attempt of $max_retries..."

		local curl_cmd="curl -fsSL --connect-timeout $timeout --max-time $((timeout * 2))"

		# Add user agent for better compatibility
		curl_cmd="$curl_cmd -A 'shell-starter-installer/1.0'"

		# Add output file if specified
		if [[ -n "$output_file" ]]; then
			curl_cmd="$curl_cmd -o '$output_file'"
		fi

		curl_cmd="$curl_cmd '$url'"

		# Execute curl command
		local response
		if [[ -n "$output_file" ]]; then
			if eval "$curl_cmd" 2>/dev/null; then
				log_info "HTTP request successful"
				return 0
			fi
		else
			if response=$(eval "$curl_cmd" 2>/dev/null); then
				echo "$response"
				log_info "HTTP request successful"
				return 0
			fi
		fi

		local curl_exit_code=$?
		log_warn "HTTP request failed (exit code: $curl_exit_code)"

		# Check for specific network errors
		case $curl_exit_code in
		6) log_warn "Could not resolve host. Check your internet connection." ;;
		7) log_warn "Failed to connect to host. Server may be down or unreachable." ;;
		28) log_warn "Operation timeout. Server is responding slowly." ;;
		35) log_warn "SSL/TLS handshake failed. Security certificate issues." ;;
		*) log_warn "Network request failed with exit code $curl_exit_code" ;;
		esac

		if [[ $attempt -lt $max_retries ]]; then
			log_info "Retrying in ${retry_delay}s..."
			sleep "$retry_delay"
			# Exponential backoff
			retry_delay=$((retry_delay * 2))
		fi

		((attempt++))
	done

	log_error "All HTTP request attempts failed after $max_retries tries"
	return 1
}

# Check network connectivity
check_network_connectivity() {
	log_info "Checking network connectivity..."

	# Test connectivity to GitHub
	if http_request "https://api.github.com" >/dev/null 2>&1; then
		log_info "Network connectivity confirmed"
		return 0
	fi

	log_warn "Cannot reach GitHub API. Checking general internet connectivity..."

	# Fallback: test connectivity to a reliable service
	local test_urls=(
		"https://httpbin.org/status/200"
		"https://www.google.com"
		"https://cloudflare.com"
	)

	for url in "${test_urls[@]}"; do
		if curl -fsSL --connect-timeout 10 --max-time 15 "$url" >/dev/null 2>&1; then
			log_warn "Internet is accessible, but GitHub may be unreachable"
			return 1
		fi
	done

	log_error "No internet connectivity detected"
	return 2
}

# Create manifest directory if it doesn't exist
create_manifest_dir() {
	if [[ ! -d "$MANIFEST_DIR" ]]; then
		log_info "Creating manifest directory: $MANIFEST_DIR"
		mkdir -p "$MANIFEST_DIR"
	fi
}

# Initialize manifest file
init_manifest() {
	log_info "Initializing install manifest: $MANIFEST_FILE"
	echo "# Shell Starter Install Manifest" >"$MANIFEST_FILE"
	echo "# Generated on $(date)" >>"$MANIFEST_FILE"
	echo "# Install prefix: $PREFIX" >>"$MANIFEST_FILE"
	echo "" >>"$MANIFEST_FILE"
}

# Function to get the latest release from GitHub
get_latest_release() {
	local repo="${1:-$GITHUB_REPO}"
	local api_url="${GITHUB_API_URL}/repos/${repo}/releases/latest"

	log_info "Fetching latest release from GitHub..."

	# Check network connectivity first
	local connectivity_status
	check_network_connectivity
	connectivity_status=$?

	if [[ $connectivity_status -eq 2 ]]; then
		log_error "No internet connectivity available"
		return 1
	elif [[ $connectivity_status -eq 1 ]]; then
		log_warn "GitHub may be unreachable, but attempting request anyway..."
	fi

	# Use robust HTTP request with retries
	local response
	if ! response=$(http_request "$api_url"); then
		log_error "Failed to fetch release information after multiple attempts"
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
		log_error "Could not parse release information"
		return 1
	fi

	echo "$tag_name"
	return 0
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

	log_info "Fetching release download URL..."

	# Use robust HTTP request with retries
	local response
	if ! response=$(http_request "$api_url"); then
		log_error "Failed to fetch release information after multiple attempts"

		# Try alternative download URL as fallback
		log_info "Attempting fallback download URL..."
		local fallback_url="https://github.com/${repo}/archive/refs/tags/${tag}.tar.gz"

		if [[ "$tag" == "latest" ]]; then
			# For latest, try main branch
			fallback_url="https://github.com/${repo}/archive/refs/heads/main.tar.gz"
		fi

		log_info "Using fallback download URL: $fallback_url"
		echo "$fallback_url"
		return 0
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
		log_error "Could not parse download URL from release information"
		return 1
	fi

	echo "$download_url"
	return 0
}

# Function to download and extract release from GitHub
download_github_release() {
	local version="${1:-latest}"
	local temp_dir="$TEMP_DIR"

	log_info "Downloading Shell Starter from GitHub (version: $version)..."

	# Create temporary directory
	if ! mkdir -p "$temp_dir"; then
		log_error "Failed to create temporary directory: $temp_dir"
		return 1
	fi

	# Get download URL
	local download_url
	if ! download_url=$(get_release_download_url "$GITHUB_REPO" "$version"); then
		rm -rf "$temp_dir"
		return 1
	fi

	# Download the tarball using robust HTTP request
	local tarball_path="$temp_dir/release.tar.gz"
	log_info "Downloading tarball from: $download_url"

	if ! http_request "$download_url" "$tarball_path"; then
		log_error "Failed to download release tarball after multiple attempts"

		# Try direct branch download as final fallback
		log_info "Attempting final fallback: downloading from main branch..."
		local fallback_url="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.tar.gz"

		if ! http_request "$fallback_url" "$tarball_path"; then
			log_error "All download attempts failed"
			rm -rf "$temp_dir"
			return 1
		fi

		log_warn "Using main branch instead of requested version $version"
	fi

	# Verify the downloaded file exists and has content
	if [[ ! -f "$tarball_path" || ! -s "$tarball_path" ]]; then
		log_error "Downloaded file is missing or empty"
		rm -rf "$temp_dir"
		return 1
	fi

	# Extract the tarball
	if ! tar -xzf "$tarball_path" -C "$temp_dir" --strip-components=1; then
		log_error "Failed to extract release tarball"
		rm -rf "$temp_dir"
		return 1
	fi

	# Remove the tarball to save space
	rm -f "$tarball_path"

	log_success "Successfully downloaded and extracted release"
	echo "$temp_dir"
}

# Function to cleanup temporary directory
cleanup_temp_dir() {
	if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
		log_info "Cleaning up temporary files..."
		rm -rf "$TEMP_DIR"
	fi
}

# Install scripts from bin/ directory
install_scripts() {
	local script_count=0
	local working_dir="."

	# If installing from GitHub, download and extract first
	if [[ "$FROM_GITHUB" == true ]]; then
		local version_to_install="${VERSION:-latest}"
		if ! working_dir=$(download_github_release "$version_to_install"); then
			log_error "Failed to download release from GitHub"
			exit 1
		fi

		# Set up cleanup trap
		trap cleanup_temp_dir EXIT
	fi

	# Check if bin directory exists in working directory
	if [[ ! -d "$working_dir/bin" ]]; then
		if [[ "$FROM_GITHUB" == true ]]; then
			log_error "Downloaded release does not contain a 'bin' directory"
			cleanup_temp_dir
		else
			log_error "No 'bin' directory found. Are you running this from the project root?"
		fi
		exit 1
	fi

	# Check if PREFIX directory exists, create if needed
	if [[ ! -d "$PREFIX" ]]; then
		log_info "Creating install directory: $PREFIX"
		mkdir -p "$PREFIX"
	fi

	# Install each script in bin/
	for script in "$working_dir"/bin/*; do
		if [[ -f "$script" && -x "$script" ]]; then
			local script_name
			script_name=$(basename "$script")
			local dest_path="$PREFIX/$script_name"

			log_info "Installing $script_name -> $dest_path"

			# Copy script to destination
			cp "$script" "$dest_path"
			chmod +x "$dest_path"

			# Record in manifest
			echo "$dest_path" >>"$MANIFEST_FILE"

			((script_count++))
		fi
	done

	if [[ $script_count -eq 0 ]]; then
		log_warn "No executable scripts found in bin/ directory"
	else
		log_success "Installed $script_count script(s)"
	fi
}

# Main installation process
main() {
	parse_args "$@"

	if [[ "$FROM_GITHUB" == true ]]; then
		local version_msg="${VERSION:-latest}"
		log_info "Starting Shell Starter installation from GitHub (version: $version_msg)..."

		# Early network connectivity check for GitHub installations
		if ! check_network_connectivity >/dev/null 2>&1; then
			log_error "Network installation requested but no internet connectivity available"
			log_info "To install from a local directory instead, run without --from-github or --version flags"
			log_info "Example: $0 --prefix $PREFIX"
			exit 1
		fi
	else
		log_info "Starting Shell Starter installation from local directory..."
	fi

	create_manifest_dir
	init_manifest

	# Install scripts with enhanced error handling
	if ! install_scripts; then
		log_error "Installation failed"
		if [[ "$FROM_GITHUB" == true ]]; then
			log_info "Network issues detected. Try again later or install from a local directory"
			log_info "You can also try setting these environment variables for better network handling:"
			log_info "  export CURL_TIMEOUT=60"
			log_info "  export CURL_RETRY_COUNT=5"
			log_info "  export CURL_RETRY_DELAY=3"
		fi
		exit 1
	fi

	# Setup PATH in shell configuration
	local shell_config
	shell_config=$(detect_shell_config)
	add_to_path "$shell_config" "$PREFIX"

	log_success "Installation complete!"
	if [[ "$FROM_GITHUB" == true ]]; then
		local version_msg="${VERSION:-latest}"
		log_info "Installed Shell Starter from GitHub (version: $version_msg)"
	fi
	log_info "Scripts installed to: $PREFIX"
	log_info "Install manifest saved to: $MANIFEST_FILE"
	log_info "PATH updated in: $shell_config"
	log_info "Please run 'source $shell_config' or restart your shell to use the installed scripts"
	log_info "Use 'curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/main/uninstall.sh | bash' to uninstall"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
	main "$@"
fi
