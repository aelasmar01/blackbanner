# Combat System

## Overview

The combat system is built around composable components that separate health bookkeeping from actor-specific behavior.  Actors own their movement and input; combat math lives in shared components under `game/combat/`.

## Components

### HealthComponent (`game/combat/health_component.gd`)

A `Node`-based component attached as a child of any actor that has hit points.

| Property | Type | Description |
|---|---|---|
| `max_hp` | `float` (exported) | Maximum hit points, set per-actor in the inspector or scene |
| `current_hp` | `float` | Current hit points, clamped to `[0, max_hp]` |
| `is_dead` | `bool` (readonly) | `true` when `current_hp <= 0` |

| Signal | Payload | Emitted when |
|---|---|---|
| `damaged` | `Damage` | After HP is reduced |
| `healed` | `float` (amount restored) | After HP is increased |
| `died` | — | When HP reaches zero |

**Key methods:**
- `take_damage(damage_info: Damage) -> float` — apply damage, return actual dealt
- `heal(amount: float) -> float` — restore HP, return actual healed
- `reset()` — set HP back to max (init/revive, not normal healing)

### Damage (`game/combat/damage.gd`)

A lightweight `RefCounted` data object passed into `take_damage()`.

| Field | Type | Description |
|---|---|---|
| `amount` | `float` | Raw damage value |
| `source` | `Node` | The node that caused the damage (nullable) |
| `type` | `StringName` | Semantic tag (`&"melee"`, `&"fire"`, etc.) |

This object is the extension point for future modifiers, resistances, and damage-type interactions.  Systems that modify damage can inspect and alter the object before it reaches the health component.

## Player Actor (`game/actors/player/`)

### Scene structure

```
Player (CharacterBody2D)
  ├── BodyShape (CollisionShape2D)
  ├── Health (HealthComponent) [unique name]
  ├── AttackTimer (Timer) [unique name]
  └── AttackOrigin (Marker2D) [unique name]
```

### Responsibilities

| Area | Owner |
|---|---|
| Movement (8-dir input) | `player.gd._handle_movement()` |
| Facing direction | `player.gd.facing` — updated each frame from input |
| Primary attack | `player.gd.primary_attack()` — spawns a short-lived `Area2D` hitbox |
| Health / death | Delegated to `HealthComponent`; death emits `EventBus.player_died` |
| Damage intake | `player.gd.take_damage(Damage)` — delegates to health component |

### Collision layers

| Layer | Usage |
|---|---|
| 1 | Player body |
| 2 | Enemy bodies |
| 3 | Projectiles / hitboxes |

The player's attack hitbox listens on mask layer 2 (enemies).

### Extension points

- **Weapon variety**: Override or replace `primary_attack()` and `_spawn_attack_area()` to change the attack shape, range, or behavior.
- **Damage modifiers**: Insert logic between the `take_damage()` public method and the `health.take_damage()` call to add armor, shields, or invincibility frames.
- **Animation**: Connect to `HealthComponent.damaged`, `HealthComponent.died`, and the attack flow to drive animation and VFX.
- **Stats**: Movement speed and attack cooldown are exported — future upgrade systems can modify these at runtime.

## EventBus Signals

| Signal | Payload | Purpose |
|---|---|---|
| `player_damaged` | `Damage` | Notify HUD, camera shake, etc. |
| `player_died` | — | Trigger run-end flow, death screen, etc. |

## Design Decisions

- **Composition over inheritance**: `HealthComponent` is a child node, not a base class.  Enemies will reuse the same component.
- **Damage as data**: The `Damage` class carries context so combat modifiers can be applied without coupling the health system to specific sources.
- **No animation/VFX yet**: This is a combat *shell* — visual polish will be layered on without changing the health or damage API.
- **Input actions**: Movement uses built-in `ui_*` actions.  The `primary_attack` action must be added to the input map before the player scene is used in gameplay.
