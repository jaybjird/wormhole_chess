# Milestone 4: The Sparring Partner
**Goal:** Introduce foundational single-player mechanics so users can practice the complex movements. Implement a basic AI opponent and text-driven tutorials to help players grasp the rules.

## Tasks (Future Issues)

### 1. Basic Single-Player Architecture Setup
- Create a `PlayerMode` enum or state to differentiate human-vs-human (local) and human-vs-computer.
- Create a `BotService` (`packages/engine/lib/src/bot/`) that can accept a game state and return a move asynchronously.

### 2. Random/Greedy Bot (Level 1)
- Implement a basic evaluation function inside `BotService` (material counting: Pawn=1, Knight=3, Bishop=3, Rook=5, Queen=9).
- Implement a 1-ply search (look at all current legal moves, pick the one that captures the most valuable piece, or randomly if none).
- Ensure the bot runs asynchronously to not block the main Flutter thread (using Dart's `compute` or `Isolate.run`).

### 3. Move Execution Delay (UX Polish)
- Implement an artificial delay (e.g., 500ms) before the bot makes its move so it feels "human-like" and doesn't instantly snap.
- Add an "opponent is thinking..." visual indicator to the UI.

### 4. Interactive Help Bar & Glossary
- Implement a collapsible "Help Bar" or floating Glossary panel in the UI.
- Populate the glossary with static text and basic diagrams explaining piece movements, topological board rules, and basic mechanics.
