class_name PrepareGame
extends RefCounted

## Bootstrap do jogo, como uma classe de aplicacao comum: nao e um elemento
## de cena, nao aparece na arvore de nodes nem no editor, e nao tem posicao
## no mundo. E instanciada e chamada explicitamente pelo controlador
## principal (main.gd), igual a qualquer outra classe de orquestracao do
## seu codigo.
##
## Uso:
##   var prepare_game = PrepareGame.new()
##   prepare_game.character_spawned.connect(...)
##   prepare_game.finished.connect(...)
##   prepare_game.run(self, $map/Characters)
##
## Fluxo: baixa resources/fakers/players.json (via PlayerRosterLoader), cria
## um Character por jogador em uma celula distinta do grid e dispara o
## download do avatar de cada um (via RemoteTextureLoader). "character_spawned"
## e emitido assim que o node existe na arvore (antes mesmo do avatar
## terminar de carregar), para que main.gd possa conectar o clique sem
## precisar esperar a rede.
##
## O parametro "host" de run() nao e sobre "pertencer a cena": e apenas o
## ponto de fixacao que o Godot exige para os HTTPRequest funcionarem (eles
## so processam resposta de rede enquanto estao dentro da arvore).

signal character_spawned(character: Character)
signal finished

const DEFAULT_ROSTER_URL = "http://127.0.0.1:8081/players.json"
const DEFAULT_MOVEMENT_RANGE = 5
const SPAWN_COLUMN = 1

var roster_url: String

var _pending_avatars := 0

func _init(p_roster_url: String = DEFAULT_ROSTER_URL) -> void:
	roster_url = p_roster_url

func run(host: Node, characters_container: Node) -> void:
	var loader := PlayerRosterLoader.new()
	host.add_child(loader)
	loader.roster_ready.connect(_on_roster_ready.bind(host, characters_container, loader))
	loader.load_failed.connect(_on_roster_failed.bind(loader))
	loader.load_from_url(roster_url)

func _on_roster_ready(players: Array[PlayerData], host: Node, characters_container: Node, loader: PlayerRosterLoader) -> void:
	loader.queue_free()

	if players.is_empty():
		finished.emit()
		return

	_pending_avatars = players.size()
	for index in players.size():
		_spawn_player(players[index], index, host, characters_container)

# Cada personagem nasce numa celula diferente (mesma coluna, linha = indice
# do jogador na lista) para nao empilhar todo mundo no mesmo tile.
func _spawn_player(player: PlayerData, index: int, host: Node, characters_container: Node) -> void:
	var movement_range := player.movement_points if player.movement_points > 0 else DEFAULT_MOVEMENT_RANGE
	var character := Character.new(movement_range)
	character.place_at_cell(Vector2i(SPAWN_COLUMN, index))
	characters_container.add_child(character)
	character_spawned.emit(character)

	if player.avatar_url.is_empty():
		_on_avatar_done()
		return

	var texture_loader := RemoteTextureLoader.new()
	host.add_child(texture_loader)
	texture_loader.texture_ready.connect(_on_avatar_ready.bind(character, texture_loader))
	texture_loader.load_failed.connect(_on_avatar_failed.bind(texture_loader))
	texture_loader.load_from_url(player.avatar_url)

func _on_avatar_ready(texture: Texture2D, character: Character, loader: RemoteTextureLoader) -> void:
	character.set_appearance_texture(texture)
	loader.queue_free()
	_on_avatar_done()

func _on_avatar_failed(reason: String, loader: RemoteTextureLoader) -> void:
	push_warning("PrepareGame: %s" % reason)
	loader.queue_free()
	_on_avatar_done()

func _on_avatar_done() -> void:
	_pending_avatars -= 1
	if _pending_avatars <= 0:
		finished.emit()

func _on_roster_failed(reason: String, loader: PlayerRosterLoader) -> void:
	push_warning("PrepareGame: %s" % reason)
	loader.queue_free()
	finished.emit()
