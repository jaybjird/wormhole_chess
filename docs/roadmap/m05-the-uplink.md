# Milestone 5: The Uplink
**Goal:** Connect the game to Appwrite Cloud to enable asynchronous 1v1 multiplayer. Players will be able to challenge friends via shareable links, and their progress will be safely stored in the database.

## Tasks (Future Issues)

### 1. Database Schema & Models Definition
- Create Appwrite Database and Collections (`Games`, `Moves`).
- Integrate `drift` and `drift_flutter` into `packages/app/pubspec.yaml` to establish a local-first repository pattern from the start.
- Define shared Flutter models in `packages/models/lib/src/game.dart` and `move.dart`. Ensure the `Game` schema uses a dynamic array/list for `playerIds` rather than hardcoded `player1Id` / `player2Id` to prevent painful database migrations in Milestone 10.
- Ensure these models are annotated for both Appwrite (`json_serializable`) and Drift to minimize code duplication.
- Create a `DatabaseRepository` interface that treats Drift as the primary read source and Appwrite purely as a sync engine.

### 2. Single Player Cloud Persistence & Authentication
- Implement Appwrite authentication requiring Email/Password or OAuth (Google, Apple). Do not use anonymous guest sessions to avoid database bloat.
- Update the single-player mode so that the current game state and move history are written locally to Drift first, then continuously synced to an Appwrite Game document.
- Ensure the user can reload the web page and resume their single-player game from the local/cloud cache.

### 3. Asynchronous Multiplayer Game Creation
- Implement a "Create Multiplayer Game" button on the home screen.
- Upon clicking "Create", generate a new Game document in Appwrite and sync it to the local Drift database.
- The UI should immediately transition to the active game board (waiting for player 2), bypassing a complex lobby screen for now.

### 4. Shareable Link Generation & Joining
- Implement logic to generate a unique invite link for the active game.
- Configure web routing (e.g., `go_router`) to handle `wormhole.chess/join/GAME_ID`.
- Implement logic: If a user clicks the link, prompt them to log in (if necessary), then add them as Player 2 to the existing Game document.

### 5. Realtime Board State Synchronization (Optimistic UI)
- Implement Appwrite Realtime subscriptions on the `Games` and `Moves` collections, updating the local Drift repository.
- Update the UI BLoC (`GameStateBloc`) to react to Drift database changes via GetIt repository injection.
- Implement Optimistic UI updates for local moves: the UI should immediately reflect the move, with logic to rollback state if the server sync fails.
