class_name CameraPan
extends Camera2D

## Mecanica de camera: arrastar o cenario com as setas do teclado, com o
## botao do meio do mouse, ou pressionando e arrastando na tela (touch).
## Tambem expoe center_on() para centralizar suavemente em um ponto (usado
## ao trocar o personagem selecionado).

@export var keyboard_pan_speed: float = 600.0
@export var center_on_select_time: float = 0.35

var _middle_mouse_dragging := false
var _touch_index := -1

func _process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		position += input_vector * keyboard_pan_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_middle_mouse_dragging = event.pressed
	elif event is InputEventMouseMotion and _middle_mouse_dragging:
		position -= event.relative / zoom
	elif event is InputEventScreenTouch:
		_touch_index = event.index if event.pressed else -1
	elif event is InputEventScreenDrag and event.index == _touch_index:
		position -= event.relative / zoom

func center_on(target_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, center_on_select_time)
