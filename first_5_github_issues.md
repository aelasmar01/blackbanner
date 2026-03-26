# First 5 GitHub Issues

These issues are written so an AI coding agent can execute them cleanly inside a Godot 4.x roguelike repository.
Each issue is intentionally scoped, implementation-oriented, and designed to preserve modular architecture.

---

# Issue 1: Bootstrap foundation and startup flow

## Goal
Create the initial bootstrap flow for the project with the core autoload services and a startup scene that initializes the application, ensures a profile state exists, and transitions into the main menu.

## Why this matters
This establishes the minimum project backbone all later systems will depend on.
Without a clean startup flow, future work on saves, run state, menus, and gameplay transitions becomes brittle and inconsistent.

## Scope
- create the initial directory structure needed for startup and service orchestration
- create the following autoload scripts:
  - `GameState`
  - `EventBus`
  - `SaveManager`
  - `RunManager`
- create a bootstrap startup scene under `game/scenes/bootstrap/`
- initialize a default profile state if no save exists yet
- transition from bootstrap into a placeholder main menu scene
- ensure autoload responsibilities stay minimal and well-defined
- add or update docs describing startup flow and autoload ownership

## Required files
- `project.godot`
- `game/autoload/game_state.gd`
- `game/autoload/event_bus.gd`
- `game/autoload/save_manager.gd`
- `game/autoload/run_manager.gd`
- `game/scenes/bootstrap/bootstrap.tscn`
- `game/scenes/bootstrap/bootstrap.gd`
- `game/scenes/menu/main_menu.tscn`
- `game/scenes/menu/main_menu.gd`
- `docs/architecture/scene-boundaries.md`
- `docs/architecture/gameplay-loop.md`

## Acceptance criteria
- project starts through a bootstrap scene
- bootstrap initializes required autoload flow cleanly
- a default profile state is created when no save data exists
- project transitions into a placeholder main menu scene without errors
- autoloads expose narrow responsibilities rather than becoming god objects
- documentation explains startup flow and autoload ownership clearly
- validation runs successfully

## Constraints
- do not add gameplay systems beyond what is needed for startup flow
- do not put combat, UI-specific business logic, or save schema details into unrelated autoloads
- preserve modular scene architecture
- prefer typed GDScript
- keep diff scoped to startup flow only

## Validation
- run repository validation script
- confirm project boots to main menu without runtime errors

## Deliverable summary
Return:
- files changed
- what was implemented
- validation results
- remaining risks or follow-up items

---

# Issue 2: Create versioned profile and run state schema

## Goal
Create serializable, versioned profile state and run state models with save and load helpers that can be extended safely as the project evolves.

## Why this matters
A roguelike depends on reliable persistence for profile progression, unlocks, current-run recovery, and future schema evolution.
A weak save model early on causes painful rewrites later.

## Scope
- define typed structures or classes for profile state
- define typed structures or classes for run state
- add schema version fields and migration-ready save structure
- implement serialization and deserialization helpers
- integrate save/load helpers with `SaveManager`
- ensure new default state can be created deterministically
- document the save schema and versioning strategy
- add tests for save serialization roundtrip where practical

## Required files
- `game/autoload/save_manager.gd`
- `game/core/services/` or `game/core/utils/` for serialization helpers
- `game/core/interfaces/` or equivalent location for state models
- `docs/architecture/save-data-schema.md`
- `tests/unit/`

## Acceptance criteria
- profile state can be created, serialized, saved, loaded, and restored
- run state can be created, serialized, saved, loaded, and restored
- schema version is stored with persisted data
- save structure is designed to support future migrations
- invalid or missing save data fails safely and predictably
- tests cover at least one successful serialization roundtrip and one invalid-data case if practical
- documentation explains fields, ownership, and migration approach
- validation runs successfully

## Constraints
- do not over-engineer migration logic before it is needed
- do not scatter save schema ownership across unrelated gameplay classes
- keep state models readable and typed
- keep runtime scene dependencies out of save model code

## Validation
- run repository validation script
- run relevant tests for serialization and load behavior

## Deliverable summary
Return:
- files changed
- what was implemented
- validation results
- remaining risks or follow-up items

---

# Issue 3: Build player combat shell

## Goal
Create a reusable player actor scene with movement, a primary attack shell, health management, damage intake, and death signal flow.

## Why this matters
This is the minimum playable actor foundation required before enemy interactions, encounters, rewards, and run pacing can be built meaningfully.
It also establishes the coding pattern for future actors.

## Scope
- create a player scene and player script under `game/actors/player/`
- implement movement logic suitable for top-down or arena-style roguelike gameplay
- implement a basic primary attack shell with clear extension points
- implement health and damage intake handling
- emit death or player-defeated signals through a clean interface or event flow
- keep combat calculations and reusable logic in the proper combat-related directories where appropriate
- document the player actor responsibilities and extension points
- add tests for pure combat or health logic where practical

## Required files
- `game/actors/player/player.tscn`
- `game/actors/player/player.gd`
- `game/combat/`
- `docs/systems/combat-system.md`
- `tests/unit/` and or `tests/integration/`

## Acceptance criteria
- player can be instantiated and controlled in a simple gameplay scene
- player can move without runtime errors
- player can perform a primary attack action through a clearly defined method or flow
- player can take damage and update health state correctly
- death condition emits a clear signal or event
- implementation preserves separation between actor control and reusable combat logic
- docs explain the actor's current capabilities and future extension points
- validation runs successfully

## Constraints
- do not build full combat polish, animation polish, or balance systems yet
- do not hardcode future weapon variety into one giant script
- keep implementation modular and extensible
- prefer typed GDScript

## Validation
- run repository validation script
- run relevant tests
- confirm player actor works inside a basic gameplay test scene

## Deliverable summary
Return:
- files changed
- what was implemented
- validation results
- remaining risks or follow-up items

---

# Issue 4: Create reusable enemy base framework

## Goal
Create a reusable enemy actor foundation with definition-driven stats, health handling, hit reaction support, and a simple chase-and-attack behavior state flow.

## Why this matters
Enemy architecture will scale across many content variations.
If the base framework is not modular and data-driven now, later content work will turn into duplication and brittle special cases.

## Scope
- create an enemy base scene and base script under `game/actors/enemies/`
- create an enemy definition model or Resource for stats and configurable properties
- implement health and damage intake handling for enemies
- implement a minimal behavior loop such as idle, chase, and attack
- expose a clean interface for future enemy variants and elite modifiers
- separate reusable logic from content-specific definitions
- document the enemy framework and extension pattern
- add tests for pure stat or behavior-selection helpers where practical

## Required files
- `game/actors/enemies/`
- `game/data/resources/` or equivalent definition location
- `game/combat/`
- `docs/systems/enemy-ai.md`
- `tests/unit/` and or `tests/integration/`

## Acceptance criteria
- enemy can be instantiated from a reusable base scene
- enemy stats are configurable through a definition model rather than hardcoded constants only
- enemy can take damage and die correctly
- enemy can perform a simple chase-and-attack loop without runtime errors
- framework supports future enemy variants without scene duplication for trivial changes
- docs explain how definitions, runtime behavior, and future extensions should work
- validation runs successfully

## Constraints
- do not implement a full enemy roster yet
- do not create one-off hacks for specific enemy types
- keep content definitions separate from shared behavior logic
- prefer typed GDScript and modular composition

## Validation
- run repository validation script
- run relevant tests
- confirm enemy can function in a basic gameplay test scene against the player shell

## Deliverable summary
Return:
- files changed
- what was implemented
- validation results
- remaining risks or follow-up items

---

# Issue 5: Implement post-encounter reward draft system

## Goal
Create a reusable reward draft system that presents three valid upgrade choices after an encounter and applies the selected upgrade to the active run state.

## Why this matters
This is one of the core replayability and retention loops of the roguelike.
It must be data-driven and modular so future rarity, weighting, synergy, blacklist, unlock, and content-expansion rules can be added without rewriting the whole system.

## Scope
- create upgrade definition data models or Resources
- create a central upgrade candidate selection service
- support filtering and duplicate-prevention hooks in one place
- create a reward draft UI screen or controller that displays three upgrade choices
- apply the selected upgrade to the active run state
- emit appropriate events or signals for reward-opened and upgrade-selected flow
- document the upgrade framework and reward application flow
- add tests for selection and filtering logic

## Required files
- `game/progression/upgrades/`
- `game/run/rewards/`
- `game/ui/screens/`
- `game/data/resources/` or equivalent content-definition location
- `docs/systems/upgrade-framework.md`
- `tests/unit/`

## Acceptance criteria
- system can load upgrade definitions
- post-encounter reward flow can request three valid upgrade candidates
- upgrade filtering happens in one central selection path
- duplicate prevention can be enforced centrally
- UI can present three upgrade choices without hardcoded upgrade content in the screen logic
- selecting an upgrade applies the effect to active run state through a clean interface
- tests cover core candidate selection logic
- docs explain definitions, filtering, application flow, and extension points
- validation runs successfully

## Constraints
- do not hardcode specific upgrades into the UI layer
- do not tightly couple reward UI to one scene implementation
- do not overbuild rarity or synergy systems before the core flow exists
- prefer data-driven design and typed GDScript

## Validation
- run repository validation script
- run relevant tests for selection and application logic
- confirm reward flow works in a minimal encounter-complete test path if practical

## Deliverable summary
Return:
- files changed
- what was implemented
- validation results
- remaining risks or follow-up items

