extends CharacterBody2D

@export var velocidade_maxima: float = 400.0
@export var aceleracao: float = 300.0
@export var friccao: float = 200.0
@export var velocidade_curva: float = 3.0 # Quão rápido o carro vira
var velocidade_atual: float = 0.0
func _physics_process(delta: float) -> void:
	# 1. PEGAR INPUTS DAS SETAS
	var direcao_rotacao = 0.0
	if Input.is_action_pressed("ui_right"):
		direcao_rotacao += 1.0
	if Input.is_action_pressed("ui_left"):
		direcao_rotacao -= 1.0
		
	var entrada_aceleracao = 0.0
	if Input.is_action_pressed("ui_up"):
		entrada_aceleracao += 1.0
	if Input.is_action_pressed("ui_down"):
		entrada_aceleracao -= 1.0

	# 2. CALCULAR ROTAÇÃO (Só vira se o carro estiver se mexendo)
	if velocidade_atual != 0.0:
		# Inverte a direção da curva se estiver dando ré
		var sinal_re = -1.0 if velocidade_atual < 0.0 else 1.0
		rotation += direcao_rotacao * velocidade_curva * delta * sinal_re

	# 3. CALCULAR ACELERAÇÃO E FRICÇÃO
	if entrada_aceleracao != 0.0:
		velocidade_atual = move_toward(velocidade_atual, entrada_aceleracao * velocidade_maxima, aceleracao * delta)
	else:
		# Se soltar as setas, o carro vai parando sozinho
		velocidade_atual = move_toward(velocidade_atual, 0.0, friccao * delta)

	# 4. APLICAR O MOVIMENTO
	# Criamos um vetor apontando para a frente do carro (baseado na rotação dele)
	var direcao_frente = Vector2.UP.rotated(rotation) # Usa Vector2.RIGHT se o sprite do seu carro estiver apontando para a direita por padrão
	velocity = direcao_frente * velocidade_atual

	move_and_slide()
