# Advanced Transformations for ZX Spectrum Constraint Optimization

A research document exploring modern computer vision techniques, advanced loss functions, and object-aware transformations for retro graphics conversion.

## Current Limitations of Autodiver

The existing implementation uses simple affine transformations (rotation, scale, translation) with a basic color-counting loss function. While effective for basic optimization, it has several limitations:

1. **Limited transformation space**: Only explores affine transformations
2. **Global optimization**: Treats the entire image uniformly
3. **Simplistic loss function**: Only counts color violations, ignoring perceptual quality
4. **No object awareness**: Cannot independently optimize different visual elements

## Perspective and Projective Transformations

### Beyond Affine: Perspective Correction

ZX Spectrum graphics often depicted 3D scenes or isometric views. Perspective transformations could better fit complex scenes:

```ruby
# Perspective transformation matrix
# [x']   [m00 m01 m02] [x]
# [y'] = [m10 m11 m12] [y]
# [w']   [m20 m21  1 ] [1]
#
# Final coordinates: x'/w', y'/w'

def generate_perspective_variations(image, perspective_range = 0.001)
  variations = []
  
  # Vary perspective parameters
  (-perspective_range..perspective_range).step(perspective_range/10) do |px|
    (-perspective_range..perspective_range).step(perspective_range/10) do |py|
      # Create perspective matrix
      matrix = [1, 0, 0, 0, 1, 0, px, py, 1]
      variations << apply_perspective(image, matrix)
    end
  end
  
  variations
end
```

### Non-Linear Transformations

#### Barrel/Pincushion Distortion
Simulate CRT monitor distortion or correct for lens effects:

```ruby
def barrel_distortion(image, k1, k2 = 0)
  # r² = x² + y²
  # x' = x(1 + k1*r² + k2*r⁴)
  # y' = y(1 + k1*r² + k2*r⁴)
end
```

#### Keystone Correction
For images captured at angles or displayed on tilted screens:

```ruby
def keystone_transform(image, top_scale, bottom_scale)
  # Trapezoidal transformation
  # Useful for correcting perspective photography of screens
end
```

#### Wave/Ripple Effects
For artistic or technical distortion correction:

```ruby
def sine_wave_distortion(image, amplitude, frequency, direction = :horizontal)
  # x' = x + amplitude * sin(2π * frequency * y / height)
  # Useful for correcting scan line effects or artistic purposes
end
```

## Advanced Loss Functions

### Perceptual Loss Components

The current color-counting approach can be enhanced with perceptual metrics:

#### 1. Structural Similarity (SSIM) Component
```ruby
def ssim_loss(original, transformed, window_size = 8)
  # Calculate SSIM for each 8x8 window
  # Penalize structural distortions that affect recognizability
  
  total_ssim = 0
  window_count = 0
  
  (0...height).step(window_size) do |y|
    (0...width).step(window_size) do |x|
      window_orig = extract_window(original, x, y, window_size)
      window_trans = extract_window(transformed, x, y, window_size)
      
      ssim = calculate_ssim(window_orig, window_trans)
      total_ssim += ssim
      window_count += 1
    end
  end
  
  1.0 - (total_ssim / window_count)  # Convert to loss (lower SSIM = higher loss)
end
```

#### 2. Edge Preservation Loss
```ruby
def edge_preservation_loss(original, transformed)
  # Detect edges in both images
  edges_orig = detect_edges(original)
  edges_trans = detect_edges(transformed)
  
  # Penalize edge displacement/loss
  edge_similarity = compare_edge_maps(edges_orig, edges_trans)
  1.0 - edge_similarity
end
```

#### 3. Frequency Domain Loss
```ruby
def frequency_domain_loss(original, transformed)
  # Compare DCT coefficients to preserve important frequencies
  dct_orig = discrete_cosine_transform(original)
  dct_trans = discrete_cosine_transform(transformed)
  
  # Weight lower frequencies more heavily (more perceptually important)
  weights = create_frequency_weights(dct_orig.size)
  weighted_diff = (dct_orig - dct_trans).abs * weights
  
  weighted_diff.sum / weights.sum
end
```

### Multi-Objective Loss Function

Combine multiple criteria with learned or manually tuned weights:

```ruby
def comprehensive_loss(original, transformed, weights = {})
  w = {
    color_clash: 0.4,
    ssim: 0.2,
    edge_preservation: 0.2,
    frequency: 0.1,
    contrast: 0.1
  }.merge(weights)
  
  losses = {
    color_clash: color_clash_loss(transformed),
    ssim: ssim_loss(original, transformed),
    edge_preservation: edge_preservation_loss(original, transformed),
    frequency: frequency_domain_loss(original, transformed),
    contrast: contrast_preservation_loss(original, transformed)
  }
  
  total_loss = 0
  losses.each { |type, loss| total_loss += w[type] * loss }
  
  { total: total_loss, components: losses }
end
```

## Object Detection and Segmentation

### Modern Object Detection Integration

Use YOLO, R-CNN, or similar models to identify distinct objects for independent optimization:

```ruby
def detect_objects(image)
  # Use pre-trained model (via Python bridge or API)
  objects = call_object_detector(image)
  
  objects.map do |obj|
    {
      class: obj[:class],
      confidence: obj[:confidence],
      bbox: obj[:bounding_box],
      mask: generate_object_mask(image, obj[:bbox])
    }
  end
end
```

### Semantic Segmentation for Fine-Grained Control

```ruby
def semantic_segmentation(image)
  # Segment image into regions: sky, ground, characters, UI, etc.
  segments = call_segmentation_model(image)
  
  segments.group_by { |pixel| pixel[:class] }
end
```

### Object-Aware Transformation Pipeline

```ruby
def optimize_with_object_awareness(image)
  objects = detect_objects(image)
  
  best_transformations = {}
  
  objects.each do |object|
    # Extract object region
    object_region = extract_region(image, object[:mask])
    
    # Optimize transformation for this object independently
    best_transform = optimize_object_transformation(
      object_region, 
      object[:class],
      priority: get_object_priority(object[:class])
    )
    
    best_transformations[object[:id]] = best_transform
  end
  
  # Compose final image from optimized objects
  compose_optimized_image(image, objects, best_transformations)
end
```

## Constraint-Aware Object Optimization

### Priority-Based Optimization

Different objects require different optimization strategies:

```ruby
def get_optimization_strategy(object_class)
  strategies = {
    'person' => {
      priority: :high,
      preserve_edges: true,
      allow_color_reduction: false,
      transformation_limits: { rotation: 2, scale: 0.05 }
    },
    'background' => {
      priority: :low,
      preserve_edges: false,
      allow_color_reduction: true,
      transformation_limits: { rotation: 10, scale: 0.2 }
    },
    'text' => {
      priority: :highest,
      preserve_edges: true,
      allow_color_reduction: false,
      transformation_limits: { rotation: 0.5, scale: 0.01 }
    },
    'ui_element' => {
      priority: :high,
      snap_to_grid: true,  # Align with 8x8 boundaries
      preserve_edges: true,
      transformation_limits: { rotation: 0, scale: 0 }
    }
  }
  
  strategies[object_class] || strategies['background']
end
```

### Constraint Stencil System

Define different constraint templates for different object types:

```ruby
class ConstraintStencil
  def initialize(type)
    @constraints = load_constraint_template(type)
  end
  
  def evaluate(image_region)
    case @constraints[:type]
    when :spectrum_2color
      evaluate_2color_constraint(image_region)
    when :spectrum_monochrome
      evaluate_monochrome_constraint(image_region)
    when :amstrad_4color
      evaluate_4color_constraint(image_region)
    when :flexible
      evaluate_flexible_constraint(image_region)
    end
  end
end

def load_constraint_template(type)
  templates = {
    character_sprite: {
      type: :spectrum_2color,
      strict: true,
      grid_aligned: true
    },
    background_tile: {
      type: :spectrum_2color,
      strict: false,  # Allow some violations for better appearance
      dithering_allowed: true
    },
    ui_text: {
      type: :spectrum_monochrome,
      strict: true,
      high_contrast: true
    },
    decorative_element: {
      type: :flexible,
      max_colors_per_cell: 3,  # Relaxed constraint
      artistic_priority: true
    }
  }
  
  templates[type]
end
```

## Advanced Optimization Algorithms

### Genetic Algorithm for Transformation Discovery

```ruby
class TransformationEvolution
  def initialize(population_size = 100, generations = 50)
    @population_size = population_size
    @generations = generations
  end
  
  def evolve(image, target_constraints)
    population = initialize_random_population
    
    @generations.times do |gen|
      # Evaluate fitness of each individual
      fitness_scores = population.map { |individual| 
        evaluate_fitness(apply_transformation(image, individual), target_constraints)
      }
      
      # Selection, crossover, mutation
      population = genetic_operations(population, fitness_scores)
      
      puts "Generation #{gen}: Best fitness = #{fitness_scores.max}"
    end
    
    # Return best individual
    best_index = fitness_scores.index(fitness_scores.max)
    population[best_index]
  end
  
  private
  
  def initialize_random_population
    @population_size.times.map do
      {
        rotation: rand(-10.0..10.0),
        scale_x: rand(0.8..1.2),
        scale_y: rand(0.8..1.2),
        translate_x: rand(-20..20),
        translate_y: rand(-20..20),
        perspective_x: rand(-0.001..0.001),
        perspective_y: rand(-0.001..0.001),
        barrel_distortion: rand(-0.1..0.1)
      }
    end
  end
end
```

### Simulated Annealing for Local Optimization

```ruby
def simulated_annealing_optimize(image, initial_transform, max_iterations = 1000)
  current_transform = initial_transform.dup
  current_loss = evaluate_loss(apply_transformation(image, current_transform))
  
  temperature = 1.0
  cooling_rate = 0.995
  
  best_transform = current_transform.dup
  best_loss = current_loss
  
  max_iterations.times do |iteration|
    # Generate neighbor solution
    neighbor = mutate_transformation(current_transform, temperature)
    neighbor_loss = evaluate_loss(apply_transformation(image, neighbor))
    
    # Accept or reject based on probability
    if neighbor_loss < current_loss || 
       rand < Math.exp(-(neighbor_loss - current_loss) / temperature)
      current_transform = neighbor
      current_loss = neighbor_loss
      
      if neighbor_loss < best_loss
        best_transform = neighbor.dup
        best_loss = neighbor_loss
      end
    end
    
    temperature *= cooling_rate
  end
  
  best_transform
end
```

## Modern Deep Learning Integration

### Neural Style Transfer for Constraint Adaptation

Train a neural network to learn ZX Spectrum style conversion:

```python
# Pseudo-code for integration
class SpectrumStyleTransfer:
    def __init__(self):
        self.model = load_pretrained_model("spectrum_converter.pth")
    
    def convert(self, image):
        # Apply learned transformation that respects ZX Spectrum constraints
        return self.model.predict(image)
    
    def fine_tune(self, image_pairs):
        # Fine-tune on specific image types or artistic styles
        self.model.train(image_pairs)
```

### Reinforcement Learning for Transformation Discovery

```python
class TransformationAgent:
    def __init__(self):
        self.q_network = build_dqn()
        self.experience_buffer = []
    
    def choose_transformation(self, image_state):
        # Choose next transformation action based on learned policy
        q_values = self.q_network.predict(image_state)
        return select_action(q_values)
    
    def learn(self, state, action, reward, next_state):
        # Update policy based on constraint satisfaction reward
        self.experience_buffer.append((state, action, reward, next_state))
        if len(self.experience_buffer) > batch_size:
            self.train_on_batch()
```

## Implementation Roadmap

### Phase 1: Enhanced Loss Functions
1. Implement SSIM and edge preservation metrics
2. Add frequency domain analysis
3. Create multi-objective optimization framework

### Phase 2: Advanced Transformations
1. Add perspective transformation support
2. Implement non-linear distortion corrections
3. Create transformation composition pipeline

### Phase 3: Object Detection Integration
1. Integrate modern object detection models
2. Implement object-aware optimization
3. Create constraint stencil system

### Phase 4: Advanced Optimization
1. Implement genetic algorithm search
2. Add simulated annealing for local optimization
3. Create hybrid optimization strategies

### Phase 5: Deep Learning Integration
1. Train domain-specific style transfer models
2. Implement reinforcement learning agents
3. Create end-to-end neural optimization pipeline

## Conclusion

These advanced techniques could significantly improve Autodiver's ability to create high-quality retro graphics while respecting historical constraints. The combination of modern computer vision, advanced optimization algorithms, and domain-specific knowledge about retro computing limitations offers exciting possibilities for automated graphics conversion.

The key insight is moving from global, uniform optimization to object-aware, context-sensitive approaches that can make intelligent trade-offs based on the semantic content of the image and the specific requirements of different visual elements.