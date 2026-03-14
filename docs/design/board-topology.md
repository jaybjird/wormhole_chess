# Board Topology Design Document

This document outlines the mathematical, spatial, and visual design of the Wormhole Chess board. It serves as the source of truth for understanding how pieces move across the board and how the engine and UI should represent this complex space.

## 1. The Core Concept: The Einstein-Rosen Bridge
The fundamental mechanic of Wormhole Chess is not instant teleportation between arbitrary squares. Instead, the board represents a literal physical space warped by an Einstein-Rosen bridge (a wormhole). 

Imagine 3D space represented as a 2D sheet of paper. You draw two distant dots on the paper, fold the paper so the dots touch, and pierce a hole through them. That hole is a shortcut connecting two previously distant points.

Our chess board is a literal interpretation of this concept. The "Wormhole" is a physical tunnel through the center of the board that connects two distinct planar surfaces.

## 2. Mathematical Topology: The Partial Torus
From a topological perspective, the board is structured as a **Partial Torus**.

### The Structure
- **Top Plane:** A standard square grid (representing one side of the "universe" or "folded space").
- **Bottom Plane:** A second square grid directly beneath the top plane (representing the other side of the "folded space").
- **The Tunnel (Wormhole):** A cylindrical bridge that connects the center of the Top Plane to the center of the Bottom Plane. It is composed of playable squares (e.g., 2 rings of 12 tiles each) that pieces must physically traverse to get from one plane to the other.

### Key Rules of Movement
1. **No Instant Teleportation:** A piece does not "enter" square A and instantly appear on square B. It must move *into* the tunnel, travel along the tunnel's inner surface, and exit onto the opposite plane.
2. **Directional Continuity:** Movement vectors (cardinal and diagonal) must remain mathematically consistent as they transition from the flat plane into the curved surface of the tunnel.
3. **Corner Geometry:** Because the tunnel intersects the flat planes, certain intersection squares (corners of the wormhole entrance) will have non-standard adjacencies (e.g., a square might touch 5 other squares instead of the standard 4 or 8). The engine must handle these edge cases logically.

## 3. UI Representation: The "Folded Space" MVP
While the board exists conceptually as a 3D Torus, rendering true 3D in the early stages (Web Alpha) introduces unnecessary complexity. We will use a 2D (or 2.5D) representation known as the **"Folded Space" MVP**.

### Visualizing the Folded Space
To visualize the 2D UI, imagine opening a book and laying it completely flat, face down.
- **The Left Cover:** Represents the **Top Plane**.
- **The Right Cover:** Represents the **Bottom Plane**.
- **The Center Hole:** The "spine" of the book is **NOT** a playable surface. Instead, imagine a literal hole cut through the center of both covers, with a visible tunnel bridging the gap.

In the UI:
- The two main playing planes will be rendered side-by-side on the screen.
- They are completely disconnected along their outer edges.
- The **ONLY** way a piece can move from the left plane to the right plane is by entering the central "Wormhole" area, traversing the tunnel squares, and exiting on the other side.
- The UI must clearly delineate the boundary of the planes and the entrance to the tunnel, likely using subtle highlights or custom painter paths to show the topological curvature.

## 4. Engine Architecture Implications
Because the board is non-Euclidean, traditional 2D array coordinates (`[x][y]`) or standard 64-square bitboards will not suffice without heavy modification.

The engine must:
1. Use an algorithmically driven coordinate system that maps standard planar coordinates to the tunnel coordinates.
2. Rely on static look-up tables (generated at board initialization) to define which squares are adjacent to which, preventing the need to calculate complex Torus geometry on the fly during move generation. 
3. Support N-player threat detection across these continuous, curved vectors.
