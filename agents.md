# AGENTS.md

## Mission
Build a modular, data-driven 2D roguelike in Godot 4.x using typed GDScript.
Preserve clean scene boundaries, readable gameplay code, deterministic validation, and strong separation between gameplay logic, content definitions, UI, and persistence.

## How to work
You are an implementation agent for this repository.
Your job is to complete scoped engineering tasks cleanly, with the smallest safe diff that satisfies the acceptance criteria.
Do not improvise major architecture changes unless the task explicitly requires them.

## Non-negotiable rules
1. Do not make unrelated changes.
2. Do not rename files, scenes, nodes, signals, or public methods unless required by the task.
3. Prefer typed GDScript.
4. Prefer composition over inheritance unless inheritance is already the established pattern.
5. Put gameplay content in Resources when possible.
6. Keep scenes small, focused, and reusable.
7. Do not hardcode content that should be data-driven.
8. Do not add dependencies unless the task explicitly requires them or the existing validation strategy depends on them.
9. End every task by running the repository validation commands.
10. If validation fails, fix the issue before ending the task.
11. When changing behavior, add or update tests if practical.
12. When changing system behavior, update the corresponding docs.

## Primary architecture goals
- Modular Godot 4.x project structure
- Typed GDScript for gameplay systems
- Data-driven definitions for content
- Small public APIs between systems
- Event-driven coordination where appropriate
- Save-safe and testable logic
- Minimal coupling between UI and gameplay

## Repository boundaries
Use these directory responsibilities.

- `game/autoload/`
  - global services only
  - examples: `GameState`, `EventBus`, `SaveManager`, `RunManager`

- `game/core/`
  - shared utilities, interfaces, services, constants

- `game/actors/`
  - player, enemies, projectiles, summons, pickups

- `game/combat/`
  - damage, status effects, abilities, hit handling, combat services

- `game/progression/`
  - upgrades, relics, unlocks, economy, meta systems

- `game/run/`
  - encounter flow, rewards, map progression, wave or room directors

- `game/ui/`
  - menus, HUD, screens, widgets, controllers for display logic

- `game/data/`
  - Resources, definitions, tables, serialized content assets

- `game/scenes/`
  - high-level scene entry points and composed scene shells

- `game/tools/`
  - editor tools, generators, importers

- `tests/`
  - unit and integration tests

- `docs/`
  - architecture docs, system docs, task docs, QA docs

## Coding standards
- Use explicit types for variables, parameters, and return values where practical.
- Keep functions short and responsibility-focused.
- Prefer pure utility or service logic for rules that should be testable without scene runtime.
- Avoid deep hardcoded node-path access where a stable reference, exported NodePath, or scene-local unique name is better.
- Prefer signals and events over tight cross-scene references.
- Avoid global state unless it belongs in an intentional autoload.
- Avoid embedding save schema details inside unrelated gameplay classes.
- Avoid mixing combat logic with UI logic.
- Avoid mixing editor-only tooling into runtime scripts.

## Scene rules
- One clear root node per scene.
- One script should own the scene's public behavior.
- Child nodes should be accessed through stable typed references.
- Scenes should expose a small public API.
- Variation should come from data definitions or reusable components, not scene duplication.

## Data-driven rules
Use Resources or equivalent structured definitions for content-like objects.
Examples include:
- enemy definitions
- attack patterns
- upgrades
- relics
- encounter templates
- rewards
- biome modifiers
- status effect definitions

Do not hardcode content inside UI scenes or one-off managers if it should scale later.

## Autoload rules
Allowed autoload responsibilities:
- profile and run state ownership
- event dispatching
- save/load orchestration
- top-level run lifecycle orchestration
- optional shared audio orchestration if justified

Avoid:
- god objects
- combat math in autoloads
- autoloads directly manipulating scene internals when events or narrow APIs would be cleaner

## Task workflow
For every task, do the following in order:
1. Read `AGENTS.md`.
2. Read the relevant docs in `docs/` before editing.
3. Restate the acceptance criteria internally and scope the minimum required diff.
4. Inspect the current implementation before changing files.
5. Implement only what is required.
6. Add or update tests when behavior changes or when the task requests it.
7. Run validation.
8. Update docs if architecture, system behavior, or public interfaces changed.
9. Return a concise implementation summary.

## Required completion output
At the end of each task, provide:
- summary of what changed
- files changed
- validation performed
- tests added or updated
- docs updated
- remaining risks or follow-up items

## Validation policy
Always prefer repository wrapper scripts if they exist.
Typical commands may include:
- `scripts/validate.sh`
- `scripts/validate.ps1`
- test runner commands defined by the repo

Do not claim validation was run unless it was actually run.
If a command fails because the environment lacks a dependency or binary, state that clearly.

## Change control
Before making large refactors, ask whether the task actually requires one.
If not, do the smaller change.
If an existing pattern is imperfect but consistent, follow the repo's current pattern unless the task explicitly asks for a structural improvement.

## Anti-patterns to avoid
- giant all-in-one manager classes
- duplicated enemy scenes for minor stat or behavior changes
- upgrade logic hardcoded in UI buttons
- brittle node-path spaghetti
- silent changes to public interfaces
- unrelated cleanup mixed into feature work
- scene-specific hacks inside shared systems
- save logic scattered across many runtime classes
- placeholder TODOs where working logic is required

## Preferred implementation style
- small composable scripts and scenes
- Resources for content definitions
- event-driven coordination where appropriate
- deterministic helpers for testable game rules
- narrow interfaces between systems
- minimal, reviewable diffs

## Final priority order
1. Correctness
2. Acceptance criteria
3. Small safe diff
4. Clean architecture
5. Tests and validation
6. Documentation accuracy
