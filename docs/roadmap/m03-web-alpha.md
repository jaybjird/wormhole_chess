# Milestone 3: Web Alpha
**Goal:** Bring the game to life visually by connecting the core engine to a basic user interface. Conclude with a playable prototype deployed to Appwrite Sites for early testing and feedback.

## Tasks (Future Issues)

### 1. Flutter Project Initialization & Dependency Wiring
- Ensure `packages/app/pubspec.yaml` properly references `packages/engine` and `packages/models` via `path:` dependency.
- Setup Riverpod `ProviderScope` in the main Flutter app (`packages/app/lib/main.dart`).
- Initialize Talker for app-wide logging.

### 2. 3D Board UI (Curved Topology)
<!-- TODO: The current plan is to render the board in 2D, or 2.5D, possibly using
a custom painter, though additional research may be needed. For the first pass of
the UI, imagine the board as a book, with the top and bottom planes being the
two covers, and the tunnel being a hole in the center. If you were to open the
book, lay it flat pages down, and do a top down view of the cover, that is our
MVP representation of the board. -->
- Research and implement a 3D rendering solution (e.g., using `flame` or a custom painter) to accurately represent the curved space and the central tunnel of the wormhole board.
- Implement camera controls (pan, zoom, rotate) to allow users to inspect both planes and the tunnel.
- Ensure the 3D board remains performant on both web and mobile platforms.

<!-- TODO: Build out a testing suite for the UI to automate testing, make
manual validation easier, and allow for test driven development. Possibly using
widget tests. -->

### 3. Basic Piece Assets & Rendering
- Integrate open-source vector piece assets (e.g., SVG or PNG).
- Render pieces dynamically based on the current engine state, attaching them to the correct planar or tunnel coordinates.
- Create a Provider to listen to the `GameState` from the core engine.

### 4. Interactive Move Handling & Selection UI
- Implement tap-to-select, tap-to-move and drag-and-drop functionality for pieces.
- Highlight legal destination squares when a piece is selected.
- Add visual indicators for "last move" and "check".
- Connect UI actions (drags/taps) back to the engine's `makeMove` function.

### 5. Appwrite Project Setup & Basic Hosting Config
- Create the Appwrite project on the Appwrite Cloud console.
- Configure custom domains or default Appwrite Sites URLs.
- Setup Appwrite MCP for streamlined infrastructure management.
- Setup the Appwrite Flutter SDK in `packages/app/pubspec.yaml`.
- Update `docs/setup.md` with Appwrite MCP and project initialization instructions.

### 6. Appwrite Sites Deployment & SRE Setup
- Integrate `sentry_flutter` for early crash reporting on the web client.
- Configure a GitHub Action (`.github/workflows/deploy-web.yml`) to run tests, build the Flutter web app (`flutter build web`), and automatically generate sourcemaps for Sentry.
- Add the Appwrite CLI step to deploy the `build/web` directory to Appwrite Hosting upon push/merge to the `main` branch.

