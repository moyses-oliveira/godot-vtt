class_name TileShadowSet
extends RefCounted

## Algoritmo central de "sombras" de tabuleiro: grupos nomeados de celulas
## com uma cor (alcance de movimento, alvos de ataque, previa de ataque,
## etc.) mais uma celula de hover que sobrepoe a cor de qualquer grupo em
## que ela esteja. So guarda estado e decide qual cor cada celula deve
## receber - nao sabe desenhar nada. A view (TileShadowLayer) escuta o
## sinal `changed` e redesenha; qualquer outro board/grid pode reusar esta
## mesma classe sem depender de Node nenhum.

signal changed

var hover_cell := Vector2i(-1, -1)
var hover_color := Color.WHITE

var _groups: Dictionary = {}  # id:String -> {cells: Array[Vector2i], color: Color}

func set_group(id: String, cells: Array[Vector2i], color: Color) -> void:
	_groups[id] = {"cells": cells, "color": color}
	changed.emit()

func clear_group(id: String) -> void:
	if _groups.erase(id):
		changed.emit()

func clear_all() -> void:
	if _groups.is_empty() and hover_cell == Vector2i(-1, -1):
		return
	_groups.clear()
	hover_cell = Vector2i(-1, -1)
	changed.emit()

func has_group(id: String) -> bool:
	return _groups.has(id)

func cells_of(id: String) -> Array[Vector2i]:
	if _groups.has(id):
		return _groups[id]["cells"]
	return []

func set_hover(cell: Vector2i, color: Color) -> void:
	hover_cell = cell
	hover_color = color
	changed.emit()

func clear_hover() -> void:
	if hover_cell == Vector2i(-1, -1):
		return
	hover_cell = Vector2i(-1, -1)
	changed.emit()

## Uma entrada {cell, color} por celula de todos os grupos, ja resolvendo
## a cor final (a de hover, se a celula estiver sob o mouse; senao a do
## proprio grupo). E o unico metodo que a view precisa chamar em _draw().
func painted_cells() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in _groups.keys():
		var group: Dictionary = _groups[id]
		for cell in group["cells"]:
			var color: Color = hover_color if cell == hover_cell else group["color"]
			result.append({"cell": cell, "color": color})
	return result
