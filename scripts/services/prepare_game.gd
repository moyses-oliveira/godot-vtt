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
##   prepare_game.finished.connect(...)
##   prepare_game.run(self, personagem)
##
## Hoje a unica tarefa e baixar a textura do atirador e aplicar no
## personagem informado. No futuro, outras tarefas de carregamento de dados
## via API podem ser adicionadas aqui, cada uma na sua propria funcao,
## seguindo o mesmo padrao.
##
## Esta classe nao sabe COMO baixar uma imagem (isso e responsabilidade do
## RemoteTextureLoader) nem COMO trocar a aparencia do personagem (isso e
## responsabilidade do proprio personagem, via set_appearance_texture).
## Ela apenas coordena essas duas coisas.
##
## O parametro "host" de run() nao e sobre "pertencer a cena": e apenas o
## ponto de fixacao que o Godot exige para o HTTPRequest funcionar (ele
## so processa a resposta de rede enquanto esta dentro da arvore).

signal finished

const DEFAULT_SNIPER_TEXTURE_URL = "http://127.0.0.1:8080/Sniper_shooter/rotations/char.png"

var sniper_texture_url: String

func _init(p_sniper_texture_url: String = DEFAULT_SNIPER_TEXTURE_URL) -> void:
	sniper_texture_url = p_sniper_texture_url

func run(host: Node, character) -> void:
	var loader := RemoteTextureLoader.new()
	host.add_child(loader)
	loader.texture_ready.connect(_on_sniper_texture_ready.bind(character, loader))
	loader.load_failed.connect(_on_sniper_texture_failed.bind(loader))
	loader.load_from_url(sniper_texture_url)

func _on_sniper_texture_ready(texture: Texture2D, character, loader: RemoteTextureLoader) -> void:
	character.set_appearance_texture(texture)
	loader.queue_free()
	finished.emit()

func _on_sniper_texture_failed(reason: String, loader: RemoteTextureLoader) -> void:
	push_warning("PrepareGame: %s" % reason)
	loader.queue_free()
	finished.emit()
