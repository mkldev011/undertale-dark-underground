# Undertale: Dark Underground

A free, non-commercial 2D fangame inspired by **Undertale** and **Deltarune**, created for educational and entertainment purposes.

> **Credit**: This project is inspired by Toby Fox's Undertale and Deltarune. All original code, art, and music are created specifically for this fan project.

## ⚠️ Disclaimer

This is a **fan game** made purely for:
- Educational purposes
- Entertainment value
- Demonstrating game development skills

**No monetization, ads, donations, or commercial use.**

---

## 🎮 Platform Recommendation

### **Recommended: Godot Engine (PC)**

We recommend **Godot 4.2+** for this project:

| Platform | Pros | Cons |
|----------|------|------|
| **PC (Godot)** | Easy development, full features, free export | Desktop only initially |
| **Android** | Wide reach, mobile play | Complex controls, performance tuning needed |
| **Web (HTML5)** | No install, easy sharing | Performance limits, limited storage |

### Why Godot?
- ✅ **100% Free & Open Source** (MIT license)
- ✅ **2D-focused** with dedicated tools
- ✅ **Built-in pixel art support**
- ✅ **Easy exports** to PC, Android, HTML5, Switch
- ✅ **Lightweight** - runs on low-end hardware
- ✅ **No royalties** ever

### Future Platforms (can be exported later):
1. **Android** - Requires touch controls implementation
2. **HTML5/Web** - Great for demos and sharing
3. **Consoles** - Requires additional licensing

---

## 📁 Project Structure

```
undertale_dark_underground/
├── assets/
│   ├── sprites/
│   │   ├── characters/    # Player, NPCs
│   │   ├── enemies/       # Battle sprites
│   │   ├── environment/   # Tiles, backgrounds
│   │   └── ui/            # Menus, buttons
│   ├── tilesets/          # Game maps
│   ├── maps/              # Level data
│   ├── effects/           # Visual effects
│   └── particles/        # Particle systems
│
├── audio/
│   ├── music/             # Original music
│   ├── sound_effects/    # UI, combat, etc.
│   └── voice/             # (optional)
│
├── scripts/
│   ├── core/             # GameManager, SaveSystem, etc.
│   ├── systems/           # Combat, dialogue, inventory
│   ├── characters/       # Character classes
│   ├── enemies/           # Enemy AI
│   ├── battle/           # Battle mechanics
│   ├── ui/               # Interface scripts
│   └── puzzles/          # Puzzle logic
│
├── scenes/
│   ├── core/             # Main menu, etc.
│   ├── levels/           # Game levels
│   ├── battles/          # Battle scenes
│   ├── dialogue/         # Dialogue sequences
│   ├── ui/               # UI components
│   └── puzzles/          # Puzzle rooms
│
├── dialogue/
│   └── json/             # Dialogue data
│
├── data/
│   ├── characters/       # Character definitions
│   ├── enemies/          # Enemy stats
│   ├── items/            # Item database
│   ├── spells/           # Magic spells
│   └── quests/           # Quest definitions
│
├── resources/
│   ├── shaders/          # Visual shaders
│   ├── themes/           # UI themes
│   └── styles/           # Button styles
│
└── docs/
    └── roadmap.md        # Development roadmap
```

---

## 🚀 Getting Started

### Prerequisites
- Godot 4.2+ ([Download](https://godotengine.org/download))
- Git (for version control)

### Setup Instructions

1. **Clone or download** this repository
2. **Open Godot** and import the project:
   - Click "Import"
   - Select `project.godot` file
   - Click "Import & Edit"
3. **Run the project** by pressing F5

### Controls
| Action | Keyboard |
|--------|----------|
| Move | WASD / Arrow Keys |
| Confirm / Interact | Enter / Space / E |
| Cancel / Menu | Escape / Q |
| Pause | Start / Tab |

---

## 🎯 Features

### Implemented
- [x] Core game loop and state management
- [x] Turn-based battle system
- [x] FIGHT, ACT, ITEM, MERCY, SPARE commands
- [x] TP gauge for magic system
- [x] Bullet-hell attack patterns
- [x] Typewriter-style dialogue
- [x] Save/Load system
- [x] Audio management

### Planned
- [ ] Character sprites and animations
- [ ] Multiple playable characters (party system)
- [ ] Chapter 1 complete storyline
- [ ] Puzzle dungeon mechanics
- [ ] Boss battles with unique mechanics
- [ ] Original music compositions
- [ ] Dark World/Dark Fountain mechanics

---

## 🎨 Story Overview

**The Setup**: Strange Dark Fountains have begun appearing throughout the Underground, transforming familiar locations into Dark Worlds. Frisk hasn't fallen yet. The monsters must investigate these mysterious events.

### Characters
**Undertale Characters**: Toriel, Sans, Papyrus, Undyne, Alphys, Asgore, Flowey, Mettaton, Napstablook

**Deltarune Characters**: Kris, Susie, Ralsei, Noelle, Berdly, Lancer, Rouxls Kaard, Queen

---

## 🛠️ Development Guidelines

### Code Style
- Use GDScript for all game logic
- Follow Godot naming conventions
- Comment complex systems
- Keep functions focused and small

### Art Guidelines
- **Resolution**: 1280x720 viewport, pixel-perfect rendering
- **Sprite Size**: 16x16 base, up to 64x64 for detailed sprites
- **Style**: 2D pixel art, inspired by Undertale/Deltarune but original
- **Color Palette**: Limited palette per sprite, high contrast

### Audio Guidelines
- **Music**: Original compositions inspired by Toby Fox's style
- **SFX**: Retro-style sound effects
- **Format**: OGG for music, WAV for SFX

---

## 📜 License

This is a **non-commercial fan project**. 

- All original code is MIT licensed
- All original art/music is CC0 (public domain)
- Do NOT use official Undertale/Deltarune assets

**You are free to**:
- Study this code
- Use it for learning
- Modify it for personal use
- Share with others

**You may NOT**:
- Monetize this project
- Claim ownership of Toby Fox's IP
- Use official game assets

---

## 🤝 Contributing

This is an open project. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📖 Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript API](https://docs.godotengine.org/en/stable/classes/)
- [Pixel Art Tutorial](https://pixelart.fandom.com/wiki/Pixel_Art_Tutorial)
- [Game Audio Tutorial](https://www.gamedeveloper.com/)

---

## 📅 Roadmap

### Phase 1: Foundation (Current)
- [x] Project structure
- [x] Core engine systems
- [x] Battle system framework
- [x] Dialogue system

### Phase 2: Content
- [ ] Original character sprites
- [ ] Original enemy designs
- [ ] Level 1 map design
- [ ] Basic puzzle implementation

### Phase 3: Polish
- [ ] Original music
- [ ] Sound effects
- [ ] Visual effects
- [ ] Playtesting

### Phase 4: Expansion
- [ ] Android export
- [ ] Chapter 2+
- [ ] Additional features

---

## 📬 Contact

For questions about this project:
- This is a fan project for educational purposes
- No official support available
- Feel free to fork and modify!

---

**Remember**: This game is made with love for the Undertale and Deltarune communities. Keep it free, keep it respectful, and have fun creating!
