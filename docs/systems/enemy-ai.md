# Enemy AI

## Overview

The enemy framework is built around one reusable actor scene and a data-driven `EnemyDefinition` resource. Shared runtime behavior lives in `game/actors/enemies/`; content tuning lives under `game/data/resources/enemies/`.

## Files

- `game/actors/enemies/enemy_base.tscn`
- `game/actors/enemies/enemy_base.gd`
- `game/actors/enemies/enemy_behavior_selector.gd`
- `game/data/resources/enemies/enemy_definition.gd`
- `game/data/resources/enemies/default_enemy_definition.tres`

## Scene Structure

```text
EnemyBase (CharacterBody2D)
  BodyShape (CollisionShape2D)
  Health (HealthComponent) [unique name]
  AttackTimer (Timer) [unique name]
  HitReactionTimer (Timer) [unique name]
```

## Runtime Responsibilities

`enemy_base.gd` owns:
- target following through an exported `target_path` or `set_target()`
- idle, chase, attack, and hit-reaction state flow
- attack timing and contact-damage delivery
- death handling through the shared `HealthComponent`

`enemy_base.gd` does not own:
- content tuning for stats
- variant-specific attacks or elite modifiers
- encounter orchestration or spawn management

## EnemyDefinition Fields

- `display_name`
- `max_hp`
- `move_speed`
- `chase_range`
- `attack_range`
- `attack_cooldown`
- `contact_damage`
- `hit_reaction_duration`
- `hit_reaction_speed`

These values are stored in a Resource so future enemy variants can reuse the same scene and script without duplicating behavior code.

## Behavior Flow

`EnemyBehaviorSelector` resolves one of four states:
- `idle`
- `chase`
- `attack`
- `hit_reaction`

Selection priority is:
1. `hit_reaction` while the hit-reaction timer is active
2. `attack` when a valid target is inside `attack_range`
3. `chase` when a valid target is inside `chase_range`
4. `idle` otherwise

## Combat Integration

- Damage intake is exposed through `take_damage(damage_info: Damage)`.
- Health bookkeeping is delegated to `HealthComponent`.
- Contact attacks create a shared `Damage` object and call the target's `take_damage()` method.
- Death disables movement/collision and emits the local `defeated` signal.

## Extension Pattern

- Create new `.tres` definitions to change stats without duplicating the enemy scene.
- Subclass or wrap `enemy_base.gd` only when a variant needs behavior beyond the shared idle/chase/attack flow.
- Replace the contact-damage implementation with a different attack method while keeping the same state-selection helper if a variant needs ranged or telegraphed attacks.

## Test Scene

`tests/integration/enemy_player_test_scene.tscn` instantiates the reusable enemy base against the current player shell and wires the enemy target through `target_path`. It exists as a minimal gameplay smoke scene for manual or automated validation.
