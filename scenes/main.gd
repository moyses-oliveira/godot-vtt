extends Node2D

var selected

func _ready():

	for c in $Characters.get_children():
		c.clicked.connect(_on_character_clicked)

	$Grid2d.tile_clicked.connect(_on_tile_clicked)

func _on_character_clicked(character):
	selected = character
	$Grid2d.show_movement_range(character.grid_position, character.movement)

func _on_tile_clicked(cell):
	if selected == null:
		return

	var path = $Grid2d.build_path_to(cell)
	selected.move_to(path, $Grid2d)
	selected = null
	$Grid2d.clear_highlight()
