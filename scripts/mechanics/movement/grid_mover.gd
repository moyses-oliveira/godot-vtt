class_name GridMover
extends Node

## Componente de movimento em grid, reutilizavel por qualquer node 2D
## (Area2D, CharacterBody2D, etc). Anexe como filho do objeto e ele ganha
## posicao logica em celulas e a capacidade de seguir um caminho ortogonal
## celula a celula, disparando armadilhas no percurso.
##
## Uso: adicionar como filho de qualquer personagem/objeto e chamar
## move_along_path(path, pathfinder) para movimenta-lo.

signal movement_finished
signal trap_entered(cell)

@export var cell_size: int = 64
@export var move_time_per_cell: float = 0.2
@export var movement_range: int = 5

var grid_position := Vector2i()
var moving: bool = false

func _ready() -> void:
	var target := get_parent() as Node2D
	if target:
		grid_position = Vector2i(floori(target.position.x / cell_size), floori(target.position.y / cell_size))
		snap_to_grid_position()

func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size + cell_size / 2, cell.y * cell_size + cell_size / 2)

func snap_to_grid_position() -> void:
	var target := get_parent() as Node2D
	if target:
		target.position = cell_center(grid_position)

## Segue o caminho (lista de celulas, sem incluir a atual) com uma tween
## sequencial, uma celula por vez, disparando armadilhas encontradas.
func move_along_path(path: Array[Vector2i], pathfinder: GridPathfinder) -> void:
	if moving or path.is_empty():
		return

	var target := get_parent() as Node2D
	if not target:
		return

	grid_position = path[-1]
	moving = true

	var tween := create_tween()
	for cell in path:
		tween.tween_property(target, "position", cell_center(cell), move_time_per_cell)
		if pathfinder.is_trap(cell):
			tween.tween_callback(_on_trap_entered.bind(cell))

	tween.finished.connect(_on_movement_finished)

func _on_trap_entered(cell: Vector2i) -> void:
	trap_entered.emit(cell)

func _on_movement_finished() -> void:
	moving = false
	movement_finished.emit()
