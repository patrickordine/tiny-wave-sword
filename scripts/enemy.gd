class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene
@onready var damage_digit_marker = $DamageDigitMarker

@export var drop_chance: float = 0.1
@export var drop_itens:Array[PackedScene]
@export var drop_chances:Array[float]
var score: int = 1

func _ready():
	damage_digit_prefab= preload("res://misc/damage_digit.tscn")
	

func damage(amount: int)-> void:
	health -= amount
	print("Damage: ", amount, " Health: ", health)
	#HIT COLOR
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#DamageDigit
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	#Se o Marker existir, posisiona no marker, se não posiciona no "pé" do inimigo
	if(damage_digit_marker):
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	if (health <= 0):
		die()

func die()-> void:
	if(death_prefab):
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
		
	if(randf()<=drop_chance):
		drop_item()
		
	GameManager.player_score +=1
	queue_free()


	
func get_random_drop_item() -> PackedScene:
	# Verifica se drop_itens não está vazio
	if drop_itens.size() == 0:
		# Retorna nulo ou faz algo apropriado se a lista estiver vazia
		return null
	
	# Se houver apenas 1 item, retorne-o diretamente
	if drop_itens.size() == 1:
		return drop_itens[0]
	
	# Calcula a chance máxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	# Gera um valor aleatório dentro da faixa de chances
	var random_value = randf() * max_chance
	
	# Gira a roleta para escolher um item
	var needle: float = 0.0
	for i in range(drop_itens.size()):
		var drop_item = drop_itens[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	# Retorna o primeiro item por padrão (caso algo dê errado)
	return drop_itens[0]


func drop_item() -> void:
	var drop_scene = get_random_drop_item()
	if drop_scene != null:
		var drop = drop_scene.instantiate()
		drop.position = position
		get_parent().add_child(drop)
	else:
		print("No item to drop")
