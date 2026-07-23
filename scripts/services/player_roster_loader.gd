class_name PlayerRosterLoader
extends HTTPRequest

## Responsabilidade unica: baixar players.json de uma URL e transformar cada
## entrada em um PlayerData. Nao sabe nada sobre Character, cena ou grid -
## so baixa e faz o parse do JSON.
##
## Uso:
##   var loader = PlayerRosterLoader.new()
##   add_child(loader)
##   loader.roster_ready.connect(func(players): ...)
##   loader.load_failed.connect(func(reason): ...)
##   loader.load_from_url("http://127.0.0.1:8081/players.json")

signal roster_ready(players: Array[PlayerData])
signal load_failed(reason: String)

var _team: PlayerData.Team = PlayerData.Team.ALLY

func _ready() -> void:
	request_completed.connect(_on_request_completed)

## "team" marca se as entradas baixadas sao aliados (players.json) ou
## inimigos (enemies.json) - o JSON em si nao carrega essa informacao,
## quem sabe e quem escolheu a URL.
func load_from_url(url: String, team: PlayerData.Team = PlayerData.Team.ALLY) -> void:
	_team = team
	var error := request(url)
	if error != OK:
		load_failed.emit("Nao foi possivel iniciar o download (%s): %s" % [url, error])

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		load_failed.emit("Download falhou (result=%s, http=%s)" % [result, response_code])
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_ARRAY:
		load_failed.emit("Resposta do roster nao e uma lista valida")
		return

	var players: Array[PlayerData] = []
	for entry in parsed:
		if typeof(entry) == TYPE_DICTIONARY:
			players.append(PlayerData.from_dict(entry, _team))

	roster_ready.emit(players)
