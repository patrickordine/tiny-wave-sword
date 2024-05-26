extends Node

signal game_over
var player: Player
var player_position: Vector2
var player_score: int = 0
var is_game_over: bool = false

var gameTime: float = 0.0
var gameTime_string: String
var meat_counter: int = 0
var gold_counter: int = 0

func _process(delta: float):
	gameTime += delta
	var gameTime_seconds : int = floori(gameTime)
	var seconds: int = gameTime_seconds % 60
	var minutes: int = gameTime_seconds / 60
	gameTime_string = "%02d:%02d" %[minutes, seconds]

	
func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()
	
func reset():
	player = null
	
	is_game_over = false
	
	gameTime = 0.0
	gameTime_string = "0:00"
	meat_counter = 0
	gold_counter = 0
	player_score = 0
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
