# Development Journey: AI-Assisted Markdown to PDF Converter CLI
**Task Code**: `JOURNEY-MD-PDF`

Build a professional markdown to PDF conversion tool using Shell Starter and an AI coding assistant.

## 📋 Overview

**What You'll Build:** A CLI tool that converts markdown files to professional PDFs using pandoc with theme support, interactive prompts, and comprehensive error handling.

**AI Coding Agents:** Claude Code, Cursor, Codex, Gemini CLI, etc.

**Final Result:** Production-ready `md-to-pdf` script with professional UX

## ⏱️ Time Estimate
**Total:** ~40 minutes
- Setup & Exploration: 5 minutes
- Requirements: 3 minutes  
- AI Development: 15 minutes
- Testing & Refinement: 10 minutes
- Enhancement: 7 minutes

## 📚 Prerequisites

- Basic command line knowledge
- Access to an AI coding agent
- Pandoc installed (`brew install pandoc` or `apt-get install pandoc`)
- Some sample markdown files for testing

---

## Phase 1: Discovery & Setup (5 minutes)

### Step 1: Get Shell Starter

```bash
# Clone Shell Starter as your project template
git clone https://github.com/jeromecoloma/shell-starter.git
cd shell-starter
```

### Step 2: Explore the Capabilities

```bash
# Try the example scripts directly to understand Shell Starter's features
./bin/hello-world --help
./bin/show-colors
./bin/long-task
./bin/greet-user --formal "Developer"
```

**Key Observations:**
- Consistent `--help` and `--version` flags
- Colored logging output (`log::info`, `log::error`, etc.)
- Progress spinners for long operations
- Professional argument parsing

### Step 3: Examine the Project Structure

```bash
# Look at the library functions available
ls lib/
# colors.sh  logging.sh  main.sh  spinner.sh  utils.sh

# Check existing script patterns
ls bin/
# hello-world  show-colors  long-task  greet-user  my-cli  ai-action  polyglot-example
```

---

## Phase 2: Requirements Definition (3 minutes)

### Step 4: Define Your Markdown to PDF Converter Requirements

Our tool should:

- ✅ **Single file conversion** from markdown to PDF
- ✅ **Interactive prompts** for input/output paths and theme selection  
- ✅ **Dependency checking** to ensure pandoc is available
- ✅ **Progress indicators** during conversion
- ✅ **Error handling** for invalid files, permissions, pandoc errors
- ✅ **Theme support** (GitHub, Academic, Clean, Modern styles)
- ✅ **Preview mode** to show what would be processed
- ✅ **Shell Starter compliance** (help, version, logging, etc.)

### Step 5: Plan the User Experience

```bash
# Desired usage patterns:
md-to-pdf --help                      # Show comprehensive help
md-to-pdf --version                   # Show version
md-to-pdf                            # Interactive mode with prompts
md-to-pdf document.md                 # Convert to document.pdf
md-to-pdf document.md report.pdf      # Convert with custom output name
md-to-pdf --theme academic doc.md     # Convert with specific theme
md-to-pdf --preview document.md       # Preview conversion plan
```

---

## Phase 3: AI-Assisted Development (15 minutes)

### Step 6: Setup Autonomous AI Development Workflow

Instead of crafting a single prompt, we'll set up a self-managing AI development system that can work across context windows and different AI coding agents.

#### 6A: Generate AI Workflow Structure

```bash
# Generate the autonomous development workflow
./bin/generate-ai-workflow md-to-pdf
```

This creates:
- `.ai-workflow/state/` - Task tracking and progress files
- `.ai-workflow/commands/` - Multi-agent command definitions

#### 6B: Customize Project Requirements

Edit the generated requirements file to specify the md-to-pdf project details:

```bash
# Edit the product requirements document
open .ai-workflow/state/requirements.md
```

Update the template with md-to-pdf specific information:

**Product Overview:**
- Target Users: Developers, writers, documentation teams
- Core Problem: Need professional PDF output from markdown files
- Solution Approach: Command-line tool using pandoc with built-in themes

**User Stories:**
- As a developer, I want to convert README.md to PDF for offline reading
- As a writer, I want to generate styled PDFs from my markdown drafts
- As a documentation team, I want consistent PDF formatting across all docs

**Core Features:**
- Interactive mode with prompts for file selection and theme choice
- Direct mode accepting markdown input and optional PDF output name  
- Built-in themes (GitHub, Academic, Clean, Modern)
- Preview mode to show conversion plan
- Comprehensive error handling and dependency checking

#### 6C: Install Commands for Your AI Agent

Copy the appropriate commands to your coding agent:

```bash
# For Claude Code users:
mkdir -p .claude && cp -r .ai-workflow/commands/.claude/commands .claude/

# For Cursor users:
mkdir -p .cursor && cp -r .ai-workflow/commands/.cursor/commands .cursor/

# For Gemini CLI users:
mkdir -p .gemini && cp -r .ai-workflow/commands/.gemini/commands .gemini/

# For OpenCode users:
mkdir -p .opencode && cp -r .ai-workflow/commands/.opencode/command .opencode/
```

### Step 7: Start Autonomous Development

Now launch the AI development cycle:

```
/dev start
```

Your AI coding agent will now:

1. **Read** the current state from `.ai-workflow/state/` files (requirements.md and tasks.md)
2. **Analyze** the next incomplete task with detailed Goal/Actions/Verification
3. **Act** by implementing that specific feature following the task instructions
4. **Verify** with quality checks (shellcheck, shfmt, manual testing)
5. **Update** progress in the state files and mark tasks complete [x]
6. **Continue** to the next task automatically

**Expected AI Output:**
```
🔄 AUTONOMOUS DEVELOPMENT CYCLE
Current Task: MD-PDF-1: Create project structure and basic executable
Action: Creating bin/md-to-pdf with Shell Starter template structure
Progress: Implementing help text and argument parsing following task specifications
Next: MD-PDF-2: Implement core argument parsing and validation
```

### Step 8: Monitor and Resume Development

If the AI reaches context limits, it will save state and prompt you:

```
Continue development with: /dev
```

Simply start a new conversation and run:

```
/dev
```

The AI will read the saved state and continue exactly where it left off.

---

## Phase 4: Testing & Refinement (10 minutes)

### Step 9: Run Quality Assurance

The AI workflow includes built-in QA. Run comprehensive checks:

```
/qa
```

**Expected QA Output:**
```
🔍 QA REPORT
Files Checked: bin/md-to-pdf
Issues Found: 0
Critical: None
Warnings: None
Status: PASS - Ready for manual testing
```

If issues are found, the AI will provide specific fixes to implement.

### Step 10: Manual Testing

The autonomous development should have created a working script. Test it:

```bash
# Test help and version (should work automatically)
./bin/md-to-pdf --help
./bin/md-to-pdf --version

# Test dependency checking
./bin/md-to-pdf --preview /nonexistent/file.md

# The AI should have implemented proper error handling for all scenarios
```

### Step 11: Create Test Markdown Files and Directories

```bash
# Create test directory structure
mkdir -p test-docs/input test-docs/output

# Create sample markdown files for testing
echo "# Test Document
This is a test markdown file with **bold** and *italic* text.

## Code Example
\`\`\`bash
echo 'Hello World'
\`\`\`

## List Example
- Item 1
- Item 2
- Item 3
" > test-docs/input/sample.md

# Test the modes (AI should have implemented all these)
./bin/md-to-pdf                                     # Interactive mode
./bin/md-to-pdf test-docs/input/sample.md           # Direct mode (auto output)
./bin/md-to-pdf test-docs/input/sample.md test-docs/output/report.pdf  # Custom output
./bin/md-to-pdf --theme academic test-docs/input/sample.md             # Themed conversion
./bin/md-to-pdf --preview test-docs/input/sample.md                    # Preview mode
```

### Step 12: Handle Issues and Iterate

If issues are found, the autonomous workflow handles fixes:

```
/dev
```

The AI will:
1. Detect the issue from testing results
2. Fix the problem automatically
3. Re-run QA to verify the fix
4. Update progress logs

For complex issues, you can check development status:

```
/status
```

---

## Phase 5: Enhancement & Documentation (7 minutes)

### Step 13: Add Advanced Features

To add enhancements, update the requirements and let the AI continue:

```bash
# Edit requirements to add new features
open .ai-workflow/state/requirements.md
```

Add to the requirements:
```markdown
## Advanced Features
- [ ] Custom CSS: --css option to use custom stylesheets
- [ ] Table of contents: --toc flag to generate PDF bookmarks
- [ ] Page options: --margins, --paper-size (A4, Letter, etc.)
- [ ] Metadata: --title, --author flags for PDF properties
- [ ] Enhanced preview: Show markdown parsing results and theme preview
```

Then continue development:
```
/dev
```

The AI will automatically pick up the new requirements and implement them following the same autonomous cycle.

### Step 14: Generate Comprehensive Tests

```
Create comprehensive Bats tests for the md-to-pdf script.

The tests should cover:
- Help and version output validation
- Dependency checking (pandoc availability)
- Input validation (file paths, theme names)
- Error conditions (invalid files, permissions, malformed markdown)
- Interactive mode simulation
- Direct mode with various argument combinations
- Preview mode functionality
- Theme selection and application

Requirements:
- Save as tests/md-to-pdf.bats
- Use proper Bats test structure with setup() and teardown()
- Test both success and failure scenarios
- Verify exit codes and output content
- Follow the testing patterns from existing test files
```

### Step 15: Final Integration & Distribution Setup

```bash
# Run the new tests
./tests/bats-core/bin/bats tests/md-to-pdf.bats

# Add your script to the installer manifest
# This allows users to install your CLI tool with one command
# Edit install.sh to include bin/md-to-pdf in the SCRIPTS array

# Final quality check
shellcheck bin/md-to-pdf tests/md-to-pdf.bats
shfmt -d bin/md-to-pdf
```

### Step 16: Prepare for Distribution

Now that your tool is complete, you can distribute it like any professional CLI:

```bash
# 1. Update VERSION file for your first release
echo "1.0.0" > VERSION

# 2. Update README.md with your tool's description
# Replace Shell Starter content with your Markdown to PDF converter documentation

# 3. Push to your own GitHub repository
git remote set-url origin https://github.com/your-username/md-to-pdf-cli.git
git add .
git commit -m "feat: add md-to-pdf CLI tool with theme support"
git push -u origin main

# 4. Your users can now install with:
# curl -fsSL https://raw.githubusercontent.com/your-username/md-to-pdf-cli/main/install.sh | bash
```

---

## ✅ Journey Complete!

### What You Built

- **Professional CLI tool** with consistent UX
- **Markdown to PDF conversion** with pandoc integration
- **Interactive and direct modes** for different workflows
- **Built-in theme support** (GitHub, Academic, Clean, Modern)
- **Comprehensive error handling** and user feedback
- **Progress indicators** for conversion operations
- **Complete test suite** for reliability
- **Production-ready code** following Shell Starter conventions

### Verification Checklist

- [ ] Script has `--help` and `--version` flags
- [ ] Uses Shell Starter logging functions consistently
- [ ] Handles missing dependencies gracefully (pandoc)
- [ ] Validates all user inputs with helpful error messages
- [ ] Shows progress during conversion operations
- [ ] Passes shellcheck and shfmt quality checks
- [ ] Has comprehensive test coverage
- [ ] Works with various markdown files and theme selections

### Key Learning Outcomes

1. **AI Prompting**: How to craft effective prompts for Shell Starter compliance
2. **Library Integration**: Using Shell Starter's logging, spinner, and utility functions
3. **Error Handling**: Professional error messages and graceful failure modes
4. **Testing Strategy**: Comprehensive test coverage with Bats
5. **Code Quality**: Automated linting and formatting workflows

---

## 🎨 Enhancement Ideas

Ready to take it further? Try these enhancements:

### Advanced Features
- **Custom templates**: Create reusable pandoc templates for different document types
- **Batch processing**: Convert multiple markdown files in a directory
- **Live preview**: Watch mode that regenerates PDF when markdown changes
- **Plugin system**: Support for custom pandoc filters and processors

### Integration Improvements
- **Configuration files**: Support for saving/loading conversion presets
- **Git integration**: Auto-convert README.md files in repositories
- **Editor plugins**: VS Code/Vim plugins for one-click conversion
- **Web interface**: Simple web UI for drag-and-drop markdown conversion

### Professional Features
- **Document merging**: Combine multiple markdown files into single PDF
- **Citation support**: Bibliography and academic citation formatting
- **Collaboration**: Team templates and shared style configurations
- **Quality assurance**: Markdown linting and validation before conversion

---

## 📚 What's Next?

- Try the [File Converter Journey](../coming-soon.md) to build a multi-format conversion tool
- Explore [Manual Development approaches](../coming-soon.md) without AI assistance
- Check out [Team Development workflows](../coming-soon.md) for collaborative CLI projects

---

**Total Development Time:** ~40 minutes from Shell Starter template to distributed CLI tool

**Key Insight:** Shell Starter's standardized structure and comprehensive documentation makes AI-assisted development incredibly effective. The AI has clear patterns to follow, resulting in consistent, professional CLI tools with minimal iteration. The md-to-pdf converter showcases how complex document processing can be made accessible through simple, well-designed command-line interfaces.