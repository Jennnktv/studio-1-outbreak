# Reverse Horror Game Project

A Godot project for a reverse horror game where you play as an infected entity struggling to balance infection and scavenging for stims. The team was assembled on reddit with the intention to submit entries to the below game jams:
 - https://itch.io/jam/reverse-horror
 - https://itch.io/jam/the-outbreak-jam

The rough GDD can be found here:  https://chatgpt.com/canvas/shared/67a6aa8b17e08191add3ba54ae35439e

## Features

- **Reverse Horror Concept:** Assume the role of a zombie-like entity that must infect humans or scavenge for stims to stave off withdrawal.
- **Modular Structure:** Organized folder hierarchy for assets, scenes, scripts, docs, and config files to support a growing codebase.
- **Scalable & Maintainable:** Clear separation of concerns with autoload managers and dedicated folders for gameplay logic.
- **Documentation Included:** Design documents and planning notes are available in the `docs/` folder.

## Getting Started

Clone this repository and open it in Godot. For setup instructions and development guidelines, refer to the documentation in the `docs/` folder.


## Initial Folder Structure
```
ProjectName/
├── addons/                 # Third-party plugins or tools
│   └── (plugin folders)
├── assets/                 # All art, audio, shaders, and general non-code resources
│   ├── art/
│   │   ├── characters/     # Character art assets (sprites, animations, etc.)
│   │   │   ├── player/   
│   │   │   │   ├── idle.png
│   │   │   │   └── run_anim.png
│   │   │   └── human/      # Assets for NPCs
│   │   │       ├── idle.png
│   │   │       └── alert.png
│   │   ├── environments/   # Backgrounds, tilesets, props (e.g. urban decay, broken platforms)
│   │   └── ui/             # UI elements, icons, fonts, etc.
│   │       ├── icons/
│   │       └── fonts/
│   ├── audio/
│   │   ├── music/          # Background music tracks
│   │   └── sfx/            # Sound effects (infection sound, withdrawal effects, etc.)
│   ├── shaders/            # Custom shader files (for distortion effects, etc.)
│   └── animations/         # Shared animation resources (if not embedded per scene)
├── scenes/                 # Godot scene files
│   ├── main_menu.tscn      # Main menu 
│   ├── hud.tscn            # HUD overlay (sanity bar)
│   ├── levels/             # Level scenes organized by risk/difficulty
│   │   ├── level_high_risk.tscn   # Areas with many humans but few stims
│   │   └── level_low_risk.tscn    # Areas with more stims and fewer distractions
│   ├── characters/         # Scenes for in-game entities
│   │   ├── player.tscn     # The player’s base scene 
│   │   └── human.tscn      # NPC/human scene that can be infected
│   └── ui/                 # Additional UI screens (pause, game over, etc.)
│       ├── pause_menu.tscn
│       └── game_over.tscn
├── scripts/                # GDScript code files
│   ├── core/               # Global managers and autoloads
│   │   ├── game_manager.gd      # Oversees game loop, win/loss, progression
│   │   ├── ui_manager.gd        # Controls HUD and UI transitions
│   │   └── audio_manager.gd     # Plays music, SFX, and handles volume transitions
│   ├── characters/         # Scripts related to characters and entities
│   │   ├── infected.gd          # Player behavior and infection mechanics
│   │   ├── human.gd             # Human behavior (and reaction to infection)
│   │   └── infection_mechanic.gd # Logic for infecting humans, spawning helpers, etc.
│   ├── gameplay/           # Scripts for core systems and gameplay mechanics
│   │   ├── scavenging.gd        # Handling searches for stims in various areas
│   │   ├── withdrawal.gd        # Effects and logic when stims run low
│   │   └── navigation.gd        
│   └── utilities/          # Helper functions and common tools
│       ├── math_helpers.gd      # E.g. vector math for movement or effects
│       └── debug.gd             # Debug tools/logging functions
├── docs/                   # Documentation and design notes
│   ├── GDD.md              
│   └── design_notes.md     # Additional planning, brainstorming, and reference notes
└── config/                 # Project configuration files
    ├── input_map.tres      # Input mappings (actions, key bindings)
    └── project_settings.tres
```