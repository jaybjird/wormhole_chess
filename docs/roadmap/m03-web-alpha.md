# Milestone 3: Web Alpha
**Goal:** Bring the game to life visually by connecting the core engine to a basic user interface. Conclude with a playable prototype deployed to Appwrite Sites for early testing and feedback.

## Tasks (Future Issues)

### 1. Flutter Project Initialization & Dependency Wiring
- Ensure `packages/app/pubspec.yaml` properly references `packages/engine` and `packages/models` via `path:` dependency.
- Setup BLoC (`flutter_bloc`) and GetIt (`get_it`) for state management and dependency injection in the main Flutter app (`packages/app/lib/main.dart`).
- Initialize Talker for app-wide logging.

### 2. 2D "Folded Space" Board UI (Curved Topology MVP)
- Implement a 2D or 2.5D rendering solution (e.g., a custom painter or stacked grid views) that conceptually represents the torus as a folded sheet of space with a tunnel pierced through the center.
- In this flat representation, the two main playing planes will be rendered side-by-side (like the open covers of a book), but they are *only* connected through the central "Wormhole" tunnel (e.g., a central ring or designated transfer zone), not along the edges or a "spine".
- Ensure this unified flat board clearly delineates the two planes and the connective tunnel, while remaining responsive across different screen sizes.

### 3. UI Testing Suite (Live & Integration)
- Establish a robust testing framework allowing for both automated integration tests and live visual validation.
- Create dummy Appwrite client configurations that can be shared between the test framework and the local Flutter code to simulate network states and specific player setups.
- Ensure the testing environment allows for rapid TDD of the board UI logic.

### 4. Basic Piece Assets & State Management Scaffolding
- Integrate open-source vector piece assets (e.g., SVG or PNG).
- Setup the architectural scaffolding for state-driven animations and optimistic UI early on. 
- Create a clear separation using BLoC between the "Local UI State" (which drives immediate visual changes like tap-to-move animations) and the "Engine Truth State" (the validated board state). This ensures that future network rollbacks won't cause jarring UI flickering.
- Render pieces dynamically based on the current UI state, attaching them to the correct planar or tunnel coordinates.

### 5. Interactive Move Handling (Tap-to-Move)
- Implement tap-to-select and tap-to-move functionality for pieces (avoid drag-and-drop to bypass complexity over the disjointed torus representation).
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

