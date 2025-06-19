# Autodiver

A specialized image optimization tool for converting modern graphics to retro computer formats, specifically designed to minimize color clash artifacts in classic 8-bit systems.

## Historical Context and Purpose

### The Color Clash Problem

In the 1980s, home computers like the ZX Spectrum, Amstrad CPC, and MSX had severe graphical limitations that created a phenomenon known as **"color clash"** or **"attribute clash"**. These systems could display colorful graphics, but with strict constraints:

- **ZX Spectrum**: Only 2 colors allowed per 8×8 pixel block
- **Amstrad CPC Mode 1**: Only 4 colors per 8×8 character cell  
- **MSX**: Similar attribute-based color restrictions

When artists tried to create detailed graphics that violated these constraints, the result was jarring visual artifacts where colors would "bleed" into adjacent areas, creating the infamous color clash effect that plagued many games and applications of the era.

### Modern Challenge: Retro Graphics Conversion

Today, there's renewed interest in creating content for retro systems - whether for:
- **Game development** targeting classic platforms
- **Digital art** in authentic retro styles  
- **Historical preservation** of classic computer aesthetics
- **Homebrew software** for vintage machines

However, manually converting modern images to respect these historical constraints is extremely tedious. Artists often have to:
1. Manually adjust colors pixel by pixel
2. Compromise image composition to avoid color clash
3. Go through countless iterations to find the optimal version

### Autodiver's Solution

Autodiver automates this optimization process by:

1. **Generating variations**: Creates hundreds of slightly different versions of your image through rotation, scaling, and positioning adjustments
2. **Evaluating constraints**: Uses a sophisticated algorithm that analyzes each 8×8 pixel cell and penalizes violations of retro color limitations
3. **Finding optimal compromises**: Identifies which transformations minimize color clash while preserving the original image's visual impact

The tool essentially performs the tedious manual work that retro graphics artists previously had to do by hand, testing combinations that would take hours to evaluate manually.

## How It Works

### The Evaluation Algorithm

Autodiver divides images into a 32×24 grid of 8×8 pixel cells (covering the classic 256×192 resolution) and analyzes each cell:

1. **Color counting**: Counts how many pixels of each color appear in the cell
2. **Constraint checking**: Identifies cells using more than 2 colors (the ZX Spectrum limit)
3. **Penalty calculation**: Assigns error scores based on "excess" colors beyond the limit
4. **Optimization**: Finds image variations that minimize these penalties

### The Transformation Process

1. **Input**: Provide a source image and transformation parameters
2. **Generation**: Creates a grid of variations with different rotations, scales, and positions  
3. **Batch processing**: Generates ImageMagick commands to create all variations
4. **Evaluation**: Analyzes each variation for color clash violations
5. **Selection**: Identifies the best compromises between fidelity and constraint compliance

## Target Systems

While the 256×192 resolution and evaluation algorithm are optimized for ZX Spectrum-style constraints, the tool can be adapted for other retro systems:

- **ZX Spectrum** (2 colors per 8×8 cell)
- **Amstrad CPC** (4 colors per character cell)
- **MSX computers** (similar attribute limitations)
- **Early Atari ST** modes
- Any system with block-based color constraints

## Installation

```bash
# Install Ruby dependencies
bundle install
```

Requires RMagick (Ruby ImageMagick bindings).

## Usage

### Basic Workflow

1. **Generate variations**:
```bash
ruby gen.rb input.png 5 1 0.1 0.05 5
```
Parameters: `<input> <rotation_range> <rotation_step> <scale_range> <scale_step> <offset>`

2. **Execute transformations**:
```bash
./run.sh    # Unix/Linux/macOS  
run.bat     # Windows
```

3. **Evaluate results**:
```bash
ruby ev.rb
```

### Advanced: Using Masks

Masks let you protect important areas from optimization:

```bash
ruby gen.rb input.png 5 1 0.1 0.05 5 mask.png
```

This is useful for:
- Preserving text or UI elements
- Protecting key visual details
- Focusing optimization on background areas

## Output

- **`eval/`**: All generated image variations
- **`best/`**: Top-scoring images that minimize color clash
- **CSV files**: Detailed scoring data for analysis
- **Platform scripts**: `run.sh`/`run.bat` for batch processing

## Why This Matters

Autodiver bridges the gap between modern digital art tools and historical computing constraints. It enables:

- **Authentic retro aesthetics** without manual tedium
- **Historically accurate** graphics for period-appropriate software
- **Artistic exploration** of classic computing limitations
- **Preservation** of retro computing culture and aesthetics

By automating the optimization process, artists can focus on creativity rather than the technical constraints of 40-year-old hardware, while still achieving authentic results that would run perfectly on the original machines.

## Technical Details

- **Language**: Ruby with RMagick
- **Image processing**: Uses nearest-neighbor scaling to preserve pixel-perfect quality
- **Cross-platform**: Generates appropriate scripts for Unix and Windows
- **Evaluation**: Custom algorithm designed around 8×8 cell color constraints
- **Output format**: Optimized for 256×192 retro resolution