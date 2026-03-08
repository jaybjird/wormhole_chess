# Milestone 11: The Grandmaster
**Goal:** Develop a serious, highly competitive AI opponent for veteran players. The engine will run advanced background calculations to provide a true strategic challenge without slowing down the user interface.

## Tasks (Future Issues)

### 1. Engine Performance Optimization
- Profile the pure Dart engine logic using the Flutter DevTools suite.
- Optimize the move generation loop (consider using bitboards internally if performance dictates, though coordinate representations might be needed for the complex wormhole topology).
- Ensure all basic rules and mechanics execute in near-constant time.

### 2. Advanced Minimax & Alpha-Beta Pruning
- Implement a standard Minimax algorithm within `packages/engine/lib/src/bot/`.
- Enhance the algorithm with Alpha-Beta pruning to significantly cut down the search tree space.
- Implement Iterative Deepening to allow the bot to search deeper based on available time rather than a fixed depth.

### 3. Heuristic Evaluation Function Upgrade
- Replace the basic material counting evaluation with a robust heuristic function.
- Add positional bonuses (e.g., controlling the center, knight placement, pawn structures).
- Add specific "Wormhole" heuristics (e.g., heavily weighting control of squares immediately adjacent to or leading into wormholes).

### 4. Background Isolate Architecture
- Ensure the complex AI calculations never block the main Flutter thread.
- Implement a robust Isolate architecture (`Isolate.spawn` or `compute`) to offload the `BotService` computation.
- Set up a two-way communication channel between the main thread (UI updates) and the worker thread (AI calculations).

### 5. Opening Book & Endgame Tablebases
- Implement a basic opening book parser so the AI can play standard openings instantly without calculation.
- Explore generating custom opening principles specifically adapted for wormhole placements.
- Integrate simple endgame tablebases (or hardcoded endgame logic) to prevent the AI from blundering obvious mates.

### 6. AI Difficulty Scaling UI
- Update the Single Player menu to allow users to select bot difficulty (e.g., Level 1 "Beginner" to Level 10 "Grandmaster").
- Map difficulty levels to specific AI constraints (e.g., limiting search depth, adding randomness to evaluation scores, or disabling specific heuristics for lower levels).
