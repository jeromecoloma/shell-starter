# Development Journey: AI-Assisted Image Resizer CLI
**Task Code**: `JOURNEY-IMG-RESIZE`

Build a professional batch image resizing tool using Shell Starter and an AI coding assistant.

## 📋 Overview

**What You'll Build:** A CLI tool that batch resizes images using ImageMagick with interactive prompts, progress indicators, and comprehensive error handling.

**AI Coding Agents:** Claude Code, Cursor, Codex, Gemini CLI, etc.

**Final Result:** Production-ready `image-resize` script with professional UX

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
- ImageMagick installed (`brew install imagemagick` or `apt-get install imagemagick`)
- Some sample images for testing

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

### Step 4: Define Your Image Resizer Requirements

Our tool should:

- ✅ **Batch process** multiple images in a directory
- ✅ **Interactive prompts** for input/output paths and dimensions  
- ✅ **Dependency checking** to ensure ImageMagick is available
- ✅ **Progress indicators** during processing
- ✅ **Error handling** for invalid files, permissions, disk space
- ✅ **Flexible sizing** (width x height, or maintain aspect ratio)
- ✅ **Preview mode** to show what would be processed
- ✅ **Shell Starter compliance** (help, version, logging, etc.)

### Step 5: Plan the User Experience

```bash
# Desired usage patterns:
image-resize --help                    # Show comprehensive help
image-resize --version                 # Show version
image-resize                          # Interactive mode with prompts
image-resize /path/to/input /path/to/output 800x600    # Direct mode
image-resize --preview /path/to/input 1920x1080       # Preview only
```

---

## Phase 3: AI-Assisted Development (15 minutes)

### Step 6: Setup Autonomous AI Development Workflow

Instead of crafting a single prompt, we'll set up a self-managing AI development system that can work across context windows and different AI coding agents.

#### 6A: Generate AI Workflow Structure

```bash
# Generate the autonomous development workflow
./bin/generate-ai-workflow image-resize
```

This creates:
- `.ai-workflow/state/` - Task tracking and progress files
- `.ai-workflow/commands/` - Multi-agent command definitions

#### 6B: Customize Project Requirements

Edit the generated requirements file:

```bash
# Edit the project requirements
# Update with image-resizer specific features
open .ai-workflow/state/requirements.md
```

Update it with:

```markdown
# image-resize - Project Requirements
**Task Code**: `REQ-IMAGE-RESIZE`

## Overview
Batch image resizing CLI tool using ImageMagick with interactive prompts, progress indicators, and comprehensive error handling.

## Core Features
- [ ] **REQ-1:** Interactive mode: prompts for input directory, output directory, and dimensions
- [ ] **REQ-2:** Direct mode: accepts input/output paths and dimensions as arguments
- [ ] **REQ-3:** Batch processing of common image formats (jpg, png, gif, tiff, bmp)
- [ ] **REQ-4:** Maintain aspect ratio option or exact dimensions
- [ ] **REQ-5:** Preview mode to show what would be processed without actually resizing

## Shell Starter Requirements
- [ ] **REQ-6:** Follow Shell Starter conventions from docs/conventions.md
- [ ] **REQ-7:** Use the standard script template with proper header
- [ ] **REQ-8:** Include comprehensive help text with usage examples
- [ ] **REQ-9:** Use logging functions (log::info, log::error, log::warn) instead of echo
- [ ] **REQ-10:** Include proper argument parsing with --help and --version
- [ ] **REQ-11:** Add input validation for all paths and dimensions
- [ ] **REQ-12:** Handle errors gracefully with meaningful messages

## Technical Requirements
- [ ] **REQ-13:** Check for ImageMagick dependency (convert command)
- [ ] **REQ-14:** Validate input directory exists and is readable
- [ ] **REQ-15:** Create output directory if it doesn't exist
- [ ] **REQ-16:** Show progress with Shell Starter's spinner functions
- [ ] **REQ-17:** Handle file permission errors, disk space issues
- [ ] **REQ-18:** Support both "WIDTHxHEIGHT" and "WIDTH" (maintain aspect) formats
- [ ] **REQ-19:** Skip already processed files or provide overwrite option

## Error Handling Scenarios
- [ ] **REQ-20:** ImageMagick not installed
- [ ] **REQ-21:** Invalid directory paths
- [ ] **REQ-22:** No images found in input directory
- [ ] **REQ-23:** Insufficient disk space
- [ ] **REQ-24:** File permission issues
- [ ] **REQ-25:** Invalid dimension formats

## Success Criteria
- [ ] **REQ-26:** Script exists at bin/image-resize and is executable
- [ ] **REQ-27:** Passes shellcheck and shfmt quality checks
- [ ] **REQ-28:** Help text includes comprehensive usage examples
- [ ] **REQ-29:** All error conditions handled gracefully with log:: functions
- [ ] **REQ-30:** Interactive mode prompts work correctly
- [ ] **REQ-31:** Direct mode accepts all argument patterns
- [ ] **REQ-32:** Preview mode shows processing plan without executing
- [ ] **REQ-33:** Manual testing successful with real images
```

#### 6C: Install Commands for Your AI Agent

Copy the appropriate commands to your coding agent:

```bash
# For Claude Code users:
cp -r .ai-workflow/commands/.claude/commands/ .claude/

# For Cursor users:
cp -r .ai-workflow/commands/.cursor/commands/ .cursor/

# For Gemini CLI users:
cp -r .ai-workflow/commands/.gemini/commands/ .gemini/

# For OpenCode users:
cp -r .ai-workflow/commands/.opencode/command/ .opencode/
```

### Step 7: Start Autonomous Development

Now launch the AI development cycle:

```
/dev start
```

Your AI coding agent will now:

1. **Read** the current state from `.ai-workflow/state/` files
2. **Analyze** the next incomplete task
3. **Act** by implementing that specific feature
4. **Verify** with quality checks (shellcheck, shfmt, manual testing)
5. **Update** progress in the state files
6. **Continue** to the next task automatically

**Expected AI Output:**
```
🔄 AUTONOMOUS DEVELOPMENT CYCLE
Current Task: IMAGE-RESIZE-1: Create project structure and basic executable
Action: Creating bin/image-resize with Shell Starter template structure
Progress: Implementing help text and argument parsing
Next: IMAGE-RESIZE-2: Implement help text and version handling
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
Files Checked: bin/image-resize
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
./bin/image-resize --help
./bin/image-resize --version

# Test dependency checking
./bin/image-resize --preview /nonexistent/path 800x600

# The AI should have implemented proper error handling for all scenarios
```

### Step 11: Create Test Images and Directories

```bash
# Create test directory structure
mkdir -p test-images/input test-images/output

# Add some test images to test-images/input/
# (download or copy some sample images)

# Test the modes (AI should have implemented all these)
./bin/image-resize                                    # Interactive mode
./bin/image-resize test-images/input test-images/output 800x600  # Direct mode
./bin/image-resize --preview test-images/input 1920x1080        # Preview mode
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
- [ ] Quality settings: --quality option (1-100) for JPEG compression
- [ ] Format conversion: --format flag for output format (jpg/png/etc)
- [ ] Recursive processing: --recursive flag to process subdirectories
- [ ] Progress indicators: "Processing image X of Y" display
- [ ] Enhanced preview: Show before/after file sizes
```

Then continue development:
```
/dev
```

The AI will automatically pick up the new requirements and implement them following the same autonomous cycle.

### Step 14: Generate Comprehensive Tests

```
Create comprehensive Bats tests for the image-resize script.

The tests should cover:
- Help and version output validation
- Dependency checking (ImageMagick availability)
- Input validation (directories, dimension formats)
- Error conditions (invalid paths, permissions)
- Interactive mode simulation
- Direct mode with various argument combinations
- Preview mode functionality

Requirements:
- Save as tests/image-resize.bats
- Use proper Bats test structure with setup() and teardown()
- Test both success and failure scenarios
- Verify exit codes and output content
- Follow the testing patterns from existing test files
```

### Step 15: Final Integration & Distribution Setup

```bash
# Run the new tests
./tests/bats-core/bin/bats tests/image-resize.bats

# Add your script to the installer manifest
# This allows users to install your CLI tool with one command
# Edit install.sh to include bin/image-resize in the SCRIPTS array

# Final quality check
shellcheck bin/image-resize tests/image-resize.bats
shfmt -d bin/image-resize
```

### Step 16: Prepare for Distribution

Now that your tool is complete, you can distribute it like any professional CLI:

```bash
# 1. Update VERSION file for your first release
echo "1.0.0" > VERSION

# 2. Update README.md with your tool's description
# Replace Shell Starter content with your Image Resizer documentation

# 3. Push to your own GitHub repository
git remote set-url origin https://github.com/your-username/image-resize-cli.git
git add .
git commit -m "feat: add image-resize CLI tool with batch processing"
git push -u origin main

# 4. Your users can now install with:
# curl -fsSL https://raw.githubusercontent.com/your-username/image-resize-cli/main/install.sh | bash
```

---

## ✅ Journey Complete!

### What You Built

- **Professional CLI tool** with consistent UX
- **Batch image processing** with ImageMagick integration
- **Interactive and direct modes** for different workflows
- **Comprehensive error handling** and user feedback
- **Progress indicators** for long operations
- **Complete test suite** for reliability
- **Production-ready code** following Shell Starter conventions

### Verification Checklist

- [ ] Script has `--help` and `--version` flags
- [ ] Uses Shell Starter logging functions consistently
- [ ] Handles missing dependencies gracefully
- [ ] Validates all user inputs with helpful error messages
- [ ] Shows progress during batch operations
- [ ] Passes shellcheck and shfmt quality checks
- [ ] Has comprehensive test coverage
- [ ] Works with various image formats and dimension specifications

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
- **Watermarking**: Add text/image watermarks to processed images
- **Batch effects**: Apply filters, brightness, contrast adjustments
- **Cloud storage**: Upload/download from S3, Google Cloud, etc.
- **Parallel processing**: Use GNU parallel for faster batch operations

### Integration Improvements
- **Configuration files**: Support for saving/loading common presets
- **Progress persistence**: Resume interrupted batch operations
- **Notifications**: Desktop notifications when batch processing completes
- **Web interface**: Simple web UI for drag-and-drop image processing

### Professional Features
- **Logging and audit**: Detailed operation logs for batch processing
- **Resource monitoring**: Check available disk space before processing
- **Backup creation**: Automatic backup of original images
- **Metadata preservation**: Keep EXIF data, creation dates, etc.

---

## 📚 What's Next?

- Try the [File Converter Journey](../coming-soon.md) to build a multi-format conversion tool
- Explore [Manual Development approaches](../coming-soon.md) without AI assistance
- Check out [Team Development workflows](../coming-soon.md) for collaborative CLI projects

---

**Total Development Time:** ~40 minutes from Shell Starter template to distributed CLI tool

**Key Insight:** Shell Starter's standardized structure and comprehensive documentation makes AI-assisted development incredibly effective. The AI has clear patterns to follow, resulting in consistent, professional CLI tools with minimal iteration.