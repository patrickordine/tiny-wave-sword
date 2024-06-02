extends Node

@export var speed: float = 100.0
var enemy: Enemy
var sprite_2d: AnimatedSprite2D 


func _ready():
	enemy = get_parent() as Enemy
	sprite_2d = enemy.get_node("AnimatedSprite2D")


func _physics_process(delta: float) -> void:
	if GameManager.is_game_over: return
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	var direction = difference.normalized()


		
	enemy.velocity = direction * speed
	enemy.move_and_slide()

	if direction.x > 0:
		sprite_2d.flip_h = false
	elif direction.x < 0:
		sprite_2d.flip_h = true



