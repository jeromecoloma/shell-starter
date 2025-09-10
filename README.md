# Shell Starter

A bash-first template repository for creating professional CLI scripts with built-in logging, colors, spinners, installers, and testing framework.

## 🚀 Quick Start

### Installation

Clone this repository and install the example scripts:

```bash
git clone https://github.com/jeromecoloma/shell-starter.git
cd shell-starter
./install.sh
```

Or install directly from GitHub (⚠️ **Security Warning**: Only run this from trusted sources):

```bash
curl -fsSL https://raw.githubusercontent.com/jeromecoloma/shell-starter/main/install.sh | bash
```

### Custom Installation Path

By default, scripts are installed to `~/.config/shell-starter/bin`. To install elsewhere:

```bash
./install.sh --prefix /usr/local
```

### Uninstallation

```bash
./uninstall.sh
# Or skip confirmation prompt:
./uninstall.sh -y
```

## 📋 Features

- **🎨 Colors & Logging**: Built-in colored logging functions (`log::info`, `log::warn`, `log::error`, `log::debug`)
- **⏳ Spinners**: Loading indicators for long-running tasks
- **📦 Easy Installation**: One-command installer with custom path support
- **🔧 Argument Parsing**: Boilerplate for handling command-line arguments and help text
- **📝 Centralized Versioning**: Single `VERSION` file for all scripts
- **🔗 Polyglot Support**: Helper functions to call Python, Node.js, and other language scripts
- **🧪 Testing Framework**: Bats-core integration for reliable script testing
- **🤖 CI/CD Ready**: GitHub Actions with ShellCheck, shfmt, and automated testing
- **🤖 AI-Friendly**: Comprehensive documentation for AI-assisted development

## 📂 Project Structure

```
shell-starter/
├── bin/                # CLI scripts (kebab-case, no .sh suffix)
├── lib/                # Shared utilities (colors, logging, spinners)
├── scripts/            # Helper scripts in other languages
├── tests/              # Bats testing framework tests
├── docs/               # Documentation for humans and AI assistants
├── .github/workflows/  # CI/CD configuration
├── VERSION             # Centralized version file (SemVer)
├── install.sh          # Installer with curl support
└── uninstall.sh        # Manifest-based uninstaller
```

## 🎯 Example Scripts

Shell Starter includes several example scripts to demonstrate features:

| Script | Purpose |
|--------|---------|
| `hello-world` | Basic script structure with argument parsing |
| `show-colors` | Demonstrates logging functions and color output |
| `long-task` | Shows spinner usage for long-running operations |
| `greet-user` | Advanced argument parsing and configuration |
| `my-cli` | Multi-command dispatcher (git-like subcommands) |
| `ai-action` | Template for AI API integration with secure key handling |
| `polyglot-example` | Bash + Python integration example |

### Try the examples:

```bash
hello-world --help
show-colors
long-task
greet-user --name "Developer" --enthusiastic
my-cli user list
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
# Install bats-core if not already installed
npm install -g bats

# Run tests
bats tests/
```

### Code Quality

```bash
# Lint all scripts
shellcheck bin/* lib/*.sh install.sh uninstall.sh

# Format code
shfmt -w bin/* lib/*.sh install.sh uninstall.sh
```

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

- [Shell Scripting Best Practices](docs/conventions.md)
- [Example Scripts Guide](docs/examples.md)
- [AI Development Guide](docs/ai-guide.md)
- [Local CI Testing with Act](docs/act-usage.md)