extends Control

## View burra do menu de acoes do personagem selecionado. Nao conhece
## Character nem regras de turno - apenas exibe botoes (um por ataque
## disponivel, montados em runtime a partir de set_attacks) e emite sinais
## para quem estiver escutando (main.gd) decidir o que fazer.
##
## Uso:
##   $UI/ActionMenu.move_requested.connect(...)
##   $UI/ActionMenu.attack_hover_requested.connect(...)
##   $UI/ActionMenu.attack_selected.connect(...)
##   $UI/ActionMenu.end_turn_requested.connect(...)
##   $UI/ActionMenu.set_attacks(character.attacks)
##   $UI/ActionMenu.open()

signal move_requested
signal attack_hover_requested(attack: AttackData)
signal attack_hover_cleared
signal attack_selected(attack: AttackData)
signal end_turn_requested

@onready var _move_button: Button = $VBoxContainer/MoveButton
@onready var _attacks_container: VBoxContainer = $VBoxContainer/AttacksContainer
@onready var _end_turn_button: Button = $VBoxContainer/EndTurnButton

func _ready() -> void:
	_move_button.pressed.connect(_on_move_pressed)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)
	close()

## Recria os botoes de ataque a partir da lista do personagem selecionado -
## um botao por AttackData, nomeado com attack.name.
func set_attacks(attacks: Array[AttackData]) -> void:
	for child in _attacks_container.get_children():
		child.queue_free()

	for attack in attacks:
		var button := Button.new()
		button.text = attack.name
		button.mouse_entered.connect(_on_attack_button_hovered.bind(attack))
		button.mouse_exited.connect(_on_attack_button_unhovered)
		button.pressed.connect(_on_attack_button_pressed.bind(attack))
		_attacks_container.add_child(button)

func open() -> void:
	visible = true

func close() -> void:
	visible = false

func _on_move_pressed() -> void:
	move_requested.emit()

func _on_attack_button_hovered(attack: AttackData) -> void:
	attack_hover_requested.emit(attack)

func _on_attack_button_unhovered() -> void:
	attack_hover_cleared.emit()

func _on_attack_button_pressed(attack: AttackData) -> void:
	attack_selected.emit(attack)

func _on_end_turn_pressed() -> void:
	print("fim de turno")
	end_turn_requested.emit()
