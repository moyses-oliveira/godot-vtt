extends Area2D

signal clicked(character)
signal trap_triggered(cell)

const CELL_SIZE = 64
const MOVE_TIME_PER_CELL = 0.35

@export var movement = 5

var grid_position = Vector2i()
var moving = false

func _ready():
	grid_position = Vector2i(floori(position.x / CELL_SIZE), floori(position.y / CELL_SIZE))
	update_position()

func update_position():
	position = Vector2(
		grid_position.x * CELL_SIZE + CELL_SIZE/2,
		grid_position.y * CELL_SIZE + CELL_SIZE/2
	)

# Segue o caminho ortogonal (celula a celula) calculado pelo grid, disparando
# armadilhas encontradas no percurso.
func move_to(path: Array[Vector2i], grid) -> void:
	if moving or path.is_empty():
		return

	grid_position = path[-1]
	moving = true

	var tween = create_tween()
	for cell in path:
		var target_position = Vector2(
			cell.x * CELL_SIZE + CELL_SIZE/2,
			cell.y * CELL_SIZE + CELL_SIZE/2
		)
		tween.tween_property(self, "position", target_position, MOVE_TIME_PER_CELL)
		if grid.is_trap(cell):
			tween.tween_callback(_on_trap_triggered.bind(cell))

	tween.finished.connect(func(): moving = false)

func _on_trap_triggered(cell):
	trap_triggered.emit(cell)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
			get_viewport().set_input_as_handled()
