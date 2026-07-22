extends Node2D

var selected

# PrepareGame e uma classe comum (RefCounted), nao um node - por isso
# precisa ficar guardada aqui. Sem essa referencia, nada mais na arvore de
# cena a mantem viva, e ela seria descartada antes de terminar seu trabalho.
var _prepare_game: PrepareGame

func _ready():

	$map/Grid2d.tile_clicked.connect(_on_tile_clicked)
	$UI/ActionMenu.move_requested.connect(_on_move_requested)
	$UI/ActionMenu.end_turn_requested.connect(_on_end_turn_requested)

	_prepare_game = PrepareGame.new()
	_prepare_game.character_spawned.connect(_on_character_spawned)
	_prepare_game.run(self, $map/Characters)

# PrepareGame baixa resources/fakers/players.json e cria um Character por
# jogador; aqui a gente so pluga o clique - quem decide quantos personagem
# existem e onde eles nascem e o proprio PrepareGame.
func _on_character_spawned(character: Character) -> void:
	character.clicked.connect(_on_character_clicked)

func _unhandled_input(event):
	if event.is_action_pressed("ui_focus_next"):
		_select_next_character()

func _select_next_character():
	var characters = $map/Characters.get_children()
	if characters.is_empty():
		return

	var next_index = (characters.find(selected) + 1) % characters.size()
	_select_character(characters[next_index])

func _select_character(character):
	selected = character
	$map/Grid2d.show_movement_range(character.grid_position, character.movement)
	$map/Camera2D.center_on(character.position)
	$UI/ActionMenu.open()

func _deselect_character():
	selected = null
	$map/Grid2d.clear_highlight()
	$UI/ActionMenu.close()

func _on_character_clicked(character):
	_select_character(character)

func _on_tile_clicked(cell):
	if selected == null:
		return

	var path = $map/Grid2d.build_path_to(cell)
	selected.move_to(path, $map/Grid2d.pathfinder)
	_deselect_character()

func _on_move_requested():
	# Grid ja mostra o range assim que o personagem e selecionado; o botao
	# so precisa sair da frente para o jogador clicar no tile de destino.
	$UI/ActionMenu.close()

func _on_end_turn_requested():
	_deselect_character()
