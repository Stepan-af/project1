

## ABSOLUTE RULES (DO NOT BREAK)

1. Use **Flutter** only.
2. Use **MapLibre** for maps.

   * ❌ Do NOT use Mapbox
   * ❌ Do NOT use Google Maps
3. Routes are **predefined and stored locally**.

   * ❌ No live routing
   * ❌ No routing APIs at runtime
4. Focus sessions:

   * Have **fixed duration**
   * Are based on **timestamps**, not tick counters
5. App must work **without any backend**.
6. Do **NOT** introduce features not described in the spec.
7. Prefer **simple, deterministic solutions** over complex ones.
8. Use **only open-source libraries**.

---

## WORKFLOW (VERY IMPORTANT)

You must work **step by step**.

### Step 1 — Architecture (DO FIRST)

* Propose:

  * app architecture
  * folder / file structure
* Explain responsibilities of each layer.
* **DO NOT write UI code yet.**
* Wait for confirmation before proceeding.

### Step 2 — Data & Storage

* Define data models.
* Define local persistence strategy.
* Provide example JSON for routes.
* **DO NOT write UI code yet.**
* Wait for confirmation.

### Step 3 - Git

## Branching
- main: stable
- develop: active development
- feature/*, fix/*: short-lived branches

## Commits
Use conventional commits:
feat, fix, refactor, docs, chore, style

## Pull Requests
- All changes go through PR into develop
- Direct commits to main are not allowed

## Rules
- Follow the MVP specification strictly
- Do not introduce features outside scope

### Step 4 — Map & Route Rendering

* Implement:

  * MapLibre integration
  * polyline rendering
  * start/end markers
* Explain polyline interpolation logic.

### Step 5 — Session Engine

* Implement:

  * timestamp-based timer
  * pause / resume
  * restoration after app restart
* Explain lifecycle handling.

### Step 6 — Screens

* Implement screens in this order:

  1. Routes List
  2. Route Details
  3. Session
  4. Arrival
  5. Statistics

### Step 7 — Share Feature

* Implement PNG generation.
* System share sheet.

### Step 8 — Cleanup

* Refactor
* Add comments
* Ensure determinism

---

## QUALITY BAR

* Code must be:

  * readable
  * modular
  * production-oriented (MVP level)
* Avoid “magic numbers”.
* Avoid unnecessary abstractions.
* Explain non-trivial logic in comments.

---

## IF YOU ARE UNSURE

* Re-read the specification.
* Choose the **simplest** interpretation.
* Ask for clarification **before implementing**.

---

## OUTPUT FORMAT

* For each step:

  * Explanation first
  * Then code (if applicable)
* Clearly label sections:

  * `Architecture`
  * `Models`
  * `Storage`
  * `Map`
  * `Session Engine`
  * etc.

---

## FINAL NOTE

Do **NOT** try to improve the product or add features.
Your job is **precise execution of the specification**.

---



# LLM-FRIENDLY TECH SPEC

## Journey Focus — MVP (Hybrid, Open-Source Only)

---

## ROLE & CONTEXT (обязательно оставить)



---

## HARD CONSTRAINTS (DO NOT VIOLATE)

* Platform: **Flutter (iOS + Android)**
* Maps: **MapLibre only** (NO Mapbox, NO Google Maps)
* Data source: **predefined routes with polylines**
* Routing:

  * ❌ NO live routing
  * ❌ NO external routing APIs at runtime
* Time:

  * Focus sessions have **fixed duration**
  * Duration is **not related to real ETA**
* Backend:

  * ❌ NO backend
  * ❌ NO auth
* Monetization:

  * ❌ NO subscriptions
  * ❌ NO payments
* Libraries:

  * ❌ NO paid SDKs

---

## CORE IDEA

This app simulates a **journey** (train / car / ferry) as a **focus session**.

User selects a route → starts session → timer runs → marker moves along a polyline → arrival screen.

---

## DATA MODEL (STRICT)

### Route model

```json
{
  "id": "string",
  "title": "string",
  "transport": "train | car | ferry",
  "durationMinutes": number,
  "description": "string",
  "start": { "lat": number, "lon": number },
  "end": { "lat": number, "lon": number },
  "polyline": [
    { "lat": number, "lon": number }
  ]
}
```

Rules:

* `durationMinutes` is **fixed**
* `polyline` is used for:

  * drawing the route
  * animating marker movement

---

### Session model

```json
{
  "id": "string",
  "routeId": "string",
  "startedAt": "timestamp",
  "finishedAt": "timestamp | null",
  "plannedDurationSeconds": number,
  "actualDurationSeconds": number,
  "completed": boolean
}
```

---

## SCREENS (IMPLEMENT IN THIS ORDER)

### 1. Routes List Screen

Must:

* Display list of routes
* Show:

  * title
  * transport icon
  * duration
* Filter by transport (train / car / ferry)
* Search by title

---

### 2. Route Details Screen

Must:

* Show **MapLibre map**
* Draw:

  * route polyline
  * start marker
  * end marker
* Display:

  * title
  * description
  * duration
* Button: **Start Journey**

---

### 3. Session Screen (Core Logic)

Must:

* Start a timer for `durationMinutes`
* Display:

  * remaining time (mm:ss)
  * progress bar (%)
* Animate:

  * marker moves along polyline
  * movement is **linear in time**
* Controls:

  * Pause
  * Resume
  * Finish early (with confirmation)

#### Timer rules (IMPORTANT)

* Timer must be based on **timestamps**, not tick counters
* If app is backgrounded or restarted:

  * session state must restore correctly
  * remaining time must be recalculated

---

### 4. Arrival Screen

Shown when:

* Timer reaches zero
* Or user finishes manually

Must show:

* "You have arrived"
* route title
* actual duration
* current streak

Buttons:

* Share
* Repeat route
* Back to list

---

### 5. Statistics Screen

Must show:

* Today:

  * sessions count
  * total focus time
* Last 7 days:

  * sessions count
  * total focus time
* All time:

  * total sessions
  * total focus time
* Current streak:

  * 1 day = at least 1 completed session that day

---

## POLYLINE ANIMATION LOGIC (IMPORTANT)

Implementation requirements:

* Precompute cumulative distances along polyline
* Progress = `elapsedSeconds / plannedDurationSeconds`
* Find position on polyline by progress
* Marker position updates smoothly

---

## STORAGE

* Local only (SQLite or simple local persistence)
* Persist:

  * sessions
  * active session state
* No cloud sync

---

## SHARE FEATURE

* Generate PNG locally
* Content:

  * route title
  * duration
  * date
  * streak
* Open system share sheet

---

## NON-GOALS (DO NOT IMPLEMENT)

* Offline maps
* Live routing
* Transport schedules
* Accounts / login
* Social / multiplayer
* Push notifications
* Payments

---

## IMPLEMENTATION STEPS (FOLLOW STRICTLY)

1. Project architecture & folder structure
2. Data models & local storage
3. Routes list screen
4. Route details + map + polyline
5. Session engine + timer restore
6. Arrival screen
7. Statistics
8. Share feature
9. Cleanup & refactor

---

## DEFINITION OF DONE

* App runs on iOS and Android
* No backend required
* No paid services used
* Focus session works reliably even after app restart
* Marker animation matches timer progress
* All screens implemented

---

## FINAL NOTE TO LLM

If something is unclear:

* Choose **simpler** implementation
* Prefer **deterministic behavior**
* Avoid overengineering

---
