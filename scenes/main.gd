extends Node2D

enum Mode { MOVE, ATTACK }

var selected
var _mode: Mode = Mode.MOVE
var _selected_attack: AttackData

# PrepareGame e uma classe comum (RefCounted), nao um node - por isso
# precisa ficar guardada aqui. Sem essa referencia, nada mais na arvore de
# cena a mantem viva, e ela seria descartada antes de terminar seu trabalho.
var _prepare_game: PrepareGame

func _ready():

	$map/Grid2d.tile_clicked.connect(_on_tile_clicked)
	$UI/ActionMenu.move_requested.connect(_on_move_requested)
	$UI/ActionMenu.attack_hover_requested.connect(_on_attack_hover_requested)
	$UI/ActionMenu.attack_hover_cleared.connect(_on_attack_hover_cleared)
	$UI/ActionMenu.attack_selected.connect(_on_attack_selected)
	$UI/ActionMenu.end_turn_requested.connect(_on_end_turn_requested)

	_prepare_game = PrepareGame.new()
	_prepare_game.character_spawned.connect(_on_character_spawned)
	_prepare_game.run(self, $map/Characters)

# PrepareGame baixa players.json (aliados) e enemies.json (inimigos) e cria
# um Character por entrada; aqui a gente so pluga clique e derrota - quem
# decide quantos personagens existem, onde nascem e de que time sao e o
# proprio PrepareGame.
func _on_character_spawned(character: Character) -> void:
	character.clicked.connect(_on_character_clicked)
	character.defeated.connect(_on_character_defeated)

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
	_mode = Mode.MOVE
	_selected_attack = null
	$map/Grid2d.show_movement_range(character.grid_position, character.movement, _occupied_cells(character))
	$map/Camera2D.center_on(character.position)
	$UI/ActionMenu.set_attacks(character.attacks)
	$UI/ActionMenu.open()

func _deselect_character():
	selected = null
	_mode = Mode.MOVE
	_selected_attack = null
	$map/Grid2d.clear_highlight()
	$UI/ActionMenu.close()

func _on_character_clicked(character):
	_select_character(character)

func _on_character_defeated(character: Character) -> void:
	if selected == character:
		_deselect_character()
	character.queue_free()

func _on_tile_clicked(cell):
	if selected == null:
		return

	if _mode == Mode.ATTACK:
		_resolve_attack(cell)
		return

	var path = $map/Grid2d.build_path_to(cell)
	selected.move_to(path, $map/Grid2d.pathfinder)
	_deselect_character()

func _on_move_requested():
	# Volta do modo de ataque para o de movimento (o grid ja mostra o range
	# assim que o personagem e selecionado; o botao so precisa sair da
	# frente e restaurar o highlight de movimento caso o de ataque esteja
	# ativo).
	_mode = Mode.MOVE
	$map/Grid2d.show_movement_range(selected.grid_position, selected.movement, _occupied_cells(selected))
	$UI/ActionMenu.close()

# Ao passar o mouse sobre um ataque no menu, mostra so a sombra da area de
# alcance (sem trocar de modo) - o jogador ainda pode mover normalmente se
# desistir do hover sem clicar.
func _on_attack_hover_requested(attack: AttackData) -> void:
	if selected == null:
		return
	$map/Grid2d.show_attack_preview(_attack_range_cells(selected, attack))

func _on_attack_hover_cleared() -> void:
	$map/Grid2d.clear_attack_preview()

func _on_attack_selected(attack: AttackData) -> void:
	if selected == null:
		return

	_mode = Mode.ATTACK
	_selected_attack = attack
	$map/Grid2d.show_attack_targets(_attack_range_cells(selected, attack))
	$UI/ActionMenu.close()

# Sombra do target_range do ataque - toda a area de alcance a partir do
# personagem, e nao so as celulas onde ha inimigos em pe.
func _attack_range_cells(character: Character, attack: AttackData) -> Array[Vector2i]:
	var pathfinder: GridPathfinder = $map/Grid2d.pathfinder
	var cells: Array[Vector2i] = []
	for cell in AttackTargeting.cells_in_range(character.grid_position, attack.target_range):
		if pathfinder.is_within_bounds(cell):
			cells.append(cell)
	return cells

func _resolve_attack(cell: Vector2i) -> void:
	var target := _character_at(cell)
	if target == null or target.team == selected.team:
		return

	if randi_range(1, 100) <= _selected_attack.aim:
		target.take_damage(randi_range(_selected_attack.damage_min, _selected_attack.damage_max))

	_deselect_character()

func _occupied_cells(excluding: Character) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for node in $map/Characters.get_children():
		if node is Character and node != excluding:
			cells.append(node.grid_position)
	return cells

func _character_at(cell: Vector2i) -> Character:
	for node in $map/Characters.get_children():
		if node is Character and node.grid_position == cell:
			return node
	return null

func _on_end_turn_requested():
	_deselect_character()
