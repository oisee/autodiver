# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Autodiver is a Ruby-based image transformation and evaluation tool designed for optimizing retro-style graphics (256x192 resolution). It generates multiple variations of an input image with different rotations, scales, and offsets, then evaluates them to find the best transformations.

## Common Development Commands

### Setup
```bash
bundle install  # Install Ruby dependencies (RMagick)
```

### Running the Tool
```bash
# Generate image variations
ruby gen.rb <input_image> <rot_all> <step_rot> <scale_all> <step_scale> <offset> <mask>

# Execute generated transformations
./run.sh  # On Unix/Linux/macOS
run.bat   # On Windows

# Evaluate generated images
ruby ev.rb
```

### Example Usage
```bash
# Generate variations with rotation from -5 to 5 degrees (step 1), scale 0.9 to 1.1 (step 0.05), offset 5 pixels
ruby gen.rb input.png 5 1 0.1 0.05 5

# With mask support
ruby gen.rb input.png 5 1 0.1 0.05 5 mask.png
```

## Architecture

The codebase consists of two main components:

1. **gen.rb**: Transformation generator
   - Reads command-line parameters for transformation ranges
   - Generates ImageMagick commands for all transformation combinations
   - Creates platform-specific scripts (run.sh/run.bat)
   - Outputs transformed images to `eval/` directory
   - Supports mask generation to `eval_mask/` directory

2. **ev.rb**: Image evaluator
   - Processes all images in `eval/` directory
   - Divides each 256x192 image into 8x8 pixel cells (32x24 grid)
   - Calculates error scores based on color distribution within cells
   - Supports masked evaluation using corresponding mask images
   - Outputs results to CSV files and copies best images to `best/` directory

## Key Technical Details

- Uses RMagick (Ruby ImageMagick bindings) for image processing
- Employs nearest-neighbor (point filter) scaling to preserve pixel-perfect quality
- Evaluation algorithm focuses on minimizing color complexity within 8x8 cells
- Cross-platform support with automatic OS detection for script generation
- Mask support allows excluding regions from evaluation (useful for UI elements, borders, etc.)

## Directory Structure

- `eval/`: Generated transformed images
- `eval_mask/`: Generated mask images (when using mask feature)
- `best/`: Best scoring images copied by evaluator
- Generated scripts: `run.sh` (Unix) or `run.bat` (Windows)