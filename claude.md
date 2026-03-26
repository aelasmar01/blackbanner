# CLAUDE.md

You are working on a Godot 4.x roguelike project implemented primarily in typed GDScript.
Your role is to complete scoped engineering tasks without damaging architecture, introducing avoidable coupling, or expanding the diff beyond what the task requires.

## Operating principles
Prioritize the following in order:
1. Correctness
2. Meeting the stated acceptance criteria
3. Minimal safe diff size
4. Clean architecture
5. Validation before completion
6. Test coverage when behavior changes
7. Documentation updates when system behavior changes

## Project direction
This repository is designed around:
- modular scene composition
- typed GDScript gameplay code
- data-driven content definitions
- small public APIs between systems
- event-driven communication where appropriate
- repeatable validation
- readable, maintainable code over cleverness

## Mandatory behavior
- Read `AGENTS.md` before editing.
- Read relevant docs under `docs/` before making changes.
- Inspect the current implementation before deciding on the change strategy.
- Make the minimum clean change that satisfies the task.
- Preserve public interfaces unless the task explicitly requires interface changes.
- Run validation commands before finishing.
- Be explicit about anything you could not validate.

## Preferred design choices
- typed GDScript over loosely typed scripting where practical
- composition over inheritance unless inheritance is already the established pattern
- Resources for content definitions
- signals and event-driven communication over deep direct references
- pure utility or service logic for rules that should be tested outside scene runtime
- small focused scenes with one clear responsibility

## Do not do these things
- Do not refactor unrelated systems.
- Do not rewrite working code for style alone.
- Do not create giant manager classes unless the task explicitly requires one.
- Do not hide critical gameplay behavior in inspector-only setup if script logic would be clearer.
- Do not hardcode content that should be data-driven.
- Do not rename files, methods, nodes, or signals unless needed.
- Do not leave TODO placeholders instead of required functionality unless the task explicitly allows stubs.
- Do not report validation as complete unless it was actually executed.

## Repository expectations
Treat these areas as the default ownership map.

- `game/autoload/` for intentional global services only
- `game/core/` for shared interfaces, utilities, services, constants
- `game/actors/` for player, enemies, projectiles, summons, pickups
- `game/combat/` for combat systems and effects
- `game/progression/` for upgrades, relics, unlocks, economy
- `game/run/` for encounter flow, rewards, map progression, directors
- `game/ui/` for HUD, menus, screens, widgets, UI controllers
- `game/data/` for content definitions and structured assets
- `tests/` for unit and integration coverage
- `docs/` for architecture and system documentation

## Scene safety rules
- Keep scenes small and modular.
- One scene should have one main responsibility.
- Access child nodes through stable references.
- Avoid fragile deep node-path lookups.
- Do not duplicate scenes for simple content variation if data definitions can handle it.
- Keep UI scenes responsible for presentation and interaction flow, not game-rule ownership.

## Data rules
If a feature looks like scalable content, prefer a Resource or structured data definition.
Examples:
- enemies
- attacks
- upgrades
- relics
- encounters
- rewards
- status effects
- biome modifiers

Avoid encoding scalable content in switch statements or large if chains when a definition-based model is cleaner and aligns with the existing repo.

## Testing guidance
Add or update tests when:
- gameplay behavior changes
- selection, weighting, serialization, or rule logic changes
- a bug fix should be guarded against regression

Prefer unit tests for pure logic and integration tests for scene or flow behavior.
If tests are not practical, explain why clearly.

## Documentation guidance
Update docs when:
- public interfaces changed
- save schema changed
- system flow changed
- architecture or ownership boundaries changed
- task instructions explicitly require docs

## Completion checklist
Before concluding a task, confirm the following:
- changed files reviewed
- task scope respected
- public interfaces preserved or intentionally updated
- tests added or updated where appropriate
- validation commands executed
- docs updated if needed
- remaining risks identified

## Required completion summary
At the end of the task, return:
- what was implemented
- files changed
- tests added or updated
- validation run and results
- docs updated
- remaining risks or follow-up suggestions

## Change discipline
If you discover a broader architectural issue while working, do not silently expand scope.
Finish the requested task cleanly first unless the discovered issue blocks correctness.
If it blocks correctness, fix the minimum required surrounding code and explain why.

## Working style
Be practical, conservative, and explicit.
Do not over-engineer.
Do not optimize prematurely.
Favor code that is easy to read, test, and extend.

