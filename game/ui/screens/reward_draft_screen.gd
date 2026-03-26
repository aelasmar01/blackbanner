extends Control
## UI screen that presents a set of upgrade candidates and lets
## the player select one.
##
## This screen has NO knowledge of specific upgrade content.  It
## receives UpgradeDefinition objects and renders them generically.
## Selection is routed back through a provided callback or signal.

signal selection_made(upgrade_id: String)

@onready var choice_container: HBoxContainer = %ChoiceContainer
@onready var title_label: Label = %TitleLabel

## The definitions currently being displayed.
var _candidates: Array[UpgradeDefinition] = []


## Populate the screen with a set of candidates.
## Call this before making the screen visible.
func show_draft(candidates: Array[UpgradeDefinition]) -> void:
	_candidates = candidates
	_clear_choices()
	_build_choices()
	visible = true


## --- Internal ---

func _clear_choices() -> void:
	for child: Node in choice_container.get_children():
		child.queue_free()


func _build_choices() -> void:
	for def: UpgradeDefinition in _candidates:
		var card: Button = _create_choice_card(def)
		choice_container.add_child(card)


func _create_choice_card(def: UpgradeDefinition) -> Button:
	var card: Button = Button.new()
	card.custom_minimum_size = Vector2(200.0, 260.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Build card content as a VBoxContainer inside the button.
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)

	var name_label: Label = Label.new()
	name_label.text = def.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var rarity_label: Label = Label.new()
	rarity_label.text = _rarity_text(def.rarity)
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(rarity_label)

	var desc_label: Label = Label.new()
	desc_label.text = def.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_label)

	card.add_child(vbox)
	card.pressed.connect(_on_choice_pressed.bind(def.id))
	return card


func _rarity_text(rarity: int) -> String:
	match rarity:
		0: return "Common"
		1: return "Uncommon"
		2: return "Rare"
		3: return "Legendary"
		_: return "Unknown"


func _on_choice_pressed(upgrade_id: String) -> void:
	visible = false
	selection_made.emit(upgrade_id)
