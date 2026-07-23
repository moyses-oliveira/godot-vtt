class_name TileShadowLayer
extends Node2D

## Componente "plugin" de highlight de tiles: um Node2D generico e
## reutilizavel que desenha grupos de celulas coloridas ("sombras") sobre
## qualquer grid. Nao conhece Character, AttackData, turnos ou qualquer
## outra regra de jogo - so recebe id + celulas + cor. Toda cena com um
## board pode instanciar scenes/components/tile_shadow_layer.tscn como
## filha e chamar os metodos abaixo para destacar celulas, sem duplicar
## codigo de desenho em cada tela.
##
## Uso:
##   var shadows := preload("res://scenes/components/tile_shadow_layer.tscn").instantiate()
##   shadows.cell_size = 64
##   add_child(shadows)
##   shadows.set_shadow("movement_range", cells, Color(0.4, 1.0, 0.4, 0.35))
##   shadows.set_hover(mouse_cell, Color(0.4, 0.8, 1.0, 0.5))
##   shadows.clear_shadow("movement_range")

@export var cell_size: int = 64

var _shadows := TileShadowSet.new()

func _ready() -> void:
	_shadows.changed.connect(queue_redraw)

func set_shadow(id: String, cells: Array[Vector2i], color: Color) -> void:
	_shadows.set_group(id, cells, color)

func clear_shadow(id: String) -> void:
	_shadows.clear_group(id)

func clear_all() -> void:
	_shadows.clear_all()

func has_shadow(id: String) -> bool:
	return _shadows.has_group(id)

func cells_of(id: String) -> Array[Vector2i]:
	return _shadows.cells_of(id)

func set_hover(cell: Vector2i, color: Color) -> void:
	_shadows.set_hover(cell, color)

func clear_hover() -> void:
	_shadows.clear_hover()

func _draw() -> void:
	for entry in _shadows.painted_cells():
		var cell: Vector2i = entry["cell"]
		var color: Color = entry["color"]
		draw_rect(Rect2(cell.x * cell_size, cell.y * cell_size, cell_size, cell_size), color)
