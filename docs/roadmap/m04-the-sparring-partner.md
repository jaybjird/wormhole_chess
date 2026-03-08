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

### 4. Interactive Tutorial Data Structure
<!-- TODO: The first pass of the tutorial should be very basic. Something like a help bar, or glossary that the user can open and look through on their own. More sophisticated tutorials will be added later. -->
- Define a `TutorialStep` model containing: initial FEN, target move(s), explanatory text, and success conditions.
- Create a JSON or Dart list of predefined tutorial scenarios focusing on standard moves and wormhole mechanics.

### 5. Tutorial UI Overlay & Progression Logic
<!-- TODO: We can skip this until the mentor milestone -->
- Implement a Flutter overlay (`lib/src/features/tutorial/presentation/`) displaying the tutorial text and a "Next" or "Skip" button.
- Implement logic to load the specific tutorial FEN into the board.
- Restrict user interaction to *only* allow the correct tutorial move.
- Upon successful execution of the tutorial move, advance to the next step.

### 6. Wormhole Specific Tutorials
<!-- TODO: We'll need something like this, but again, the wormhole is the topology of the board, so we'll need to think about how to present this in a way that's intuitive to the user. -->
- Create a tutorial specifically demonstrating moving onto a wormhole.
- Create a tutorial demonstrating capturing via a wormhole.
- Create a tutorial demonstrating blocking a wormhole exit or handling occupied wormholes.
