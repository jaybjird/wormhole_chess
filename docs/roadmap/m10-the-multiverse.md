# Milestone 10: The Multiverse
**Goal:** Scale the game engine to support multi-sided matches, encompassing both 2v2 Team alliances and Free-For-All (FFA) combat. Update the foundation to handle N-player turn indices, expand custom piece placement, and introduce chaotic party modes.

## Tasks (Future Issues)

### 1. 4-Player Engine Refactoring & Performance Pass
- Refactor the core `GameState` and turn logic in `packages/engine` to handle 3-4 players cleanly (relying on the flexible N-player models established in M02).
- Execute a performance refactor of the underlying board data structures (e.g., migrating from OOP arrays to bitboards or static look-up tables) to handle the drastically increased branching factor of 4-player Torus geometry. Ensure the M02 TDD harness passes completely.
- Implement a cyclical turn index manager.
- Update check detection to correctly evaluate threats from multiple opponents simultaneously using the optimized data structures.

### 2. Multi-Sided Board Configurations
- Create new initial board setups (FEN equivalents) designed for 3-player and 4-player games.
- Extend the board coordinate system if necessary (e.g., adding additional starting ranks for extra players).
- Define "Team" vs "FFA" rulesets (e.g., order of play, who chooses starting locations, no friendly-fire in team mode).

### 3. Player Elimination & Game End States
- In modes with more than 2 players, disable traditional checkmate/stalemate. Players are notified of checks, but elimination only occurs when the King is physically captured.
- Implement logic for what happens when a player is eliminated: Their pieces become inert, capturable obstacles on the board.
- Define the Game End State: The match concludes when all enemy players (or enemy teams) are eliminated. The surviving player/team is declared the winner.
- Research and document potential "anti-turtling" mechanics designed to prevent indefinite stalemates in 3+ player FFA variants.

### 4. 4-Player UI Scaling
- Update the Flutter UI to gracefully handle and display 4 distinct player areas (timers, captured pieces, avatars).
- Ensure the board rotation makes sense for all local players (if playing hot-seat on a tablet) or appropriately locks perspective for online play.
- Add distinct color palettes for the 3rd and 4th players (e.g., Red and Blue -TBD- alongside Black and White).

### 6. Expanded Multiplayer Networking
- Update Appwrite database schemas and Edge Functions to handle more than two players per Game document.
- Ensure the matchmaking system can populate 4-player lobbies correctly.
