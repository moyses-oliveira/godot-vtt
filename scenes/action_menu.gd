extends Control

## View burra do menu de acoes do personagem selecionado. Nao conhece
## Character nem regras de turno - apenas exibe botoes e emite sinais para
## quem estiver escutando (main.gd) decidir o que fazer.
##
## Uso:
##   $UI/ActionMenu.move_requested.connect(...)
##   $UI/ActionMenu.end_turn_requested.connect(...)
##   $UI/ActionMenu.open()

signal move_requested
signal end_turn_requested

@onready var _move_button: Button = $VBoxContainer/MoveButton
@onready var _end_turn_button: Button = $VBoxContainer/EndTurnButton

func _ready() -> void:
	_move_button.pressed.connect(_on_move_pressed)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)
	close()

func open() -> void:
	visible = true

func close() -> void:
	visible = false

func _on_move_pressed() -> void:
	move_requested.emit()

func _on_end_turn_pressed() -> void:
	print("fim de turno")
	end_turn_requested.emit()
