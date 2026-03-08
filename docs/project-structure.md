# Project Structure

This document outlines the complete directory structure of the Wormhole Chess project.

```
wormhole_chess/
├── .gitignore              # Git ignore rules (includes secrets)
├── melos.yaml              # Melos monorepo configuration
├── .windsurf/              # Windsurf AI assistant configuration
│   └── rules/              # Development rules and guidelines
│       ├── documentation.md    # Documentation rules
│       └── project-structure.md # Project structure rules
├── docs/
│   ├── setup.md           # Development setup guide
│   ├── tech-stack.md      # Technology stack overview
│   └── project-structure.md # This file - project structure
├── packages/
│   ├── app/               # Flutter UI application
│   │   ├── lib/           # Flutter app source code
│   │   ├── android/       # Android platform code
│   │   ├── ios/           # iOS platform code
│   │   ├── linux/         # Linux platform code
│   │   ├── macos/         # macOS platform code
│   │   ├── web/           # Web platform code
│   │   ├── windows/       # Windows platform code
│   │   └── pubspec.yaml   # Flutter app dependencies
│   ├── engine/            # Core chess engine (terminal game)
│   │   ├── bin/           # Executable scripts
│   │   ├── lib/           # Engine source code
│   │   └── pubspec.yaml   # Engine dependencies
│   └── models/            # Shared client-server models
│       ├── lib/           # Model definitions
│       └── pubspec.yaml   # Model dependencies
└── pubspec.yaml           # Root workspace configuration
```
