class_name Character
extends Area2D

## Um personagem do grid tatico, inteiramente construido em codigo - sem
## nenhum arquivo .tscn por tras. Cada instancia monta sua propria arvore
## de nodes (colisao, movimento, sprite) em _init(). Criar um personagem
## novo e so chamar Character.new() e adiciona-lo em algum node da cena;
## nao existe limite de quantos podem existir ao mesmo tempo.
##
## Uso:
##   var hero = Character.new()
##   $Characters.add_child(hero)
##   hero.place_at_cell(Vector2i(1, 1))

signal clicked(character)
signal trap_triggered(cell)

const COLLISION_RADIUS = 30.0
const SPRITE_MARGIN = 8.0
const DEFAULT_TEXTURE_PATH = "res://resources/characters/helmet-svgrepo-com.svg"

var mover: GridMover
var sprite: Sprite2D

var grid_position: Vector2i:
	get: return mover.grid_position

var movement: int:
	get: return mover.movement_range

func _init(movement_range: int = 5) -> void:
	_build_collision_shape()
	_build_mover(movement_range)
	_build_sprite()

func _ready() -> void:
	mover.trap_entered.connect(func(cell): trap_triggered.emit(cell))
	_fit_sprite_to_tile()

func _build_collision_shape() -> void:
	var circle := CircleShape2D.new()
	circle.radius = COLLISION_RADIUS

	var shape := CollisionShape2D.new()
	shape.shape = circle
	add_child(shape)

func _build_mover(movement_range: int) -> void:
	mover = GridMover.new()
	mover.movement_range = movement_range
	add_child(mover)

func _build_sprite() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load(DEFAULT_TEXTURE_PATH)
	add_child(sprite)

## Posiciona o personagem em uma celula do grid, ja atualizando sua
## posicao visual (em pixels) para o centro dela.
func place_at_cell(cell: Vector2i) -> void:
	mover.grid_position = cell
	mover.snap_to_grid_position()

func move_to(path: Array[Vector2i], pathfinder: GridPathfinder) -> void:
	mover.move_along_path(path, pathfinder)

## Troca a aparencia do personagem. Quem chama isso nao precisa saber que
## por baixo existe um Sprite2D - so pede para o personagem trocar sua
## textura.
func set_appearance_texture(texture: Texture2D) -> void:
	sprite.texture = texture
	_fit_sprite_to_tile()

## Redimensiona o sprite para caber dentro do tamanho do tile (com uma
## margem), nao importa a resolucao da textura atual.
func _fit_sprite_to_tile() -> void:
	if not sprite.texture:
		return

	var texture_size = sprite.texture.get_size()
	var largest_side = max(texture_size.x, texture_size.y)
	if largest_side <= 0:
		return

	var target_size = mover.cell_size - SPRITE_MARGIN * 2.0
	var fit_scale = target_size / largest_side
	sprite.scale = Vector2(fit_scale, fit_scale)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
			get_viewport().set_input_as_handled()
