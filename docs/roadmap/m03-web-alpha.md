# Milestone 3: Web Alpha
**Goal:** Bring the game to life visually by connecting the core engine to a basic user interface. Conclude with a playable prototype deployed to Appwrite Sites for early testing and feedback.

## Tasks (Future Issues)

### 1. Flutter Project Initialization & Dependency Wiring
- Ensure `packages/app/pubspec.yaml` properly references `packages/engine` and `packages/models` via `path:` dependency.
- Setup Riverpod `ProviderScope` in the main Flutter app (`packages/app/lib/main.dart`).
- Initialize Talker for app-wide logging.

### 2. 2D "Book" Board UI (Curved Topology MVP)
- Implement a 2D or 2.5D rendering solution (e.g., a custom painter or stacked grid views) that conceptually represents the torus as an "open book" viewed from the top down.
- In this flat representation, the left and right "pages" represent the top and bottom planes of the board, and the center spine represents the flattened tunnel.
- Ensure this unified flat board is responsive across different screen sizes.

### 3. UI Testing Suite (TDD)
- Establish a Flutter Widget Testing suite in `packages/app/test/` to automate UI validation.
- Implement tests verifying that the custom board representation correctly renders the expected number of squares and planes based on the Engine state.
- Ensure widget tests are integrated into the GitHub Actions CI pipeline alongside the engine unit tests.

### 4. Basic Piece Assets & Rendering
- Integrate open-source vector piece assets (e.g., SVG or PNG).
- Render pieces dynamically based on the current engine state, attaching them to the correct planar or tunnel coordinates.
- Create a Provider to listen to the `GameState` from the core engine.

### 5. Interactive Move Handling & Selection UI
- Implement tap-to-select, tap-to-move and drag-and-drop functionality for pieces.
- Highlight legal destination squares when a piece is selected.
- Add visual indicators for "last move" and "check".
- Connect UI actions (drags/taps) back to the engine's `makeMove` function.

### 6. Appwrite Project Setup & Basic Hosting Config
- Create the Appwrite project on the Appwrite Cloud console.
- Configure custom domains or default Appwrite Sites URLs.
- Setup Appwrite MCP for streamlined infrastructure management.
- Setup the Appwrite Flutter SDK in `packages/app/pubspec.yaml`.
- Update `docs/setup.md` with Appwrite MCP and project initialization instructions.

### 7. Appwrite Sites Deployment & SRE Setup
- Integrate `sentry_flutter` for early crash reporting on the web client.
- Configure a GitHub Action (`.github/workflows/deploy-web.yml`) to run tests, build the Flutter web app (`flutter build web`), and automatically generate sourcemaps for Sentry.
- Add the Appwrite CLI step to deploy the `build/web` directory to Appwrite Hosting upon push/merge to the `main` branch.

