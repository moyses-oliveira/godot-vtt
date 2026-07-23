class_name CameraPan
extends Camera2D

## Mecanica de camera: arrastar o cenario com as setas do teclado, com o
## botao do meio do mouse, ou pressionando e arrastando na tela (touch).
## Tambem expoe center_on() para centralizar suavemente em um ponto (usado
## ao trocar o personagem selecionado).
##
## O arrasto do botao do meio e lido por polling (Input.is_mouse_button_pressed
## + posicao do mouse a cada _process), em vez de depender de eventos de
## InputEventMouseMotion/Button chegando ate este node. Esses eventos podem
## ser engolidos antes por Controls da UI (botoes do menu) ou pelo picking
## fisico dos personagens (Area2D) sob o cursor, o que fazia o arrasto
## parar sempre que o clique ou o movimento passava por cima deles - so
## "funcionava" quando o mouse ficava inteiramente sobre area vazia do
## grid. Polling em _process nao depende de nenhum desses consumidores.

@export var keyboard_pan_speed: float = 600.0
@export var center_on_select_time: float = 0.35

var _middle_mouse_dragging := false
var _last_mouse_position := Vector2.ZERO
var _touch_index := -1

func _process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		position += input_vector * keyboard_pan_speed * delta

	_process_middle_mouse_drag()

func _process_middle_mouse_drag() -> void:
	var mouse_position := get_viewport().get_mouse_position()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if _middle_mouse_dragging:
			position -= (mouse_position - _last_mouse_position) / zoom
		_middle_mouse_dragging = true
	else:
		_middle_mouse_dragging = false

	_last_mouse_position = mouse_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_touch_index = event.index if event.pressed else -1
	elif event is InputEventScreenDrag and event.index == _touch_index:
		position -= event.relative / zoom

func center_on(target_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, center_on_select_time)
