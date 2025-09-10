# Development Journey: AI-Assisted Image Resizer CLI

Build a professional batch image resizing tool using Shell Starter and an AI coding assistant.

## 📋 Overview

**What You'll Build:** A CLI tool that batch resizes images using ImageMagick with interactive prompts, progress indicators, and comprehensive error handling.

**AI Assistant:** Any coding AI (Claude, ChatGPT, Gemini, etc.)

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
- Access to an AI coding assistant
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

### Step 6: Craft the AI Prompt

Copy this prompt to your AI assistant:

```
Create a Shell Starter script named "image-resize" that batch resizes images using ImageMagick with the following features:

CORE FUNCTIONALITY:
- Interactive mode: prompts for input directory, output directory, and dimensions
- Direct mode: accepts input/output paths and dimensions as arguments
- Batch processing of common image formats (jpg, png, gif, tiff, bmp)
- Maintain aspect ratio option or exact dimensions
- Preview mode to show what would be processed without actually resizing

SHELL STARTER REQUIREMENTS:
- Follow Shell Starter conventions from docs/conventions.md
- Use the standard script template with proper header
- Include comprehensive help text with usage examples
- Use logging functions (log::info, log::error, log::warn) instead of echo
- Include proper argument parsing with --help and --version
- Add input validation for all paths and dimensions
- Handle errors gracefully with meaningful messages

TECHNICAL REQUIREMENTS:
- Check for ImageMagick dependency (convert command)
- Validate input directory exists and is readable
- Create output directory if it doesn't exist
- Show progress with Shell Starter's spinner functions
- Handle file permission errors, disk space issues
- Support both "WIDTHxHEIGHT" and "WIDTH" (maintain aspect) formats
- Skip already processed files or provide overwrite option

ERROR HANDLING:
- ImageMagick not installed
- Invalid directory paths
- No images found in input directory
- Insufficient disk space
- File permission issues
- Invalid dimension formats

The script should be saved as bin/image-resize (no .sh extension) and be executable.

Include comprehensive help text with examples showing both interactive and direct usage modes.
```

### Step 7: Review and Understand the Generated Code

The AI will generate a script following Shell Starter patterns. Key sections to review:

1. **Header and imports** - Sources `lib/main.sh`
2. **Help function** - Comprehensive usage examples
3. **Input validation** - Checks for ImageMagick, paths, dimensions
4. **Main logic** - Interactive vs direct modes
5. **Error handling** - Meaningful error messages with logging

### Step 8: Save and Make Executable

```bash
# Save the AI-generated code to bin/image-resize
# Make it executable
chmod +x bin/image-resize
```

---

## Phase 4: Testing & Refinement (10 minutes)

### Step 9: Run Quality Checks

```bash
# Lint the script (following Shell Starter conventions)
shellcheck bin/image-resize

# Check formatting
shfmt -d bin/image-resize

# Apply formatting fixes if needed
shfmt -w bin/image-resize
```

### Step 10: Basic Testing

```bash
# Test help and version
./bin/image-resize --help
./bin/image-resize --version

# Test dependency checking (if ImageMagick isn't installed)
# The script should gracefully handle this

# Test with invalid arguments
./bin/image-resize /nonexistent/path
./bin/image-resize /some/path invalid-dimensions
```

### Step 11: Create Test Images and Directories

```bash
# Create test directory structure
mkdir -p test-images/input test-images/output

# Add some test images to test-images/input/
# (download or copy some sample images)

# Test the interactive mode
./bin/image-resize
# Follow the prompts: input dir, output dir, dimensions

# Test direct mode
./bin/image-resize test-images/input test-images/output 800x600

# Test preview mode
./bin/image-resize --preview test-images/input 1920x1080
```

### Step 12: Handle Issues and Iterate

If you encounter issues, ask the AI to fix them:

```
The image-resize script has an issue with [describe the problem]. 

Current behavior: [what's happening]
Expected behavior: [what should happen]

Please provide the corrected code section that follows Shell Starter conventions and handles this error gracefully.
```

---

## Phase 5: Enhancement & Documentation (7 minutes)

### Step 13: Add Advanced Features

Ask the AI to enhance the script:

```
Enhance the image-resize script with these additional features:

1. **Quality settings**: Add --quality option (1-100) for JPEG compression
2. **Format conversion**: Allow output format different from input (--format jpg/png/etc)  
3. **Recursive processing**: Add --recursive flag to process subdirectories
4. **Batch operations**: Progress indicator showing "Processing image X of Y"
5. **Dry run improvements**: Better preview showing before/after file sizes

Update the help text to include these new options and provide usage examples.
Maintain Shell Starter conventions throughout.
```

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