# Milestone 2: The Engine
**Goal:** Build the core chess rules and mathematical logic in isolation using pure Dart. Create a fully functional, mathematically validated simulation playable via a text-based interface.

## Tasks (Future Issues)

### 1. Board Representation & Coordinate System
- Define the board representation in Dart (`packages/engine/lib/src/board.dart`).
- Implement the coordinate system to handle standard squares and "Wormhole" special squares.
- Write unit tests for board initialization.

### 2. Basic Piece Definitions & Movement Logic
- Define base classes/enums for standard chess pieces (`packages/engine/lib/src/pieces/`).
<!-- TODO: Due to the topology of the board, our first task is to implement core units of movement. What direction is a piece moving in, and how does that interact with the wormhole? How do wormhole corners with 5 adjacent squares work? How do we calculate cardinal and diagonal movements in this context? Once that is done we can implement the standard movement and capturing rules for each piece.-->
- Implement standard movement and capturing rules for Pawns, Knights, Bishops, Rooks, Queens, and Kings.
- Write unit tests validating standard piece movements.

### 3. Special Moves & State Tracking
- Implement Castling logic (King and Rook movement, checking for previous moves, and checking if squares are under attack).
- Implement En Passant logic (tracking previous pawn double-moves).
- Implement Pawn Promotion logic.
- Create a game state tracker (`packages/engine/lib/src/game_state.dart`) to store move history, current turn, and active player.

### 4. Check, Checkmate, and Stalemate Detection
- Implement logic to detect if a King is in Check.
- Implement logic to determine Checkmate (no legal moves available to escape Check).
- Implement logic to determine Stalemate (no legal moves available, but not in Check).
- Implement the 50-move rule and Threefold Repetition draws.

### 5. Wormhole Teleportation Mechanics
<!-- TODO: The wormhole mechanic is not an instant teleport. Rather the board is a partial torus and the wormhole is a path that connects two planes of the board through a tunnel in the center. This complex but also the core distinguishing feature of the game, so this needs to be baked into the board representation and movement logic from the start.-->
- Implement the core "Wormhole" mechanic: allow pieces landing on a designated wormhole square to instantly teleport to any other designated wormhole square.
- Update move generation to include teleportation options.
- Write unit tests specifically for wormhole edge cases (e.g., teleporting into check, blocking paths).
<!-- TODO: black should start the game by selecting a valid starting position for their king -->

### 6. Terminal Interface (CLI)
- Create a simple CLI runner in `packages/engine/bin/engine.dart`.
- Implement a text-based board visualizer (ASCII/Unicode).
<!-- TODO: we'll need custom move notation since the board consists of 2 planes,
and 2 rings of 12 tiles in the tunnel between them.-->
- Implement text parsing for standard algebraic notation (SAN) or coordinate notation (e.g., `e2e4`) to allow users to play a game via the terminal.
