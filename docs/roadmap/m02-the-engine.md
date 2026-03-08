# Milestone 2: The Engine
**Goal:** Build the core chess rules and mathematical logic in isolation using pure Dart. Create a fully functional, mathematically validated simulation playable via a text-based interface.

## Tasks (Future Issues)

### 1. Board Representation & Coordinate System
- Define the board representation in Dart (`packages/engine/lib/src/board.dart`) as a partial torus, accounting for two planar surfaces connected by a central tunnel (e.g., 2 rings of 12 tiles).
- Implement a custom coordinate system and mathematical model to map standard squares and the curved topology of the "Wormhole" tunnel.
- Employ Test-Driven Development (TDD) by writing unit tests for board initialization and coordinate mapping before implementation.

### 2. Topological Movement Primitives
- Implement core units of movement across the non-Euclidean board.
- Calculate directional vectors (cardinal and diagonal) and define how they transition between the flat planes and the curved tunnel.
- Define behavior for moving across wormhole corners with 5 adjacent squares.
- Write extensive unit tests to validate spatial relationships and movement vectors.

### 3. Basic Piece Definitions & Movement Logic
- Define base classes/enums for standard chess pieces (`packages/engine/lib/src/pieces/`).
- Implement standard movement and capturing rules for Pawns, Knights, Bishops, Rooks, Queens, and Kings using the new topological movement primitives.
- Write TDD unit tests validating piece movements across the planes and through the tunnel.

### 4. Special Moves, State Tracking, & King Placement
- Implement the "King Placement" mechanic: Black starts the game by selecting a valid starting position for their King.
- Implement Castling, En Passant, and Pawn Promotion logic adapted for the board layout.
- Create a game state tracker (`packages/engine/lib/src/game_state.dart`) to store move history, current turn, and active player.
- Ensure state models are designed to be flexible enough to support N-players (e.g., up to 4 players) in the future.

### 5. Check, Checkmate, and Stalemate Detection
- Implement logic to detect if a King is in Check along any valid topological path.
- Implement logic to determine Checkmate and Stalemate.
- Implement the 50-move rule and Threefold Repetition draws.

### 6. Terminal Interface (CLI) & CI Setup
- Configure GitHub Actions to automatically run `melos format`, `melos analyze`, and `melos test` on every PR to enforce CI/CD standards early.
- Create a simple CLI runner in `packages/engine/bin/engine.dart`.
- Implement a text-based or rudimentary ASCII board visualizer for the CLI.
- Design and implement a custom move notation system to account for the complex board topology (2 planes, 2 rings of 12 tiles).
- Implement text parsing for the custom notation to allow CLI gameplay.
