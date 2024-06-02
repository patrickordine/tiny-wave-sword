class_name Player
extends CharacterBody2D

@onready var dust: GPUParticles2D = get_node("Dust")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d = %Sprite2D
@onready var sword_area:Area2D = $SwordArea
@onready var hitbox_area:Area2D = $HitBoxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

@export_category("Status Player")
@export var speed = 300.0
@export var swordDamage: int = 2
#@export var health: int = 100
#@export var max_health: int = 100
@export_range(0,1) var slide_factor = 0.5
@export_category("Ritual")
@export var ritual_damage: int= 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Prefabs")
@export var death_prefab: PackedScene
var direction: Vector2 = Vector2(0, 0)
var is_attacking: bool = false
var is_running: bool = false
var was_running: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
var dash_cooldown:float = 0.0

signal meat_collected(value:int)
signal gold_collected(value:int)

func  _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int): GameManager.meat_counter+=1)

func _process(delta: float)-> void:
	GameManager.player_position = position
	read_input()
	update_attack_cooldown(delta)
	playerActions()
	play_run_idle_animation()
	if not is_attacking:
		flipH()
	update_hitbox_detection(delta)
	
	update_ritual(delta)
	if(dash_cooldown > 0):
		dash_cooldown -= delta
	health_progress_bar.max_value = GameManager.max_health
	health_progress_bar.value = GameManager.health

func playerActions()->void:
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("dash"):
		dash()

func _physics_process(delta: float)-> void:
	var target_diretion = direction * speed
	if (is_attacking):
		target_diretion *= 0.25
		dust.emitting = false
	velocity = lerp(velocity, target_diretion, slide_factor)
	move_and_slide()
	
func play_run_idle_animation()->void:
	if not is_attacking:
		if(was_running !=is_running):
			if(is_running):
				animation_player.play("run")
				dust.emitting = true
			else:
				animation_player.play("idle")
				dust.emitting = false

func update_attack_cooldown(delta: float)-> void:
	if (is_attacking):
		attack_cooldown -= delta
		if(attack_cooldown <=0.0):
			is_attacking = false
			is_running = false

func read_input()->void:
	direction = Input.get_vector("ui_left", "ui_right","ui_up", "ui_down")
	was_running = is_running
	is_running = not direction.is_zero_approx()
	
func attack() -> void:
	if is_attacking:
		return
	animation_player.play("attack_side_1")
	attack_cooldown = 0.6
	is_attacking = true
	
func dash() -> void:
	if dash_cooldown <= 0:
		var modulate_alpha = modulate
		modulate_alpha.a = 0.1
		modulate = modulate_alpha

		var tween_alpha = create_tween()
		tween_alpha.set_ease(Tween.EASE_IN)
		tween_alpha.set_trans(Tween.TRANS_QUINT)
		tween_alpha.tween_property(self, "modulate", Color.WHITE, 0.3)

		direction *= 20
		dash_cooldown = 1.0  # Defina o cooldown em segundos, ajuste conforme necessário
		
func update_dash_cooldown(delta: float) ->void:
	dash_cooldown-=delta
	
func deal_damage_to_enemies()-> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var enemy_direction = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if(sprite_2d.flip_h):
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = enemy_direction.dot(attack_direction)

			if(dot_product >=0.3):
				enemy.damage(swordDamage)
	#Chama a funcção damage

func flipH() -> void:
	if(direction.x > 0):
		sprite_2d.flip_h = false
	elif(direction.x < 0):
		sprite_2d.flip_h = true

func damage(amount: int)-> void:
	if GameManager.health<=0: return
	GameManager.health -= amount
	print("Damage: ", amount, " Health: ", GameManager.health)
	#HIT COLOR
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	if (GameManager.health <= 0):
		die()

func die()-> void:
	GameManager.end_game()
	if(death_prefab):
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()

func update_hitbox_detection(delta: float) ->void:
	#temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown >0: return
	#frequencia
	hitbox_cooldown = 0.5
	
	#hitboxarea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func heal(amount: int) ->int:
	GameManager.health += amount
	if GameManager.health > GameManager.max_health:
		GameManager.health = GameManager.max_health
	return GameManager.health

func update_ritual(delta: float)-> void:
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
