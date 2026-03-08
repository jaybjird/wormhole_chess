# Milestone 9: The Arena
**Goal:** Expand the multiplayer experience to the public by introducing community features. Players will be able to create usernames, maintain friend lists, and automatically match with opponents of similar skill levels.

## Tasks (Future Issues)

### 1. Robust Authentication & User Profiles
- Implement profile creation flow during onboarding (prompting to upgrade from Guest account or link email/OAuth providers).
- Create a `Users` collection in Appwrite database to store profiles (username, avatar URL, created date).

### 2. Player Rating System (Elo/Glicko)
- Implement a rating calculation algorithm (e.g., Elo or Glicko-2) on the server (Appwrite Edge Function).
- Update both players' ratings in the database at the conclusion of a ranked match.
- Display player ratings prominently in the UI.

### 3. Automated Matchmaking (Queue System)
- Create a server-side queuing system (likely via Appwrite Edge Functions or a dedicated matching service).
- Implement a UI for "Find Ranked Match".
- The system should pair players currently in the queue who have similar ratings and create a new Game document for them.

### 4. Friends List & Presence System
- Create a `Friends` or `Relationships` collection in Appwrite to handle friend requests (Pending, Accepted).
- Implement UI to search for users by username and send friend requests.
- Implement a basic "Presence" system to show if a friend is currently Online, Offline, or In-Game.

### 5. Chat System (In-Game & Lobby)
- Add a `Messages` collection to Appwrite linked to specific Game IDs.
- Implement an in-game chat window using Appwrite Realtime subscriptions.
- Include basic filtering/muting functionality and a library of quick-chat emotes.

### 6. Leaderboards & Statistics
- Create a global leaderboard UI querying the top players by rating from the `Users` collection.
- Implement a personal statistics page showing win/loss ratio, total games played, and favorite piece.
