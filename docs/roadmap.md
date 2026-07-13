# Undertale: Dark Underground - Development Roadmap

## Overview

This document outlines the development phases and milestones for creating a complete, playable fangame.

---

## 🎯 Platform Decision: Godot Engine (PC-First)

### Why PC First?
1. **Easier Development** - Full keyboard/mouse support during development
2. **Simpler Debugging** - Better tooling and console access
3. **Foundation Building** - Core systems work on PC, then port later
4. **Free Export** - Can export to HTML5 for easy sharing, then Android later

### Platform Roadmap
| Phase | Platform | Features |
|-------|----------|----------|
| 1 | PC | Full game, all features |
| 2 | HTML5/Web | Browser play, demo sharing |
| 3 | Android | Touch controls, mobile optimization |

---

## 📋 Development Phases

### Phase 1: Foundation (Week 1-2)
**Goal**: Get the core engine running with working systems

#### Completed ✓
- [x] Project structure and organization
- [x] Core autoloads (GameManager, SaveSystem, AudioManager, DialogueManager, BattleManager, GlobalVariables)
- [x] Turn-based battle system framework
- [x] ACT, MAGIC, ITEMS, SPARE, DEFEND commands
- [x] TP gauge system
- [x] Bullet-hell attack patterns (spread, aimed, wave, random)
- [x] Typewriter dialogue system
- [x] Save/Load functionality
- [x] Basic UI framework

#### In Progress
- [ ] Demo level scene
- [ ] Test battle encounters

#### Next Steps
- [ ] Player controller refinement
- [ ] Camera system
- [ ] Basic tileset system

---

### Phase 2: Art & Assets (Week 3-6)
**Goal**: Create original pixel art sprites and animations

#### Character Sprites (16x16 base)
- [ ] Frisk (4 directions, idle, walk, run, hurt, battle)
- [ ] Dark World versions of characters
- [ ] Light World NPCs

#### Enemy Sprites
- [ ] Training Dummy
- [ ] Froggit variant
- [ ] Shadow Creature (Dark World)
- [ ] Mini-boss sprites

#### Environment Art
- [ ] Ruins tileset (interior, exterior)
- [ ] Dark World tileset
- [ ] Save point sprite
- [ ] Door/interaction sprites

#### UI Elements
- [ ] HP/TP bar graphics
- [ ] Menu backgrounds
- [ ] Battle UI buttons
- [ ] Text box graphics

#### Visual Effects
- [ ] Hit effects
- [ ] Magic spell effects
- [ ] Screen transitions
- [ ] Damage numbers

---

### Phase 3: Content (Week 7-12)
**Goal**: Build the actual game content

#### Chapter 1: "The Dark Beginning"
**Story**: Strange Dark Fountains have begun appearing in the Underground. Toriel asks you to investigate.

##### Areas
1. **Ruins (Light)** - Tutorial area
   - Toriel's house
   - Puzzle rooms (spider baking, switching puzzles)
   - Monster encounters (Froggit, Whimsun)

2. **Dark Ruins** - First Dark World
   - Transformed version of the Ruins
   - Darkner encounters
   - Ralsei joins party
   - First mini-boss

3. **Forest Path** - Optional area
   - More monster encounters
   - Hidden secrets
   - Papyrus encounter

##### Bosses
1. **Training Dummy** - Tutorial boss (can't lose)
2. **Shadow Guardian** - First real boss

##### Party System
- [ ] Frisk (always available)
- [ ] Ralsei (Dark World companion)
- [ ] Kris (joins after Dark Ruins)
- [ ] Susie (joins after first boss)

##### Puzzles
- [ ] Pressure plate puzzles
- [ ] Color matching
- [ ] Shadow puzzles (Light World only)
- [ ] Block pushing

---

### Phase 4: Polish (Week 13-16)
**Goal**: Make it feel good to play

#### Audio
- [ ] Original music (5-10 tracks)
  - Battle themes (2)
  - Area themes (3)
  - Boss themes (2)
  - Menu themes (1)
  
- [ ] Sound effects
  - UI sounds (select, confirm, cancel, move)
  - Battle sounds (attack, hit, magic, victory)
  - Environment sounds (doors, save points)

#### Game Feel
- [ ] Screen shake on hits
- [ ] Hit freeze frames
- [ ] Smooth camera follow
- [ ] Dialogue sound effects
- [ ] Inventory animations

#### Balancing
- [ ] Enemy HP/damage tuning
- [ ] Magic spell balancing
- [ ] EXP curve testing
- [ ] Difficulty options

---

### Phase 5: Testing (Week 17-20)
**Goal**: Find and fix bugs

#### Playtesting
- [ ] Internal testing
- [ ] Closed beta testing
- [ ] Bug fixes
- [ ] Balance adjustments

#### Quality Assurance
- [ ] All paths tested
- [ ] Save/load tested
- [ ] Edge cases covered
- [ ] Performance optimization

---

### Phase 6: Release (Week 21-24)
**Goal**: Get the game to players

#### PC Release
- [ ] Export build
- [ ] Create itch.io page
- [ ] Upload game
- [ ] Write description

#### HTML5 Export (Optional)
- [ ] Web optimization
- [ ] Browser testing
- [ ] Itch.io web build

---

## 🎮 Controls Specification

### Keyboard
| Action | Keys |
|--------|------|
| Move | WASD / Arrow Keys |
| Interact | Enter / Space / E |
| Cancel | Escape / Q |
| Menu | Tab |
| Confirm | Enter / Space |
| FIGHT | 1 / F |
| ACT | 2 / A |
| ITEM | 3 / I |
| MERCY | 4 / M |

### Gamepad (Future)
| Action | Button |
|--------|--------|
| Move | D-Pad / Left Stick |
| Interact | A |
| Cancel | B |
| Menu | Start |
| FIGHT | X |
| ACT | Y |
| ITEM | LB |
| MERCY | RB |

### Mobile (Future)
| Action | Input |
|--------|-------|
| Move | Virtual joystick (left) |
| Interact | Tap on target |
| Menu | Button (top-right) |

---

## 📁 File Organization

```
Project/
├── project.godot
├── README.md
├── LICENSE
│
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   │   ├── frisk/
│   │   │   ├── ralsei/
│   │   │   └── [etc]
│   │   ├── enemies/
│   │   ├── environment/
│   │   └── ui/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
│
├── data/
│   ├── enemies/
│   ├── items/
│   ├── spells/
│   └── quests/
│
├── scripts/
│   ├── autoload/
│   ├── characters/
│   ├── enemies/
│   ├── battle/
│   ├── ui/
│   └── utilities/
│
└── scenes/
    ├── core/
    ├── levels/
    ├── battles/
    └── ui/
```

---

## 🎯 Success Criteria

### MVP (Minimum Viable Product)
- [ ] Working battle system
- [ ] At least 3 enemy types
- [ ] 1 playable area
- [ ] Save/Load works
- [ ] Basic story
- [ ] Original art
- [ ] Original music (3+ tracks)

### Full Release
- [ ] All Phase 1-5 complete
- [ ] Chapter 1 playable start to finish
- [ ] 10+ enemy types
- [ ] Party system working
- [ ] Boss battles (2+)
- [ ] 60+ minutes gameplay

---

## 🛠️ Development Tools

### Required
- Godot 4.2+ (https://godotengine.org)
- Git (version control)
- Text editor (VS Code recommended)

### Recommended
- Aseprite (pixel art)
- LMMS or FL Studio (music)
- Audacity (sound editing)
- GitHub Desktop (git GUI)

---

## 📅 Timeline Estimate

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Foundation | 2 weeks | 2 weeks |
| Art & Assets | 4 weeks | 6 weeks |
| Content | 6 weeks | 12 weeks |
| Polish | 4 weeks | 16 weeks |
| Testing | 4 weeks | 20 weeks |
| Release | 4 weeks | 24 weeks |

**Total: ~6 months** (part-time development)

---

## 🤝 How to Contribute

1. **Code**: Implement features, fix bugs
2. **Art**: Create sprites, tilesets, effects
3. **Music**: Compose original tracks
4. **Writing**: Dialogue, story, descriptions
5. **Testing**: Play and report bugs

---

## 📚 Resources

### Learning
- [Godot Documentation](https://docs.godotengine.org/)
- [GDQuest Tutorials](https://www.gdquest.com/)
- [Heartbeast YouTube](https://www.youtube.com/@uheartbeast)

### Community
- [r/godot](https://reddit.com/r/godot)
- [Godot Discord](https://discord.gg/4yMxkxJ)
- [Pixel Art Discord](https://discord.gg/pixelart)

---

## ⚠️ Important Notes

1. **Original Assets Only** - Do NOT use official Undertale/Deltarune sprites, music, or other assets
2. **Free Forever** - This game will never have ads, microtransactions, or paid DLC
3. **Credit Toby Fox** - Always credit the original games that inspired this project
4. **No Copyright Infringement** - This is a transformative fan work, not a replacement for the originals

---

*Last Updated: 2024*
*Version: 0.1.0*
