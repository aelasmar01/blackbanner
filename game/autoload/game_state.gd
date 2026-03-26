class_name GameStateService
extends Node
## Owns the authoritative in-memory profile state.
##
## Other systems read from here; only SaveManager should write
## bulk state back after a load.  GameState itself never touches
## the filesystem.

## Current profile data. Null until populated by SaveManager
## during bootstrap.
var profile: ProfileState = null

## True once a profile has been loaded or created this session.
var profile_ready: bool = false


func set_profile(data: ProfileState) -> void:
	profile = data
	profile_ready = data != null


func clear_profile() -> void:
	profile = null
	profile_ready = false
