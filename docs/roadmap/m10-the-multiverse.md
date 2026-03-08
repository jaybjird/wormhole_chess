# Milestone 10: The Multiverse
**Goal:** Scale the game engine to support multi-sided matches, encompassing both 2v2 Team alliances and Free-For-All (FFA) combat. Update the foundation to handle N-player turn indices, expand custom piece placement, and introduce chaotic party modes.

## Tasks (Future Issues)

### 1. 4-Player Engine Refactoring
- Refactor the core `GameState` and turn logic in `packages/engine` to handle 3-4 players cleanly (relying on the flexible N-player models established in M02).
- Implement a cyclical turn index manager.
- Update check detection to correctly evaluate threats from multiple opponents simultaneously.

### 2. Multi-Sided Board Configurations
- Create new initial board setups (FEN equivalents) designed for 3-player and 4-player games.
- Extend the board coordinate system if necessary (e.g., adding additional starting ranks for extra players).
- Define "Team" vs "FFA" rulesets (e.g., order of play, who chooses starting locations, no friendly-fire in team mode).

### 3. Player Elimination & "Zombie" States
- In modes with more than 2 players, disable traditional checkmate/stalemate. Players are notified of checks, but elimination only occurs when the King is physically captured.
- Implement logic for what happens when a player is eliminated: Their pieces become inert, capturable obstacles on the board.

### 4. 4-Player UI Scaling
- Update the Flutter UI to gracefully handle and display 4 distinct player areas (timers, captured pieces, avatars).
- Ensure the board rotation makes sense for all local players (if playing hot-seat on a tablet) or appropriately locks perspective for online play.
- Add distinct color palettes for the 3rd and 4th players (e.g., Red and Blue -TBD- alongside Black and White).

### 6. Expanded Multiplayer Networking
- Update Appwrite database schemas and Edge Functions to handle more than two players per Game document.
- Ensure the matchmaking system can populate 4-player lobbies correctly.
