# PhysicsPuzzle

A physics-based puzzle game where you strategically place objects to guide falling boxes into target areas while avoiding hazards.

## About

PhysicsPuzzle is a challenging puzzle game built with Godot Engine 4.5. Use different types of physics objects to create paths, bounce projectiles, and solve increasingly complex puzzles across 5 unique levels.

## Features

- **5 Progressive Levels** - Each level introduces new mechanics and challenges
- **4 Object Types** - Regular boxes, bouncy balls, heavy objects, and light floaters
- **Timer System** - Track your completion time for each level
- **Scoring System** - Earn points based on speed and efficiency
  - Base Score: 1000 points per level
  - Time Bonus: Up to 500 points for beating par time
  - Efficiency Bonus: Up to 500 points for using fewer objects
  - Maximum Score: 8750 points (perfect game)
- **Par System** - Target benchmarks for time and object usage
- **Particle Effects** - Visual feedback for spawning, success, destruction, and victory
- **Resource Management** - Limited objects per level encourage strategic thinking

## Gameplay

### Controls

- **1-4 Keys** - Select object type (Regular Box, Bouncy Ball, Heavy Object, Light Floater)
- **Mouse Click** - Place selected object in the game world
- **ESC** - Quit game

### Object Types

1. **Regular Box** (Blue) - Standard physics object with normal bounce
2. **Bouncy Ball** (Green) - Circular object with high bounce, useful for momentum
3. **Heavy Object** (Gray) - High mass, moves slower, useful for anchoring
4. **Light Floater** (Yellow) - Low mass with air friction, floats and drifts

### Level Par Times & Objects

| Level | Par Time | Par Objects | Description |
|-------|----------|-------------|-------------|
| 1     | 30s      | 4           | Tutorial level |
| 2     | 35s      | 4           | Bouncy platforms |
| 3     | 40s      | 5           | Hazard introduction |
| 4     | 45s      | 6           | Moving targets |
| 5     | 60s      | 8           | Ultimate challenge |

## Getting Started

### Prerequisites

- [Godot Engine 4.5](https://godotengine.org/download) or later

### Running the Game

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd physics-puzzle
   ```

2. Open the project in Godot Engine 4.5+

3. Press **F5** or click the **Play** button to run the game

### Building for Distribution

The project includes export presets. To create executable builds:

1. In Godot, go to **Project → Export**
2. Select the target platform (Windows, Linux, macOS)
3. Click **Export Project**
4. Builds will be saved to the `builds/` directory

See `builds/HOW_TO_CREATE_RELEASE.txt` for detailed release instructions.

## Project Structure

```
physics-puzzle/
├── scenes/
│   ├── main.tscn          # Main game scene
│   ├── main.gd            # Core game logic (560 lines)
│   ├── box.tscn           # Box physics object
│   └── target.tscn        # Target area
├── builds/                # Exported game builds
├── project.godot          # Godot project configuration
├── export_presets.cfg     # Build export settings
├── icon.svg               # Game icon
├── POLISH_FEATURES.md     # Detailed feature documentation
└── README.md              # This file
```

## Development

### Main Game Systems

- **Level Management** - 5 hardcoded levels with unique obstacles and requirements
- **Physics Objects** - Custom physics properties per object type
- **Scoring Algorithm** - Calculates bonuses based on time and efficiency
- **Particle Systems** - Blue (spawn), Green (success), Red (destruction), Gold (victory)
- **UI System** - Real-time timer, score tracking, and resource counters

### Key Functions

- `load_level(level_index)` - Loads and initializes level
- `calculate_score()` - Computes level score with bonuses
- `create_*_effect()` - Particle effect generators
- `check_win_condition()` - Victory detection and scoring

## Tips & Strategies

- **Plan Ahead** - Limited objects mean every placement counts
- **Beat Par** - Complete levels under par time for maximum time bonus
- **Minimize Objects** - Using fewer objects increases efficiency bonus
- **Object Synergy** - Combine different object types for creative solutions
- **Hazard Awareness** - Red areas destroy objects, avoid them!

## Version History

- **v1.0** - Professional polish features: timer, scoring, particles
  - Added comprehensive scoring system
  - Implemented particle effects
  - Added par time/object benchmarks
  - Enhanced UI with timer and score display
- **Beta** - Enhanced gameplay mechanics with unique puzzle challenges
- **Alpha** - Initial release with falling boxes and basic physics

## License

This project is available for personal and educational use.

## Acknowledgments

Built with [Godot Engine](https://godotengine.org/) - Open source game engine

---

**Current Version:** 1.0  
**Engine:** Godot 4.5  
**Status:** Feature Complete
