#!/bin/bash

set -euo pipefail

# Shell Starter Uninstaller
# This script removes installed CLI scripts based on the installation manifest

# Configuration
MANIFEST_DIR="${MANIFEST_DIR:-$HOME/.config/shell-starter}"
MANIFEST_FILE="${MANIFEST_FILE:-$MANIFEST_DIR/install-manifest.txt}"

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

# Remove PATH entry from shell configuration
remove_from_path() {
	local config_file="$1"
	local path_to_remove="$2"

	if [[ ! -f "$config_file" ]]; then
		log_info "Shell config file not found: $config_file"
		return 0
	fi

	# Check if PATH entry exists
	if ! grep -q "export PATH.*$path_to_remove" "$config_file" 2>/dev/null; then
		log_info "PATH entry not found in $config_file"
		return 0
	fi

	log_info "Removing PATH entry from $config_file"

	# Create a temporary file
	local temp_file
	temp_file=$(mktemp)

	# Remove the PATH line and the comment line before it using a simpler approach
	awk -v target_path="$path_to_remove" '
	/^# Added by shell-starter installer$/ {
		# Check if next line contains the PATH entry
		getline nextline
		if (index(nextline, target_path) == 0 || nextline !~ /^export PATH=/) {
			# If not our PATH entry, keep both lines
			print $0
			print nextline
		}
		# If it is our PATH entry, skip both lines (dont print anything)
		next
	}
	# Print all other lines
	{ print }
	' "$config_file" >"$temp_file"

	# Replace original file with cleaned version
	if mv "$temp_file" "$config_file"; then
		log_success "Removed PATH entry from $config_file"
	else
		log_error "Failed to update $config_file"
		rm -f "$temp_file"
	fi
}

# Show usage information
show_help() {
	cat <<EOF
Shell Starter Uninstaller

Usage: $0 [OPTIONS]

OPTIONS:
    -y, --force      Skip confirmation prompt and remove files immediately
    --help, -h       Show this help message

DESCRIPTION:
    This script removes all Shell Starter CLI scripts that were previously 
    installed using install.sh. It reads the installation manifest to determine
    which files to remove and automatically cleans up PATH entries from your
    shell configuration.
    
    The manifest file is located at: $MANIFEST_FILE
    
EXAMPLES:
    $0               # Remove files with confirmation prompt
    $0 -y            # Remove files without confirmation
    $0 --force       # Same as -y

EOF
}

# Parse command line arguments
parse_args() {
	FORCE_REMOVE=false

	while [[ $# -gt 0 ]]; do
		case $1 in
		-y | --force)
			FORCE_REMOVE=true
			shift
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
}

# Check if manifest file exists
check_manifest() {
	if [[ ! -f "$MANIFEST_FILE" ]]; then
		log_error "No installation manifest found at: $MANIFEST_FILE"
		log_error "Either Shell Starter was never installed, or the manifest was deleted."
		exit 1
	fi
}

# Read and validate manifest
read_manifest() {
	log_info "Reading installation manifest: $MANIFEST_FILE"

	# Extract install prefix from manifest
	INSTALL_PREFIX=$(grep '^# Install prefix:' "$MANIFEST_FILE" | sed 's/^# Install prefix: //' || true)

	# Count non-comment, non-empty lines
	local file_count
	file_count=$(grep -v '^#' "$MANIFEST_FILE" | grep -v '^[[:space:]]*$' | wc -l || echo "0")
	file_count=$(echo "$file_count" | tr -d ' \n\r\t')

	if [[ $file_count -eq 0 ]]; then
		log_warn "No files listed in manifest. Nothing to uninstall."
		exit 0
	fi

	log_info "Found $file_count file(s) to remove"
	if [[ -n "$INSTALL_PREFIX" ]]; then
		log_info "Install prefix: $INSTALL_PREFIX"
	fi
}

# Show files that will be removed
show_files() {
	echo
	log_info "The following files will be removed:"
	echo

	# Show each file in the manifest (skip comments and empty lines)
	grep -v '^#' "$MANIFEST_FILE" | grep -v '^[[:space:]]*$' | while read -r file_path; do
		if [[ -f "$file_path" ]]; then
			echo "  🗑️  $file_path"
		else
			echo "  ❌ $file_path (not found)"
		fi
	done
	echo
}

# Get user confirmation
get_confirmation() {
	if [[ "$FORCE_REMOVE" == "true" ]]; then
		log_info "Force removal enabled, skipping confirmation"
		return 0
	fi

	echo -e "${YELLOW}Are you sure you want to remove these files? [y/N]${NC} "
	read -r response

	case "$response" in
	[yY] | [yY][eE][sS])
		return 0
		;;
	*)
		log_info "Uninstallation cancelled by user"
		exit 0
		;;
	esac
}

# Remove files listed in manifest
remove_files() {
	local removed_count=0
	local not_found_count=0

	log_info "Starting file removal..."

	# Process each file in the manifest
	while IFS= read -r file_path; do
		# Skip comments and empty lines
		if [[ "$file_path" =~ ^#.*$ ]] || [[ -z "$file_path" ]] || [[ "$file_path" =~ ^[[:space:]]*$ ]]; then
			continue
		fi

		if [[ -f "$file_path" ]]; then
			log_info "Removing: $file_path"
			if rm "$file_path"; then
				((removed_count++))
			else
				log_error "Failed to remove: $file_path"
			fi
		else
			log_warn "File not found (already removed?): $file_path"
			((not_found_count++))
		fi
	done <"$MANIFEST_FILE"

	log_success "Removed $removed_count file(s)"
	if [[ $not_found_count -gt 0 ]]; then
		log_warn "$not_found_count file(s) were already missing"
	fi
}

# Clean up PATH entries
cleanup_path() {
	if [[ -n "$INSTALL_PREFIX" ]]; then
		log_info "Cleaning up PATH entries..."
		local shell_config
		shell_config=$(detect_shell_config)
		remove_from_path "$shell_config" "$INSTALL_PREFIX"
		log_info "Please run 'source $shell_config' or restart your shell to update PATH"
	fi
}

# Clean up manifest file and directory
cleanup_manifest() {
	log_info "Cleaning up installation manifest..."

	# Remove the manifest file
	if rm "$MANIFEST_FILE"; then
		log_info "Removed manifest file: $MANIFEST_FILE"
	else
		log_warn "Failed to remove manifest file: $MANIFEST_FILE"
	fi

	# Remove manifest directory if empty
	if [[ -d "$MANIFEST_DIR" ]] && [[ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]]; then
		if rmdir "$MANIFEST_DIR"; then
			log_info "Removed empty manifest directory: $MANIFEST_DIR"
		else
			log_warn "Failed to remove manifest directory: $MANIFEST_DIR"
		fi
	fi
}

# Main uninstallation process
main() {
	log_info "Starting Shell Starter uninstallation..."

	parse_args "$@"
	check_manifest
	read_manifest
	show_files
	get_confirmation
	remove_files
	cleanup_path
	cleanup_manifest

	log_success "Uninstallation complete!"
	log_info "All Shell Starter files and PATH entries have been removed from your system."
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
	main "$@"
fi
