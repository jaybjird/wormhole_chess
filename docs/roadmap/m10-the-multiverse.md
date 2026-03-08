# Milestone 10: The Multiverse
**Goal:** Scale the game engine to support multi-sided matches, encompassing both 2v2 Team alliances and Free-For-All (FFA) combat. Update the foundation to handle N-player turn indices, expand custom piece placement, and introduce chaotic party modes.

## Tasks (Future Issues)

### 1. 4-Player Engine Refactoring
<!-- TODO: This should be taken into consideration from the start of the engine
and uplink so our models and schemas are flexible enough to handle N players from the beginning -->
- Refactor the core `GameState` and turn logic in `packages/engine` to use an array/list of active players rather than a binary enum (White/Black).
- Implement a cyclical turn index manager.
- Update check/checkmate detection to correctly evaluate threats from multiple opponents simultaneously.

### 2. Multi-Sided Board Configurations
- Create new initial board setups (FEN equivalents) designed for 3-player and 4-player games.
- Extend the board coordinate system if necessary (e.g., adding additional starting ranks for extra players).
<!-- TODO: Friendly fire not allowed in team mode -->
- Define "Team" vs "FFA" rulesets (e.g., order of play, who chooses starting locations, etc.).

### 3. Player Elimination & "Zombie" States
<!-- TODO: In 4 player modes, there is no checkmate or stalemate. Players will be notified when they are put in check, or their own move would cause them to be, but
players must have their king captured to be eliminated. Once eliminated, their pieces become inert, capturable, obstacles on the board. -->
- Implement logic for what happens when a player is checkmated in an FFA game.
- Option A (Zombie): Their pieces become inert obstacles on the board.
- Option B (Inheritance): The player who delivered the checkmate gains control of the remaining pieces.
- Option C (Void): All their remaining pieces are instantly removed from the board.

### 4. 4-Player UI Scaling
- Update the Flutter UI to gracefully handle and display 4 distinct player areas (timers, captured pieces, avatars).
- Ensure the board rotation makes sense for all local players (if playing hot-seat on a tablet) or appropriately locks perspective for online play.
- Add distinct color palettes for the 3rd and 4th players (e.g., Red and Blue -TBD- alongside Black and White).

### 6. Expanded Multiplayer Networking
- Update Appwrite database schemas and Edge Functions to handle more than two players per Game document.
- Ensure the matchmaking system can populate 4-player lobbies correctly.
