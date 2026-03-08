# Milestone 5: The Uplink
**Goal:** Connect the game to Appwrite Cloud to enable asynchronous 1v1 multiplayer. Players will be able to challenge friends via shareable links, and their progress will be safely stored in the database.

## Tasks (Future Issues)

### 1. Database Schema & Models Definition
- Create Appwrite Database and Collections (`Games`, `Moves`).
- Define Flutter models in `packages/models/lib/src/game.dart` (ID, status, player IDs, current state).
- Define Flutter models in `packages/models/lib/src/move.dart` (Game ID, player ID, move notation, timestamp).
- Use `freezed` and `json_serializable` for the data models.

### 2. Single Player Cloud Persistence
- Use Appwrite authentication to support Email/Password and OAuth (Google, Apple).
- Update the single-player mode so that the current game state and move history are continuously synced to an Appwrite Game document.
- Ensure the user can reload the web page and resume their single-player game from the cloud.

### 3. Asynchronous Multiplayer Game Creation
- Implement a "Create Multiplayer Game" button on the home screen.
<!-- TODO: We won't be implementing a lobby until the arena milestone -->
- Implement a "Waiting for Opponent" lobby screen.
- Upon clicking "Create", generate a new Game document in Appwrite and navigate to the lobby.

### 4. Shareable Link Generation & Joining
- Implement an Appwrite Edge Function (or direct client code) to generate a unique invite link.
- Implement basic Appwrite anonymous authentication for guests (or bypass if using a generic public bucket for early testing, though anonymous sessions are safer).
- Configure web routing (e.g., `go_router`) to handle `wormhole.chess/join/GAME_ID`.
- Implement logic: If a user clicks the link, add them as Player 2 to the existing Game document.

### 5. Realtime Board State Synchronization
- Implement Appwrite Realtime subscriptions on the `Games` and `Moves` collections.
- Update the Riverpod `GameStateNotifier` when a new move is detected from the remote database.
- Ensure the board visually updates for the non-active player when the active player moves.

### 6. Remote Move Validation & Security Rules
- Implement an Appwrite Edge Function to validate moves on the server-side to prevent cheating (using a lightweight Dart or Node.js runtime).
- Define Appwrite Collection Level Security (Document Security) so only Player 1 or Player 2 can read/write to their specific Game document.
