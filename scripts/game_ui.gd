extends CanvasLayer
@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel
@onready var kill_label: Label = %KillsLabel
@onready var gold_label:Label = %GoldLabel
@onready var enemy: Enemy


	
func _process(delta: float):
	timer_label.text = GameManager.gameTime_string
	meat_label.text = str(GameManager.meat_counter)
	kill_label.text = str(GameManager.player_score)
	gold_label.text = str(GameManager.gold_counter)

