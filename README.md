# Chess Tournament Management System

A full-stack Chess Tournament Management System built with **Flutter** (frontend) and **Node.js/Express** with **PostgreSQL** (backend).

## Features

- **Player Management** - Create, read, update, and delete players
- **Tournament Management** - Create, read, update, delete tournaments, and add/remove players
- **Match System** - Random pairing of players, random winner selection, automatic round generation (knockout format)
- **Rankings** - Display final rankings with 1st, 2nd, and 3rd place podium

## Tech Stack

- **Frontend**: Flutter, Dart, Riverpod
- **Backend**: Node.js, Express
- **Database**: PostgreSQL

## Prerequisites

Before running this project, ensure you have installed:

| Tool | Version | Download |
|------|---------|----------|
| **Node.js** | v16 or higher | https://nodejs.org/ |
| **PostgreSQL** | v12 or higher | https://www.postgresql.org/download/ |
| **Flutter SDK** | v3.0 or higher | https://docs.flutter.dev/get-started/install |
| **Git** | Any | https://git-scm.com/ |
| **Chrome** | (for web) | Any modern browser |

### Verify installations

Open a new **PowerShell** or **Command Prompt** and run:

```powershell
node --version
npm --version
flutter --version
psql --version
```

All commands should return version numbers (not errors). If `flutter` is not found after installation, add it to PATH:

```powershell
# Add to current session
$env:Path += ";C:\tools\flutter\bin"

# OR make permanent (run once, then restart terminal)
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\tools\flutter\bin", "User")
```

---

## Project Structure

```
chess_tournament_system/
├── backend/                        # Node.js/Express API server
│   ├── src/
│   │   ├── index.js                # Server entry point (starts Express + DB)
│   │   ├── db.js                   # PostgreSQL connection pool
│   │   ├── schema.sql              # Database schema (auto-runs on start)
│   │   └── routes/
│   │       ├── players.js          # Player CRUD routes
│   │       ├── tournaments.js      # Tournament CRUD routes
│   │       ├── matches.js          # Match generation routes
│   │       └── rankings.js         # Ranking routes
│   ├── package.json
│   ├── .env                        # Environment config (DB credentials)
│   └── .env.example                # Template for .env
├── frontend/
│   └── chess_app/                  # Flutter application
│       ├── lib/
│       │   ├── main.dart           # App entry point
│       │   ├── app.dart            # MaterialApp + routing
│       │   ├── models/             # Data models (Player, Tournament, Match, Ranking)
│       │   ├── providers/          # Riverpod state management
│       │   ├── services/           # API service (HTTP client)
│       │   ├── screens/            # UI screens (Home, Player, Tournament, Match, Ranking)
│       │   └── widgets/            # Reusable UI components
│       ├── pubspec.yaml            # Flutter dependencies
│       ├── test/                   # Unit tests
│       └── build/                  # Build output (generated)
└── README.md
```

---

## Step-by-Step Setup Guide

### Step 1: Set Up the Database (PostgreSQL)

#### Option A: Using pgAdmin (GUI)

1. Open **pgAdmin**
2. Right-click **Servers** → **Create** → **Server** (or use existing)
3. Right-click **Databases** → **Create** → **Database**
4. Name: `chess_tournament`
5. Click **Save**

#### Option B: Using Command Line

Open PowerShell as Administrator and run:

```powershell
# Connect to PostgreSQL and create the database
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE chess_tournament;"
```

**Note:** Replace version `16` with your PostgreSQL version (e.g., `15`, `14`).

---

### Step 2: Configure and Start the Backend

#### 2.1 Navigate to backend

```powershell
cd chess_tournament_system\backend
```

#### 2.2 Install dependencies

```powershell
npm install
```

#### 2.3 Configure environment variables

Open the file `backend\.env` and update it with your PostgreSQL credentials:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=chess_tournament
DB_USER=postgres
DB_PASSWORD=your_actual_password    # ← CHANGE THIS to your PostgreSQL password
PORT=3000
```

> **Common PostgreSQL password issues:**
> - Default password on Windows is often set during installation
> - If you forgot the password, reset it via pgAdmin or run: `ALTER USER postgres WITH PASSWORD 'newpassword';`

#### 2.4 Start the backend server

```powershell
npm start
```

**Expected output:**

```
Database schema initialized successfully.
Chess Tournament API running on http://localhost:3000
```

The database tables (`players`, `tournaments`, `tournament_players`, `matches`) are created automatically on first run.

#### 2.5 Verify the backend is running

Open a browser or run:

```powershell
curl http://localhost:3000/api/health
```

**Expected response:**
```json
{"status":"ok"}
```

---

### Step 3: Set Up and Run the Flutter Frontend

#### 3.1 Navigate to the Flutter app

```powershell
cd chess_tournament_system\frontend\chess_app
```

#### 3.2 Install Flutter dependencies

```powershell
flutter pub get
```

**Expected output:**
```
Resolving dependencies...
Downloading packages...
Got dependencies.
```

#### 3.3 Configure the API URL

Open `lib/providers/api_provider.dart` and check the base URL:

```dart
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService('http://localhost:3000/api');
});
```

**Change the URL based on your setup:**

| Platform | URL |
|----------|-----|
| **Chrome (web)** | `http://localhost:3000/api` |
| **Android Emulator** | `http://10.0.2.2:3000/api` |
| **iOS Simulator** | `http://localhost:3000/api` |
| **Physical Device** | `http://<your-computer-ip>:3000/api` |

> To find your computer IP: run `ipconfig` and look for `IPv4 Address`.

#### 3.4 Run the Flutter app

**For Web (Chrome):**
```powershell
flutter run -d chrome
```

**For Windows Desktop:**
```powershell
flutter run -d windows
```

**For Android (connected device or emulator):**
```powershell
flutter run
```

---

## Complete Walkthrough: How to Use the Application

Once both backend and frontend are running, follow these steps to test the full workflow:

### Step 1: Add Players

1. Open the app in Chrome (`http://localhost:3000` or the Flutter web URL)
2. Click the **Players** card on the home screen
3. Click the **+** (FAB) button at bottom-right
4. Fill in:
   - **Name**: e.g., `Alice Johnson`
   - **Email**: e.g., `alice@example.com`
   - **Phone**: optional
5. Click **Save**
6. Repeat to add at least 3-4 players (e.g., Bob, Charlie, Diana)

**Visual output:** A list of all players appears with edit/delete options.

### Step 2: Create a Tournament

1. Go back to Home screen (press back button)
2. Click **Tournaments** card
3. Click the **+** (FAB) button at bottom-right
4. Fill in:
   - **Name**: e.g., `Summer Chess Championship 2026`
   - **Description**: optional
   - **Start Date**: click to open date picker, select a date
   - **End Date**: click to open date picker, select a later date
5. Click **Save**

**Visual output:** The tournament appears in the list with status "UPCOMING" and "0 players".

### Step 3: Add Players to Tournament

1. Click on the tournament name in the list
2. In the **Players** section, click **Add** button
3. A dialog shows available players — click one to add
4. Repeat to add all players to the tournament
5. Each added player appears in the list with a remove button

**Visual output:** Player count updates (e.g., "4 players"). Each player shows with avatar and email.

### Step 4: Generate Match Rounds

1. In the tournament detail screen, click **Generate Match Round** button
2. Wait a moment — the system randomly pairs players and selects winners
3. A snackbar shows: `Round 1 generated!`

**What happens internally:**
- Players are shuffled randomly
- They are paired (Player 1 vs Player 2, Player 3 vs Player 4, etc.)
- A winner is randomly chosen for each match
- Winners advance to the next round
- If odd number of players, one gets a "bye" (automatic win)

4. Click **Generate Match Round** again for subsequent rounds
5. Continue until the tournament status changes to **COMPLETED**

**Visual output:** Status changes to "ONGOING" then "COMPLETED".

### Step 5: View Matches

1. Click **View Matches** button
2. Matches are grouped by round
3. Each match shows:
   - Player names
   - "vs" between them
   - Winner highlighted in **bold green** with a trophy icon
   - "Bye" label for unpaired players

**Visual output:** A list of rounds with match cards showing winners.

### Step 6: View Rankings

1. From tournament detail, click the **leaderboard icon** (top-right) or go back and access Rankings
2. The **Podium** section shows:
   - **1st Place** (gold/amber bar) — tallest bar
   - **2nd Place** (grey bar) — medium bar
   - **3rd Place** (brown bar) — shortest bar
3. Below the podium, **All Rankings** table shows:
   - Rank number
   - Player name
   - Wins count
   - Matches played count
   - Medal chip (1st/2nd/3rd) for top 3

**Visual output:** Podium bars with trophy icons, rankings with medal chips.

---

## API Endpoints

### Players

| Method | Endpoint | Description | Example Request Body |
|--------|----------|-------------|---------------------|
| `GET` | `/api/players` | List all players | — |
| `GET` | `/api/players/:id` | Get player by ID | — |
| `POST` | `/api/players` | Create player | `{"name":"Alice","email":"a@b.com","phone":"123"}` |
| `PUT` | `/api/players/:id` | Update player | `{"name":"Alice","email":"a@b.com"}` |
| `DELETE` | `/api/players/:id` | Delete player | — |

### Tournaments

| Method | Endpoint | Description | Example Request Body |
|--------|----------|-------------|---------------------|
| `GET` | `/api/tournaments` | List all tournaments (with player count) | — |
| `GET` | `/api/tournaments/:id` | Get tournament with player list | — |
| `POST` | `/api/tournaments` | Create tournament | `{"name":"Championship","start_date":"2026-07-10","end_date":"2026-07-13"}` |
| `PUT` | `/api/tournaments/:id` | Update tournament | `{"name":"New Name","status":"ongoing"}` |
| `DELETE` | `/api/tournaments/:id` | Delete tournament | — |
| `POST` | `/api/tournaments/:id/players` | Add player to tournament | `{"player_id":1}` |
| `DELETE` | `/api/tournaments/:id/players/:playerId` | Remove player from tournament | — |

### Matches

| Method | Endpoint | Description | Example Request Body |
|--------|----------|-------------|---------------------|
| `GET` | `/api/matches/tournament/:tournamentId` | Get all matches for a tournament | — |
| `POST` | `/api/matches/generate/:tournamentId` | Generate next round (random pairing + winners) | `{}` |

### Rankings

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/rankings/:tournamentId` | Get rankings (sorted by wins) + podium (1st, 2nd, 3rd) |

### Testing API with curl (PowerShell)

```powershell
# Health check
curl http://localhost:3000/api/health

# List players
curl http://localhost:3000/api/players

# Create a player
curl -Method Post -Uri http://localhost:3000/api/players -Body '{"name":"Test","email":"t@t.com"}' -ContentType "application/json"

# Create a tournament
curl -Method Post -Uri http://localhost:3000/api/tournaments -Body '{"name":"Tourney","start_date":"2026-07-10","end_date":"2026-07-13"}' -ContentType "application/json"

# Generate matches
curl -Method Post -Uri http://localhost:3000/api/matches/generate/1 -Body '{}' -ContentType "application/json"

# Get rankings
curl http://localhost:3000/api/rankings/1
```

---

## How the Match System Works (Knockout Format)

1. **Round 1**: All tournament players are randomly shuffled and paired (2 players per match)
2. **Random Winner**: For each match, a winner is selected randomly (50/50 chance)
3. **Advancement**: Winners proceed to the next round
4. **Bye Handling**: If an odd number of players, one player automatically advances (bye)
5. **Subsequent Rounds**: Previous round winners are re-shuffled and paired again
6. **Completion**: When only one winner remains, the tournament status changes to `completed`

---

## Troubleshooting

### "database 'chess_tournament' does not exist"

**Solution:** Create the database first (see Step 1 above).

### "password authentication failed for user 'postgres'"

**Solution:** Update `DB_PASSWORD` in `backend\.env` with your actual PostgreSQL password.

### Flutter app cannot connect to backend

**Solution:** Check the API base URL in `lib/providers/api_provider.dart`. For Chrome/web, use `http://localhost:3000/api`. For Android emulator, use `http://10.0.2.2:3000/api`.

### "flutter is not recognized"

**Solution:** Add Flutter to your PATH, then restart the terminal:

```powershell
$env:Path += ";C:\tools\flutter\bin"
```

### Port 3000 already in use

**Solution:** Change the PORT in `backend\.env` to another value (e.g., `PORT=3001`) and update the Flutter app's API URL accordingly.

### "relation does not exist" errors

**Solution:** Delete the database tables (or the whole database) and restart the backend — it will recreate the schema automatically:

```powershell
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "DROP DATABASE chess_tournament; CREATE DATABASE chess_tournament;"
```

---

## Deliverables Checklist

| Requirement | Status |
|------------|--------|
| Player CRUD (Create, Read, Update, Delete) | ✅ |
| Tournament CRUD (Create, Read, Update, Delete) | ✅ |
| Add players to tournaments | ✅ |
| Random match pairing system | ✅ |
| Random winner selection | ✅ |
| Match results recorded | ✅ |
| Rankings display (1st, 2nd, 3rd) | ✅ |
| Flutter + Riverpod frontend | ✅ |
| PostgreSQL database | ✅ |
| GitHub repository | ✅ (after push) |

---

## Submission

1. Push the code to a GitHub repository
2. Deploy the backend to a hosting service (optional)
3. Submit the repository URL and/or demo video to: **workkevin d75@gmail.com**
4. Deadline: **13 July 2026, 10:00 AM**
