#!/bin/bash

set -euo pipefail

# Shell Starter Installer
# Configuration
DEFAULT_PREFIX="$HOME/.config/shell-starter/bin"
DEFAULT_LIB_PREFIX="$HOME/.config/shell-starter/lib"
MANIFEST_DIR="${MANIFEST_DIR:-$HOME/.config/shell-starter}"
MANIFEST_FILE="$MANIFEST_DIR/install-manifest.txt"
GITHUB_REPO="${GITHUB_REPO:-shell-starter/shell-starter}"
TEMP_DIR="${TMPDIR:-/tmp}/shell-starter-install-$$"
CURL_TIMEOUT="${CURL_TIMEOUT:-30}"
CURL_RETRY_COUNT="${CURL_RETRY_COUNT:-3}"

# Colors
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'

# Unified logging function
log() {
	local level="$1" && shift
	case "$level" in
	error) echo -e "${RED}[ERROR]${NC} $*" ;;
	warn) echo -e "${YELLOW}[WARN]${NC} $*" ;;
	success) echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
	*) echo -e "${BLUE}[INFO]${NC} $*" ;;
	esac
}

# Detect shell config file
detect_shell_config() {
	case "$(basename "$SHELL")" in
	zsh) echo "$HOME/.zshrc" ;;
	bash) [[ -f "$HOME/.bashrc" ]] && echo "$HOME/.bashrc" || echo "$HOME/.bash_profile" ;;
	fish) echo "$HOME/.config/fish/config.fish" ;;
	*) echo "$HOME/.bashrc" ;;
	esac
}

# Add directory to PATH
add_to_path() {
	local config_file="$1" path_to_add="$2"

	if grep -q "export PATH.*$path_to_add" "$config_file" 2>/dev/null; then
		log info "PATH entry already exists in $config_file"
		return 0
	fi

	[[ ! -f "$config_file" ]] && touch "$config_file"
	{
		echo ""
		echo "# Added by shell-starter installer"
		echo "export PATH=\"$path_to_add:\$PATH\""
	} >>"$config_file"

	log success "Added PATH entry to $config_file"
}

# Show usage
show_help() {
	cat <<EOF
Shell Starter Installer

Usage: $0 [OPTIONS]

Install CLI scripts from bin/ directory to your system.

OPTIONS:
    --prefix PATH         Install scripts location (default: $DEFAULT_PREFIX)
    --lib-prefix PATH     Install libraries location (default: $DEFAULT_LIB_PREFIX)
    --from-github         Download from GitHub releases (latest)
    --version VERSION     Install specific version (enables --from-github)
    --uninstall           Remove Shell Starter installation
    --help, -h            Show this help

EXAMPLES:
    $0                    # Install from current directory
    $0 --from-github      # Install latest from GitHub
    $0 --version v1.2.3   # Install specific version
    $0 --uninstall        # Remove installation

EOF
}

# Parse arguments
parse_args() {
	PREFIX="$DEFAULT_PREFIX" LIB_PREFIX="$DEFAULT_LIB_PREFIX" FROM_GITHUB=false VERSION="" UNINSTALL=false

	while [[ $# -gt 0 ]]; do
		case $1 in
		--prefix)
			PREFIX="$2"
			# Set lib prefix relative to bin prefix if not explicitly set
			[[ "$LIB_PREFIX" == "$DEFAULT_LIB_PREFIX" ]] && LIB_PREFIX="$(dirname "$PREFIX")/lib"
			shift 2
			;;
		--lib-prefix)
			LIB_PREFIX="$2"
			shift 2
			;;
		--from-github)
			FROM_GITHUB=true
			shift
			;;
		--version)
			VERSION="$2"
			FROM_GITHUB=true
			shift 2
			;;
		--uninstall)
			UNINSTALL=true
			shift
			;;
		--help | -h)
			show_help
			exit 0
			;;
		*)
			log error "Unknown option: $1"
			show_help
			exit 1
			;;
		esac
	done

	[[ -n "$VERSION" && ! "$VERSION" =~ ^(v?[0-9]+\.[0-9]+\.[0-9]+|latest|main|master)$ ]] &&
		log warn "Version format '$VERSION' may not be recognized"
}

# HTTP request with retry
http_request() {
	local url="$1" output_file="${2:-}" attempt=1

	command -v curl >/dev/null || {
		log error "curl is required"
		return 1
	}

	while [[ $attempt -le $CURL_RETRY_COUNT ]]; do
		local curl_cmd="curl -fsSL --connect-timeout $CURL_TIMEOUT --max-time $((CURL_TIMEOUT * 2)) -A 'shell-starter-installer/1.0'"
		[[ -n "$output_file" ]] && curl_cmd="$curl_cmd -o '$output_file'"
		curl_cmd="$curl_cmd '$url'"

		if [[ -n "$output_file" ]]; then
			eval "$curl_cmd" 2>/dev/null && return 0
		else
			local response && response=$(eval "$curl_cmd" 2>/dev/null) && {
				echo "$response"
				return 0
			}
		fi

		log warn "Request failed (attempt $attempt/$CURL_RETRY_COUNT)"
		[[ $attempt -lt $CURL_RETRY_COUNT ]] && sleep $((attempt * 2))
		((attempt++))
	done

	log error "All HTTP requests failed"
	return 1
}

# Create manifest
init_manifest() {
	mkdir -p "$MANIFEST_DIR"
	{
		echo "# Shell Starter Install Manifest"
		echo "# Generated on $(date)"
		echo "# Scripts prefix: $PREFIX"
		echo "# Libraries prefix: $LIB_PREFIX"
		echo ""
	} >"$MANIFEST_FILE"
}

# Get GitHub release download URL
get_download_url() {
	local repo="${1:-$GITHUB_REPO}" tag="${2:-latest}"
	local api_url="https://api.github.com/repos/${repo}/releases"
	[[ "$tag" != "latest" ]] && api_url="$api_url/tags/$tag" || api_url="$api_url/latest"

	local response
	if ! response=$(http_request "$api_url"); then
		# Fallback to archive URL
		local fallback="https://github.com/${repo}/archive/refs"
		[[ "$tag" == "latest" ]] && fallback="$fallback/heads/main.tar.gz" || fallback="$fallback/tags/$tag.tar.gz"
		echo "$fallback"
		return 0
	fi

	# Parse tarball_url (with or without jq)
	local url
	if command -v jq >/dev/null; then
		url=$(echo "$response" | jq -r '.tarball_url' 2>/dev/null)
	else
		url=$(echo "$response" | grep -o '"tarball_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"tarball_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
	fi

	[[ -n "$url" && "$url" != "null" ]] && echo "$url" || return 1
}

# Download and extract from GitHub
download_release() {
	local version="${1:-latest}" temp_dir="$TEMP_DIR"

	mkdir -p "$temp_dir" || {
		log error "Failed to create temp dir"
		return 1
	}

	local download_url tarball="$temp_dir/release.tar.gz"
	download_url=$(get_download_url "$GITHUB_REPO" "$version") || {
		rm -rf "$temp_dir"
		return 1
	}

	if ! http_request "$download_url" "$tarball"; then
		log error "Download failed"
		rm -rf "$temp_dir"
		return 1
	fi

	tar -xzf "$tarball" -C "$temp_dir" --strip-components=1 || {
		log error "Extract failed"
		rm -rf "$temp_dir"
		return 1
	}

	rm -f "$tarball"
	echo "$temp_dir"
}

# Install scripts and libraries
install_scripts() {
	local working_dir="." script_count=0 lib_count=0

	# Download if from GitHub
	if [[ "$FROM_GITHUB" == true ]]; then
		working_dir=$(download_release "${VERSION:-latest}") || {
			log error "GitHub download failed"
			exit 1
		}
		trap 'rm -rf "$TEMP_DIR"' EXIT
	fi

	# Verify directories exist
	[[ -d "$working_dir/bin" ]] || {
		log error "No 'bin' directory found"
		exit 1
	}

	# Create install directories
	mkdir -p "$PREFIX" "$LIB_PREFIX"

	# Install scripts from bin/
	for script in "$working_dir"/bin/*; do
		if [[ -f "$script" && -x "$script" ]]; then
			local name dest_path
			name=$(basename "$script")
			dest_path="$PREFIX/$name"

			cp "$script" "$dest_path"
			chmod +x "$dest_path"
			echo "$dest_path" >>"$MANIFEST_FILE"
			((script_count++))
		fi
	done

	# Install libraries from lib/ if directory exists
	if [[ -d "$working_dir/lib" ]]; then
		for lib_file in "$working_dir"/lib/*; do
			if [[ -f "$lib_file" ]]; then
				local name dest_path
				name=$(basename "$lib_file")
				dest_path="$LIB_PREFIX/$name"

				cp "$lib_file" "$dest_path"
				chmod 644 "$dest_path"
				echo "$dest_path" >>"$MANIFEST_FILE"
				((lib_count++))
			fi
		done
	fi

	# Report installation results
	if [[ $script_count -eq 0 ]]; then
		log warn "No executable scripts found"
	else
		log success "Installed $script_count script(s)"
	fi

	if [[ $lib_count -gt 0 ]]; then
		log success "Installed $lib_count library file(s)"
	fi
}

# Remove PATH entry from shell configuration
remove_from_path() {
	local config_file="$1" path_to_remove="$2"

	[[ ! -f "$config_file" ]] && {
		log info "Shell config file not found: $config_file"
		return 0
	}

	grep -q "export PATH.*$path_to_remove" "$config_file" 2>/dev/null || {
		log info "PATH entry not found in $config_file"
		return 0
	}

	log info "Removing PATH entry from $config_file"

	local temp_file
	temp_file=$(mktemp)

	awk -v target_path="$path_to_remove" '
	/^# Added by shell-starter installer$/ {
		getline nextline
		if (index(nextline, target_path) == 0 || nextline !~ /^export PATH=/) {
			print $0
			print nextline
		}
		next
	}
	{ print }
	' "$config_file" >"$temp_file"

	if mv "$temp_file" "$config_file"; then
		log success "Removed PATH entry from $config_file"
	else
		log error "Failed to update $config_file"
		rm -f "$temp_file"
	fi
}

# Show files that will be removed
show_uninstall_files() {
	echo
	log info "The following files will be removed:"
	echo

	grep -v '^#' "$MANIFEST_FILE" | grep -v '^[[:space:]]*$' | while read -r file_path; do
		if [[ -f "$file_path" ]]; then
			echo "  🗑️  $file_path"
		else
			echo "  ❌ $file_path (not found)"
		fi
	done
	echo
}

# Get user confirmation for uninstall
get_uninstall_confirmation() {
	echo -e "${YELLOW}Are you sure you want to remove these files? [y/N]${NC} "
	read -r response

	case "$response" in
	[yY] | [yY][eE][sS])
		return 0
		;;
	*)
		log info "Uninstallation cancelled by user"
		exit 0
		;;
	esac
}

# Remove files listed in manifest
remove_files() {
	local removed_count=0 not_found_count=0

	log info "Starting file removal..."

	while IFS= read -r file_path; do
		[[ "$file_path" =~ ^#.*$ ]] || [[ -z "$file_path" ]] || [[ "$file_path" =~ ^[[:space:]]*$ ]] && continue

		if [[ -f "$file_path" ]]; then
			log info "Removing: $file_path"
			if rm "$file_path"; then
				((removed_count++))
			else
				log error "Failed to remove: $file_path"
			fi
		else
			log warn "File not found (already removed?): $file_path"
			((not_found_count++))
		fi
	done <"$MANIFEST_FILE"

	log success "Removed $removed_count file(s)"
	[[ $not_found_count -gt 0 ]] && log warn "$not_found_count file(s) were already missing"
}

# Clean up manifest file and directory
cleanup_manifest() {
	log info "Cleaning up installation manifest..."

	if rm "$MANIFEST_FILE"; then
		log info "Removed manifest file: $MANIFEST_FILE"
	else
		log warn "Failed to remove manifest file: $MANIFEST_FILE"
	fi

	if [[ -d "$MANIFEST_DIR" ]] && [[ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]]; then
		if rmdir "$MANIFEST_DIR"; then
			log info "Removed empty manifest directory: $MANIFEST_DIR"
		else
			log warn "Failed to remove manifest directory: $MANIFEST_DIR"
		fi
	fi
}

# Uninstall functionality
run_uninstaller() {
	log info "Starting Shell Starter uninstallation..."

	[[ ! -f "$MANIFEST_FILE" ]] && {
		log error "No installation manifest found at: $MANIFEST_FILE"
		log error "Either Shell Starter was never installed, or the manifest was deleted."
		exit 1
	}

	local file_count
	file_count=$(grep -v '^#' "$MANIFEST_FILE" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' \n\r\t')

	[[ $file_count -eq 0 ]] && {
		log warn "No files listed in manifest. Nothing to uninstall."
		exit 0
	}

	log info "Found $file_count file(s) to remove"
	show_uninstall_files
	get_uninstall_confirmation
	remove_files

	local shell_config
	shell_config=$(detect_shell_config)
	remove_from_path "$shell_config" "$PREFIX"

	cleanup_manifest
	log success "Uninstallation complete!"
	log info "All Shell Starter files and PATH entries have been removed from your system."
	log info "Please run 'source $shell_config' or restart your shell to update PATH"
}

# Main installation
main() {
	parse_args "$@"

	# Handle uninstall option
	if [[ "$UNINSTALL" == true ]]; then
		run_uninstaller
		return 0
	fi

	if [[ "$FROM_GITHUB" == true ]]; then
		log info "Installing from GitHub (${VERSION:-latest})"
	else
		log info "Installing from local directory"
	fi

	init_manifest
	install_scripts

	local shell_config
	shell_config=$(detect_shell_config)
	add_to_path "$shell_config" "$PREFIX"

	log success "Installation complete!"
	log info "Scripts installed to: $PREFIX"
	log info "Libraries installed to: $LIB_PREFIX"
	log info "Manifest: $MANIFEST_FILE"
	log info "Restart shell or run: source $shell_config"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
	main "$@"
fi
