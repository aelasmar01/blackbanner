class_name EventBusService
extends Node
## Global event bus for decoupled cross-system communication.
##
## Systems emit and connect to signals here instead of holding
## direct references to each other.  Keep signals focused on
## flow-level events; do not relay per-frame gameplay data.

# --- Startup / scene flow ---
signal bootstrap_finished
signal main_menu_entered

# --- Profile ---
signal profile_loaded(profile: ProfileState)
signal profile_saved

# --- Run lifecycle ---
signal run_started
signal run_ended
