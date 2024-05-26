class_name MobSpawner
extends Node2D
@export var creatures: Array[PackedScene]
@onready var pathFollow2d: PathFollow2D = %PathFollow2D
@export var mobs_per_minute: float = 60.0
var cooldown: float = 0.0


func _process(delta: float):
	if GameManager.is_game_over: return
	#temporizador
	cooldown-=delta
	if cooldown> 0: return
	
	#frequencia
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	#instanciar
	var index = randi_range(0,creatures.size()-1)
	var creatures_scene = creatures[index]
	var creature = creatures_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)

func get_point() -> Vector2:
	pathFollow2d.progress_ratio = randf()
	return pathFollow2d.global_position
