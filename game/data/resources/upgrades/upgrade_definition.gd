class_name UpgradeDefinition
extends Resource
## Data-driven definition for a single upgrade that can appear
## in a post-encounter reward draft.
##
## Each upgrade is identified by a unique string id.  The pool
## selection service uses rarity, tags, and the max_stacks field
## to decide eligibility.  The actual gameplay effect is resolved
## by the system that consumes the upgrade id at application time.

## Unique identifier used in RunState.upgrades and by gameplay
## systems to resolve the upgrade's effect.
@export var id: String = ""

## Display name shown to the player in the draft screen.
@export var display_name: String = ""

## Short description of what the upgrade does.
@export var description: String = ""

## Rarity tier — used by future weighting logic.
## 0 = common, 1 = uncommon, 2 = rare, 3 = legendary.
@export_range(0, 3) var rarity: int = 0

## Maximum number of times this upgrade can appear in a single
## run.  0 means unlimited stacking.
@export var max_stacks: int = 0

## Freeform tags for filtering (e.g., "offensive", "defensive",
## "utility").  Selection hooks can use these to bias or exclude
## categories.
@export var tags: PackedStringArray = PackedStringArray()
