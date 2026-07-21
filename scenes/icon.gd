extends Node2D

@export var velocidade_rotacao: float = 180.0
@export var velocidade_movimento: float = 180.0
@export var graus_acumulados: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#graus_acumulados += velocidade_movimento * delta
	#rotate(deg_to_rad(velocidade_rotacao) * delta)
	#position.x = 200 + (sin(deg_to_rad(graus_acumulados)) * 200)
