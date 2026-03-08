# Milestone 8: The Mentor
**Goal:** Build an intelligent onboarding system that teaches the non-Euclidean mechanics dynamically as players interact with the board. The game will detect confusion or illegal moves and provide helpful, contextual tooltips.

## Tasks (Future Issues)

### 1. Interactive Tooltip Engine
- Design and implement a reusable `TooltipOverlay` widget in Flutter.
- Allow tooltips to be anchored to specific board squares, UI buttons, or the center of the screen.
- Implement an `OnboardingService` to track which tooltips the user has seen and dismissed (persisted locally).

### 2. Contextual Rule Reminders
- Implement a system that listens to the `Engine` for failed move attempts (e.g., trying to move a Bishop like a Rook).
- Trigger a specific, short tooltip explaining *why* the move was invalid based on the piece type.
- Ensure these reminders only appear for a limited number of times before staying silent to avoid annoyance.

### 3. Topological Contextual Guidance
- Provide subtle UI highlights indicating movement paths across the board's complex topology when a piece is selected.
- If a user attempts an invalid move (e.g., trying to move linearly across a corner where the topology curves), show a tooltip explaining the directional rules of the torus.

### 4. Interactive Tutorial Scenarios
- Implement interactive, single-move puzzles focusing on the non-Euclidean mechanics (e.g., "Find the mate in 1 across the tunnel").
- Build an overlay system that restricts interaction until the specific tutorial move is successfully executed.
- Create a sequence covering spatial orientation, diagonal transitions into the tunnel, and edge cases.

### 5. First-Time User Experience (FTUE) Flow
- Create a streamlined flow for a brand-new app installation.
- Present a choice: "I know how to play Chess" vs. "I am a beginner".
- If they know chess, jump straight to a "Wormhole Mechanics" interactive tutorial.
- If they are a beginner, offer the full suite of basic movement tutorials first.

### 6. Analytics for Onboarding
- Integrate simple analytics (via Appwrite or a dedicated service) to track where users drop off during the FTUE.
- Track metrics like "Time spent on tutorial X" or "Number of invalid move attempts before success".
