# Milestone 12: The Vault
**Goal:** Fortify the application with an offline-first architecture so players can enjoy the game anywhere. Matches will seamlessly sync to the cloud whenever an internet connection is re-established.

## Tasks (Future Issues)

### 1. Drift Local Database Setup
- Integrate `drift` and `drift_flutter` into `packages/app/pubspec.yaml`.
<!-- TODO: We should consider annotating the same objects for both Appwrite and Drift to avoid code duplication -->
- Define the local database schema (Tables: `LocalGames`, `LocalMoves`, `LocalSettings`).
- Generate the boilerplate Drift classes using `build_runner`.

### 2. Dependency Injection & Repository Layer
- Create a `DatabaseRepository` interface that hides the complexity of choosing between Appwrite (cloud) and Drift (local).
- Implement a Riverpod Provider that automatically injects the correct repository implementation based on current network connectivity.

### 3. Offline-First "Save State" Logic
- Update the single-player game flow so that moves are immediately written to the local Drift database.
- Allow users to close the app mid-game and resume from the exact state upon reopening.
- Implement a "Load Game" UI screen querying the local Drift database.

### 4. Background Sync Service
- Implement a Sync Service that runs periodically when the app is active and an internet connection is detected.
- The service should compare local `LocalGames` timestamps against the Appwrite `Games` collection.
- Push locally created single-player records to the cloud for persistent backup across devices.

### 5. Conflict Resolution Strategy
- Design a basic strategy for handling state conflicts (e.g., if a user plays the same offline game on a tablet and a phone without syncing in between).
- Implement "Last Write Wins" or prompt the user via UI: "Conflicting saves detected. Keep Local or Cloud version?".

### 6. Robust Error Handling & Retry Queues
- Implement an HTTP interceptor or wrapper around the Appwrite SDK calls.
- If a network request fails (e.g., attempting to submit a multiplayer move while driving through a tunnel), add the action to a local "Retry Queue" in Drift.
- Process the queue automatically when connection is restored.
