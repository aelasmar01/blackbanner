# Scene Boundaries

## Startup Flow

```
project.godot
  └─ main_scene = bootstrap.tscn
       │
       ├─ Autoloads (initialized by engine before _ready):
       │    EventBus   — global signal hub
       │    GameState  — in-memory profile state owner
       │    SaveManager — filesystem persistence
       │    RunManager — run lifecycle orchestrator
       │
       ├─ bootstrap._ready()
       │    1. SaveManager.ensure_profile()
       │       • loads profile from user://profile.save
       │       • if missing, creates and saves a default profile
       │       • populates GameState.profile
       │    2. EventBus.bootstrap_finished emitted
       │    3. change_scene_to_file → main_menu.tscn
       │
       └─ main_menu.tscn
            • placeholder menu — emits EventBus.main_menu_entered
```

## Scene Ownership Rules

| Scene | Responsibility | Does NOT own |
|---|---|---|
| `bootstrap.tscn` | One-time init, profile ensure, scene transition | Gameplay, UI layout, menus |
| `main_menu.tscn` | Menu presentation and navigation | Profile creation, save logic, run state |

## Principles

- Each scene has **one clear responsibility**.
- Scenes communicate through **EventBus signals** or narrow API calls on autoloads, not deep cross-scene references.
- UI scenes handle **presentation and interaction flow** only — game rules live in autoloads or service scripts.
- Scenes should be **small and composable**; avoid monolithic scene trees.
