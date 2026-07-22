class_name RemoteTextureLoader
extends HTTPRequest

## Responsabilidade unica: baixar uma imagem PNG de uma URL e transforma-la
## em Texture2D. Esta classe nao sabe nada sobre personagens, sprites ou
## bootstrap - ela so sabe baixar uma imagem e avisar quando terminar.
##
## Uso:
##   var loader = RemoteTextureLoader.new()
##   add_child(loader)
##   loader.texture_ready.connect(func(texture): ...)
##   loader.load_failed.connect(func(reason): ...)
##   loader.load_from_url("http://exemplo.com/imagem.png")

signal texture_ready(texture: Texture2D)
signal load_failed(reason: String)

func _ready() -> void:
	request_completed.connect(_on_request_completed)

func load_from_url(url: String) -> void:
	var error := request(url)
	if error != OK:
		load_failed.emit("Nao foi possivel iniciar o download (%s): %s" % [url, error])

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		load_failed.emit("Download falhou (result=%s, http=%s)" % [result, response_code])
		return

	var image := Image.new()
	var error := image.load_png_from_buffer(body)
	if error != OK:
		load_failed.emit("A resposta nao e um PNG valido (erro %s)" % error)
		return

	texture_ready.emit(ImageTexture.create_from_image(image))
