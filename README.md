# Shell Starter

A bash-first template repository for creating professional CLI scripts with built-in logging, colors, spinners, installers, and testing framework.

## 🚀 Quick Start

### Use as Template

Shell Starter is a template for building your own CLI tools:

```bash
# Use GitHub's "Use this template" button, or clone directly:
git clone https://github.com/jeromecoloma/shell-starter.git my-cli-project
cd my-cli-project

# Explore the example scripts to understand Shell Starter's capabilities:
./demo/hello-world --help
./demo/show-colors
./demo/long-task
```

### Important: Installation vs Usage

**Shell Starter itself is NOT installed** - it's a template you clone to build your own CLI tools:

```bash
# ✅ How developers use Shell Starter
git clone https://github.com/jeromecoloma/shell-starter.git my-project
cd my-project
# Build your CLI tool using Shell Starter's libraries and structure
```

**The install.sh and uninstall.sh are templates** for distributing CLI tools you build with Shell Starter:

```bash
# ✅ How end users install CLI tools built with Shell Starter
curl -fsSL https://your-domain.com/your-cli-tool/install.sh | bash
# or
./install.sh --prefix ~/.local/bin
```

**Key Points**:
- `install.sh` installs scripts from your project's `bin/` directory to user's system
- `demo/` scripts are examples only and are NOT installed
- `lib/` files are installed as dependencies for your CLI tools
- **Custom Installation Path**: Supports `--prefix /custom/path` (default: `~/.config/your-project/bin`)
- **Uninstallation**: Built-in uninstaller via `./install.sh --uninstall` or `./uninstall.sh`

## 📋 Features

- **🎨 Colors & Logging**: Built-in colored logging functions (`log::info`, `log::warn`, `log::error`, `log::debug`)
- **⏳ Spinners**: Loading indicators for long-running tasks
- **📦 Easy Installation**: One-command installer with custom path support
- **🔧 Argument Parsing**: Boilerplate for handling command-line arguments and help text
- **📝 Centralized Versioning**: Single `VERSION` file for all scripts
- **🔗 Polyglot Support**: Helper functions to call Python, Node.js, and other language scripts
- **🧪 Testing Framework**: Bats-core integration for reliable script testing
- **🤖 CI/CD Ready**: GitHub Actions with ShellCheck, shfmt, and Bats test automation
- **📦 Dependency Management**: Built-in system for updating shell-starter library dependencies
- **🔄 Breaking Change Detection**: Automatic detection and migration guidance for API changes
- **🤖 AI-Friendly**: Comprehensive documentation for AI-assisted development
- **🗺️ Development Journeys**: Step-by-step guides for real-world CLI tool creation

## 📂 Project Structure

```
shell-starter/
├── bin/                # Core utility scripts (bump-version, generate-ai-workflow, etc.)
├── demo/               # Example scripts demonstrating Shell Starter capabilities
├── lib/                # Shared utilities (colors, logging, spinners)
├── scripts/            # Helper scripts in other languages
├── tests/              # Bats testing framework tests
├── docs/               # Documentation for humans and AI assistants
├── .github/workflows/  # CI/CD configuration
├── VERSION             # Centralized version file (SemVer)
├── .shell-starter-version  # Shell Starter dependency version tracking
├── install.sh          # Template installer for your CLI tools (NOT for Shell Starter itself)
└── uninstall.sh        # Template uninstaller for your CLI tools (NOT for Shell Starter itself)
```

## 🎯 Example Scripts

Shell Starter includes example scripts (in `demo/`) and core utilities (in `bin/`):

### Demo Scripts (`demo/` - Examples Only)
| Script | Purpose |
|--------|---------|
| `hello-world` | Basic script structure with argument parsing |
| `show-colors` | Demonstrates logging functions and color output |
| `long-task` | Shows spinner usage for long-running operations |
| `greet-user` | Advanced argument parsing and configuration |
| `my-cli` | Multi-command dispatcher (git-like subcommands) |
| `ai-action` | Template for AI API integration with secure key handling |
| `polyglot-example` | Bash + Python integration example |
| `show-banner` | Demonstrates banner/branding system |
| `debug-colors` | Color palette testing and debugging |
| `update-tool` | Example of update management functionality |

### Core Utilities (`bin/` - Actual Tools)
| Script | Purpose |
|--------|---------|
| `generate-ai-workflow` | Creates multi-agent AI development workflows for autonomous coding |
| `update-shell-starter` | Updates shell-starter library dependencies in derived projects |
| `bump-version` | Intelligent version bumping for shell-starter and cloned projects |

**Built-in Features**: All example scripts support standard flags including `--help`, `--version`, `--update`, `--check-version`, `--notify-config`, and `--uninstall` (for removing CLI tool installation).

### Try the examples:

```bash
# Run example scripts from the demo/ directory
./demo/hello-world --help
./demo/show-colors
./demo/long-task
./demo/greet-user --formal "Developer"
./demo/my-cli status
./demo/ai-action --help
./demo/polyglot-example demo

# Run core utilities from the bin/ directory
./bin/generate-ai-workflow --help
./bin/bump-version --help
./bin/update-shell-starter --help
```

## 🔧 Development

### Using the Library

Source the main library in your scripts:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_STARTER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SHELL_STARTER_ROOT}/lib/main.sh"

# Now you have access to all utilities:
log::info "Starting application..."
spinner::start "Processing data"
sleep 3
spinner::stop
log::success "Complete!"
```

### Available Functions

#### Logging
- `log::info "message"` - Blue informational message
- `log::warn "message"` - Yellow warning message
- `log::error "message"` - Red error message
- `log::debug "message"` - Gray debug message (if DEBUG=1)
- `log::success "message"` - Green success message

#### Spinners
- `spinner::start "Loading message"` - Start spinner with message
- `spinner::stop` - Stop current spinner

#### Utilities
- `run::script "path/to/script.py" arg1 arg2` - Execute scripts in other languages
- `get_version` - Get version from VERSION file
- `parse_args` - Basic argument parsing template

#### Colors
Access color variables directly: `$RED`, `$GREEN`, `$BLUE`, `$YELLOW`, `$PURPLE`, `$CYAN`, `$BOLD`, `$RESET`

### Creating New Scripts

1. Create your script in `bin/` without `.sh` extension
2. Make it executable: `chmod +x bin/your-script`
3. Use the library template from existing examples
4. Add to installer manifest if needed

### Testing

Run the test suite:

```bash
# Run all tests
./tests/bats-core/bin/bats tests/*.bats

# Run specific test suites
./tests/bats-core/bin/bats tests/hello-world.bats
./tests/bats-core/bin/bats tests/generate-ai-workflow.bats
./tests/bats-core/bin/bats tests/lib-*.bats

# Or install bats-core globally
npm install -g bats
bats tests/
```

**Test Coverage**: The test suite includes comprehensive coverage of:
- All example scripts (hello-world, generate-ai-workflow, etc.)
- Library functions (logging, colors, spinners, utils)
- Integration tests for Shell Starter framework

Tests automatically run in CI on every push and pull request.

### Library Dependency Management

Shell Starter includes a built-in dependency management system for projects that use it as a library foundation:

#### Updating Shell Starter Dependencies

If you've built a project using Shell Starter as a foundation, keep your library dependencies updated:

```bash
# Check for updates
./bin/update-shell-starter --check

# Update to latest version
./bin/update-shell-starter

# Update to specific version
./bin/update-shell-starter --target-version 0.2.0

# Preview changes without applying
./bin/update-shell-starter --dry-run
```

#### Features

- **Selective Updates**: Only updates standard shell-starter library files (`lib/*.sh`)
- **Preservation**: Keeps your custom library files and project code intact
- **Version Tracking**: Maintains `.shell-starter-version` file for dependency tracking
- **Breaking Change Detection**: Warns about potential breaking changes with migration guidance
- **Backup Support**: Automatically creates backups before updates (configurable)
- **Dry Run Mode**: Preview changes before applying

#### Version Tracking

Your project automatically tracks the shell-starter version in `.shell-starter-version`:

```bash
# Check current shell-starter version
cat .shell-starter-version

# This file is automatically updated by the update tool
```

#### Breaking Changes

The update tool detects breaking changes and provides migration guidance:

```bash
# Example warning for breaking changes
./bin/update-shell-starter
# Warning: Breaking changes detected in v0.2.0
# - Function names changed from log_* to log::*
# See migration guide for details...
```

For detailed migration instructions, see [docs/MIGRATION.md](docs/MIGRATION.md).

### Version Management

Shell Starter includes intelligent version bumping that works differently for the main repository vs. cloned projects:

```bash
# Bump version types
./bin/bump-version patch    # 1.2.3 -> 1.2.4
./bin/bump-version minor    # 1.2.3 -> 1.3.0
./bin/bump-version major    # 1.2.3 -> 2.0.0

# Set exact version
./bin/bump-version 1.5.0

# Check current version and repository type
./bin/bump-version --current
./bin/bump-version --check-repo

# Preview changes without applying
./bin/bump-version --dry-run patch
```

#### Smart Repository Detection

- **Shell-starter repository**: Updates both `VERSION` and `.shell-starter-version`
- **Cloned projects**: Updates only `VERSION` file (preserves dependency tracking)
- **Auto-detection**: Uses repository markers to identify shell-starter vs. cloned project context

This ensures that when you clone Shell Starter for your project, version bumps only affect your project version, not the Shell Starter dependency version.

### Development Tool Setup

Install the required development tools:

**macOS (using Homebrew):**
```bash
# Install code quality tools
brew install shellcheck shfmt

# Optional: Install act for local CI testing
brew install act
```

**Ubuntu/Debian:**
```bash
# Install ShellCheck
sudo apt-get update
sudo apt-get install -y shellcheck

# Install shfmt
curl -L -o /tmp/shfmt https://github.com/mvdan/sh/releases/download/v3.12.0/shfmt_v3.12.0_linux_amd64
sudo install /tmp/shfmt /usr/local/bin/shfmt

# Optional: Install act for local CI testing
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

**Other Systems:**
- **ShellCheck**: See [shellcheck.net](https://www.shellcheck.net/wiki/Installing) for installation options
- **shfmt**: Download from [mvdan/sh releases](https://github.com/mvdan/sh/releases)
- **Act**: See [nektos/act](https://github.com/nektos/act#installation) for installation options

### Code Quality

Run code quality checks locally:

```bash
# Lint all scripts (configured via .shellcheckrc)
shellcheck bin/* lib/*.sh install.sh uninstall.sh

# Check formatting
shfmt -d bin/* lib/*.sh install.sh uninstall.sh

# Apply formatting fixes
shfmt -w bin/* lib/*.sh install.sh uninstall.sh
```

**Shellcheck Configuration**: The `.shellcheckrc` file configures shellcheck to ignore warnings appropriate for shell libraries (unused variables meant for external use, file sourcing behavior, etc.).

## 🤖 AI Workflow Generator

Shell Starter includes `generate-ai-workflow` - a tool that creates autonomous AI development workflows for any project:

### Quick Start

```bash
# Generate AI workflow for your project
./bin/generate-ai-workflow my-cli-tool

# Copy commands to your AI coding agent
mkdir -p .claude && cp -r .ai-workflow/commands/.claude/commands .claude/  # For Claude Code
mkdir -p .cursor && cp -r .ai-workflow/commands/.cursor/commands .cursor/  # For Cursor
mkdir -p .gemini && cp -r .ai-workflow/commands/.gemini/commands .gemini/ # For Gemini CLI

# Edit project requirements
vim .ai-workflow/state/requirements.md

# Start autonomous development
/dev start
```

### What It Creates

- **State Management**: Task tracking, requirements, progress logs
- **Multi-Agent Commands**: Works with Claude Code, Cursor, Gemini CLI, OpenCode
- **Autonomous Development**: Self-managing AI development cycles
- **Context Persistence**: Resume development across conversation resets

### AI Commands

| Command | Purpose |
|---------|---------|
| `/dev start` | Begin/resume autonomous development |
| `/qa` | Run comprehensive quality assurance |
| `/status` | Show current project status |
| `/deps` | Manage Shell Starter library dependencies |

See the [Markdown to PDF Converter Journey](docs/journeys/ai-assisted/md-to-pdf.md) for a complete example.

## 🤖 AI Development

This repository is optimized for AI-assisted development. See `docs/ai-guide.md` for:
- Prompt engineering examples
- Coding conventions
- AI-friendly documentation

## 🔐 Security Notes

### curl | bash Warning

The quick install method (`curl ... | bash`) executes remote code directly. This is convenient but has security implications:

- **Risk**: Executing unverified remote code
- **Mitigation**: Only use with trusted repositories
- **Best Practice**: Download and inspect `install.sh` before execution:

```bash
curl -fsSL https://raw.githubusercontent.com/jeromecoloma/shell-starter/main/install.sh > install.sh
# Review the script
cat install.sh
# Run it
bash install.sh
```

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `bats tests/`
5. Submit a pull request

## 📚 Learn More

- **[Development Journeys](docs/journeys/)** - Step-by-step guides for building real CLI tools
- [Shell Scripting Best Practices](docs/conventions.md)
- [Example Scripts Guide](docs/examples.md)
- [AI Development Guide](docs/ai-guide.md)
- [Local CI Testing with Act](docs/act-usage.md)