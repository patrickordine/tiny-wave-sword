class_name GameOverUI
extends CanvasLayer

@onready var time_label:Label = %TimeLabel
@onready var monster_label:Label = %MonsterLabel
@onready var gold_label:Label = %GoldLabel

@export var restart_delay: float = 5.0
var restart_cooldown: float

func _ready():
	time_label.text = GameManager.gameTime_string
	monster_label.text = str(GameManager.player_score)
	gold_label.text = str(GameManager.gold_counter)
	restart_cooldown = restart_delay
func _process(delta):
	restart_cooldown -= delta
	if(restart_cooldown <=0):
		restart_game()
func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	print("Restart game Please!")
