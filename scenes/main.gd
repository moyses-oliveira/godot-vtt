extends Node2D

var selected

# PrepareGame e uma classe comum (RefCounted), nao um node - por isso
# precisa ficar guardada aqui. Sem essa referencia, nada mais na arvore de
# cena a mantem viva, e ela seria descartada antes de terminar seu trabalho.
var _prepare_game: PrepareGame

func _ready():

	var hero := _spawn_character(Vector2i(1, 1))

	$Grid2d.tile_clicked.connect(_on_tile_clicked)

	_prepare_game = PrepareGame.new()
	_prepare_game.run(self, hero)

# Cria quantos personagens forem necessarios direto em codigo, sem depender
# de nenhuma cena (.tscn) de personagem - basta chamar isso de novo com
# outra celula para adicionar mais um.
func _spawn_character(cell: Vector2i) -> Character:
	var character := Character.new()
	character.place_at_cell(cell)
	character.clicked.connect(_on_character_clicked)
	$Characters.add_child(character)
	return character

func _unhandled_input(event):
	if event.is_action_pressed("ui_focus_next"):
		_select_next_character()

func _select_next_character():
	var characters = $Characters.get_children()
	if characters.is_empty():
		return

	var next_index = (characters.find(selected) + 1) % characters.size()
	_select_character(characters[next_index])

func _select_character(character):
	selected = character
	$Grid2d.show_movement_range(character.grid_position, character.movement)
	$Camera2D.center_on(character.position)

func _on_character_clicked(character):
	_select_character(character)

func _on_tile_clicked(cell):
	if selected == null:
		return

	var path = $Grid2d.build_path_to(cell)
	selected.move_to(path, $Grid2d.pathfinder)
	selected = null
	$Grid2d.clear_highlight()
