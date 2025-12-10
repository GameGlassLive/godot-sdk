## Example: Tic-Tac-Toe Game with GameGlass Analytics
## This is an improved version showing best practices for tracking game events

extends Node2D

# Tiles
const CELL_EMPTY = ""
const CELL_X = "X"
const CELL_O = "O"

@onready var buttons = $GridContainer.get_children()
@onready var label = $Menu/Label
@onready var menu = $Menu

# Game States
var current_player
var board
var turn_count = 0
var game_start_time = 0
var move_history = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize GameGlass
	GameGlass.initialize("your-api-key-here", "your-api-secret-here")
	
	# Set user properties that will be included in all events
	GameGlass.set_user_property("platform", OS.get_name())
	GameGlass.set_user_property("game_version", "1.0.0")
	
	# Track session start (automatic, but you can also track manually)
	GameGlass.track_event("session_start", {
		"game_type": "tic_tac_toe"
	})
	
	# Track CCU (for single-player, this would be 1)
	# Note: CCU tracking is optional for single-player games
	GameGlass.track_ccu(1)
	
	# Don't need to flush immediately - events will be sent automatically
	# GameGlass.flush()  # Only use this if you need immediate sending
	
	label.text = ""
	var button_index = 0
	for button in buttons:
		button.connect("pressed", _on_button_click.bind(button_index, button))
		button_index += 1
	
	reset_game()

func _on_button_click(idx, button):
	# Calculate position
	var _y = idx / 3
	var _x = idx % 3
	
	# Track button click with proper data types
	GameGlass.track_event("button_clicked", {
		"button_index": idx,
		"position_x": _x,
		"position_y": _y,
		"current_player": current_player,
		"turn_number": turn_count + 1,
		"scene": get_tree().current_scene.name
	})
	
	# Check if move is valid (cell is empty)
	if board[_x][_y] != CELL_EMPTY:
		# Track invalid move attempt
		GameGlass.track_event("invalid_move", {
			"position_x": _x,
			"position_y": _y,
			"current_player": current_player,
			"cell_occupied_by": board[_x][_y]
		})
		return
	
	# Make the move
	button.text = current_player
	board[_x][_y] = current_player
	turn_count += 1
	
	# Track the move
	GameGlass.track_event("move_made", {
		"position_x": _x,
		"position_y": _y,
		"player": current_player,
		"turn_number": turn_count
	})
	
	# Add to move history
	move_history.append({
		"turn": turn_count,
		"player": current_player,
		"x": _x,
		"y": _y
	})
	
	# Check win condition
	if check_win():
		var game_duration = Time.get_unix_time_from_system() - game_start_time
		label.text = current_player + " has Won!"
		
		GameGlass.track_event("player_wins", {
			"winner": current_player,
			"turn_count": turn_count,
			"game_duration_seconds": game_duration,
			"moves": move_history.size()
		})
		
		reset_game()
	elif check_fullboard():
		# Draw
		var game_duration = Time.get_unix_time_from_system() - game_start_time
		label.text = "It is a draw!"
		
		GameGlass.track_event("game_draw", {
			"turn_count": turn_count,
			"game_duration_seconds": game_duration,
			"moves": move_history.size()
		})
		
		reset_game()
	else:
		# Switch player
		current_player = CELL_X if current_player == CELL_O else CELL_O
		
		# Track player switch
		GameGlass.track_event("player_switch", {
			"new_player": current_player,
			"turn_number": turn_count + 1
		})

func check_win():
	# Check all horizontal and vertical cells
	for i in range(3):
		# Horizontal check
		if board[i][0] == board[i][1] and board[i][1] == board[i][2] and board[i][2] != CELL_EMPTY:
			return true
		# Vertical check
		if board[0][i] == board[1][i] and board[1][i] == board[2][i] and board[2][i] != CELL_EMPTY:
			return true
	
	# Check diagonals
	if board[0][0] == board[1][1] and board[1][1] == board[2][2] and board[2][2] != CELL_EMPTY:
		return true
	if board[2][0] == board[1][1] and board[1][1] == board[0][2] and board[0][2] != CELL_EMPTY:
		return true
	
	return false

func check_fullboard():
	for row in board:
		for col in row:
			if col == CELL_EMPTY:
				return false
	return true

func reset_game():
	print("Reset Game!")
	
	# Track game reset
	GameGlass.track_event("game_reset", {
		"previous_turn_count": turn_count,
		"previous_moves": move_history.size()
	})
	
	# Reset game state
	current_player = CELL_X
	turn_count = 0
	move_history.clear()
	game_start_time = Time.get_unix_time_from_system()
	
	board = [
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY],
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY],
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY]
	]
	
	# Reset buttons
	for button in buttons:
		button.text = CELL_EMPTY
	
	menu.show()

func _on_button_pressed():
	# Start game
	GameGlass.track_event("game_start", {
		"game_type": "tic_tac_toe",
		"starting_player": CELL_X
	})
	
	game_start_time = Time.get_unix_time_from_system()
	label.text = ""
	menu.hide()

func _exit_tree():
	# Track session end when game closes
	GameGlass.track_session_end()

