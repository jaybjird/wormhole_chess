# Milestone 3: Web Alpha
**Goal:** Bring the game to life visually by connecting the core engine to a basic user interface. Conclude with a playable prototype deployed to Appwrite Sites for early testing and feedback.

## Tasks (Future Issues)

### 1. Flutter Project Initialization & Dependency Wiring
- Ensure `packages/app/pubspec.yaml` properly references `packages/engine` and `packages/models` via `path:` dependency.
- Setup Riverpod `ProviderScope` in the main Flutter app (`packages/app/lib/main.dart`).
- Initialize Talker for app-wide logging.

### 2. Basic Board UI (Grid & Coordinates)
<!-- TODO: Review the example images. We're going to need a more complex solution
for representing the curved space on the board.-->
- Implement a static 8x8 chessboard UI component (`lib/src/features/board/presentation/board_view.dart`).
- Ensure the board is responsive across different screen sizes.

### 3. Basic Piece Assets & Rendering
- Integrate open-source vector piece assets (e.g., SVG or PNG).
- Render pieces dynamically based on the current engine state.
- Create a Provider to listen to the `GameState` from the core engine.

### 4. Interactive Move Handling & Selection UI
- Implement tap-to-select, tap-to-move and drag-and-drop functionality for pieces.
- Highlight legal destination squares when a piece is selected.
- Add visual indicators for "last move" and "check".
- Connect UI actions (drags/taps) back to the engine's `makeMove` function.

### 5. Appwrite Project Setup & Basic Hosting Config
- Create the Appwrite project on the Appwrite Cloud console.
- Configure custom domains or default Appwrite Sites URLs.
- Setup Appwrite MCP
- Setup the Appwrite Flutter SDK in `packages/app/pubspec.yaml`.
- Update setup.md

### 6. Appwrite Sites Deployment (Web Alpha)
- Configure a GitHub Action (`.github/workflows/deploy-web.yml`) to build the Flutter web app (`flutter build web`).
- Add the Appwrite CLI step to deploy the `build/web` directory to Appwrite Hosting upon push/merge to the `main` branch.
