# Milestone 11: The Grandmaster
**Goal:** Develop a serious, highly competitive AI opponent for veteran players. The engine will run advanced background calculations to provide a true strategic challenge without slowing down the user interface.

## Tasks (Future Issues)

### 1. Isolate Architecture & Profiling
- Profile the pure Dart engine logic (now utilizing the high-performance data structures built in M10) using the Flutter DevTools suite.
- Ensure the complex AI calculations never block the main Flutter thread.
- Implement a robust Isolate architecture (`Isolate.spawn` or `compute`) to offload the `BotService` computation.
- Set up a two-way communication channel between the main thread (UI updates) and the worker thread (AI calculations).

### 2. Advanced Minimax & Alpha-Beta Pruning (Research Phase)
- Implement a standard Minimax algorithm within `packages/engine/lib/src/bot/`.
- Enhance the algorithm with Alpha-Beta pruning to significantly cut down the search tree space.
- Research alternative or additional algorithms (e.g., Monte Carlo Tree Search or neural-net approaches) if the mathematical complexity of the Torus geometry proves too vast for standard Alpha-Beta pruning at higher depths.

### 3. Heuristic Evaluation Function Upgrade
- Replace the basic material counting evaluation with a robust heuristic function.
- Add positional bonuses (e.g., controlling the center, knight placement, pawn structures).
- Add specific "Wormhole" heuristics (e.g., heavily weighting control of squares immediately adjacent to or leading into wormholes).

### 4. Opening Book & Endgame Tablebases
- Implement a basic opening book parser so the AI can play standard openings instantly without calculation.
- Explore generating custom opening principles specifically adapted for wormhole placements.
- Integrate simple endgame tablebases (or hardcoded endgame logic) to prevent the AI from blundering obvious mates.

### 5. AI Difficulty Scaling UI
- Update the Single Player menu to allow users to select bot difficulty (e.g., Level 1 "Beginner" to Level 10 "Grandmaster").
- Map difficulty levels to specific AI constraints (e.g., limiting search depth, adding randomness to evaluation scores, or disabling specific heuristics for lower levels).
