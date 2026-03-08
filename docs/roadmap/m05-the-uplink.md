# Milestone 5: The Uplink
**Goal:** Connect the game to Appwrite Cloud to enable asynchronous 1v1 multiplayer. Players will be able to challenge friends via shareable links, and their progress will be safely stored in the database.

## Tasks (Future Issues)

### 1. Database Schema & Models Definition
- Use Appwrite authentication to support Email/Password and OAuth (Google, Apple).
- Create Appwrite Database and Collections (`Games`, `Moves`).
- Define Flutter models in `packages/models/lib/src/game.dart` (ID, status, player IDs, current FEN).
- Define Flutter models in `packages/models/lib/src/move.dart` (Game ID, player ID, move notation, timestamp).
- Use `freezed` and `json_serializable` for the data models.

### 2. Anonymous Authentication (Appwrite)
- Implement `AccountService` using `appwrite` SDK.
- Allow users to "Play as Guest" by creating an anonymous session.
<!-- TODO: I am unsure if this is necessary -->
- Store the generated Appwrite session ID locally (using `shared_preferences` or `flutter_secure_storage`).

<!-- TODO: Before connecting a second player, we will first get game persistence working for a single player. Offline saving won't be supported for some time, so 
we will persist games to Appwrite-->
### 3. Create Multiplayer Game UI
- Implement a "Create Game" and "Load Game" button on the home screen.
<!-- TODO: The first pass of the online game flow will be to create a game and
receive a shareable link to send to a friend -->
- Implement a "Waiting for Opponent" lobby screen.
- Upon clicking "Create", generate a new Game document in Appwrite and navigate to the lobby.

### 4. Shareable Link Generation & Deep Linking
- Implement an Appwrite Edge Function (or direct client code) to generate a unique invite link.
- Configure deep linking (`app_links` or `uni_links`) for Flutter Web/Mobile to handle `wormhole.chess/join/GAME_ID`.
- Implement logic: If a user clicks the link and is not authenticated, create an anonymous session, then add them as Player 2 to the Game document.

### 5. Realtime Board State Synchronization
- Implement Appwrite Realtime subscriptions on the `Games` and `Moves` collections.
- Update the Riverpod `GameStateNotifier` when a new move is detected from the remote database.
- Ensure the board visually updates for the non-active player when the active player moves.

### 6. Remote Move Validation & Security Rules
- Implement an Appwrite Edge Function to validate moves on the server-side to prevent cheating (using a lightweight Dart or Node.js runtime).
- Define Appwrite Collection Level Security (Document Security) so only Player 1 or Player 2 can read/write to their specific Game document.
