## Example: How to use GameGlass SDK in your Godot game
## This is a reference example - adapt it to your game's structure
## For more comprehensive examples, see examples_comprehensive.gd

extends Node

func _ready():
	# 1. Initialize GameGlass (do this once when your game starts)
	# Replace with your actual API key and secret from the dashboard
	# Important: Copy both values when creating your API key - you won't see the secret again!
	GameGlass.initialize("your-api-key-here", "your-api-secret-here")
	
	# 2. Set user properties that will be included in all events
	GameGlass.set_user_property("platform", OS.get_name())
	GameGlass.set_user_property("game_version", "1.0.0")
	GameGlass.set_user_property("player_id", "player_12345")  # Optional: if you have player IDs
	
	# 3. Track session start
	GameGlass.track_event("session_start")
	
	# 4. Set up CCU tracking (if you have multiplayer or want to track concurrent users)
	var ccu_timer = Timer.new()
	ccu_timer.wait_time = 60.0  # Send CCU every 60 seconds
	ccu_timer.timeout.connect(_on_ccu_timer)
	ccu_timer.autostart = true
	add_child(ccu_timer)

# Example: Track when a player completes a level
func on_level_complete(level_number: int, score: int, time_seconds: float):
	GameGlass.track_event("level_complete", {
		"level": level_number,
		"score": score,
		"time_seconds": time_seconds
	})

# Example: Track when a player defeats a boss
func on_boss_defeated(boss_name: String, difficulty: String, time_taken: float):
	GameGlass.track_event("boss_defeated", {
		"boss_name": boss_name,
		"difficulty": difficulty,
		"time_taken": time_taken
	})

# Example: Track when a player makes a purchase
func on_purchase(item_name: String, price: float, currency: String = "USD"):
	GameGlass.track_event("purchase", {
		"item": item_name,
		"price": price,
		"currency": currency
	})

# Example: Track when a player unlocks an achievement
func on_achievement_unlocked(achievement_id: String, achievement_name: String):
	GameGlass.track_event("achievement_unlocked", {
		"achievement_id": achievement_id,
		"achievement_name": achievement_name
	})

# Example: Track when a player dies
func on_player_death(level: int, cause: String):
	GameGlass.track_event("player_death", {
		"level": level,
		"cause": cause
	})

# Example: Track when a player collects an item
func on_item_collected(item_name: String, item_type: String):
	GameGlass.track_event("item_collected", {
		"item": item_name,
		"type": item_type
	})

# CCU tracking function (call this periodically)
func _on_ccu_timer():
	# Replace this with your actual player count logic
	var current_players = get_current_player_count()  # Your function here
	GameGlass.track_ccu(current_players)

# Helper function - replace with your actual logic
func get_current_player_count() -> int:
	# Example: If you have a multiplayer system, return the current player count
	# For single-player games, you might track 1 if the game is running
	return 1  # Replace with actual logic

# Clean up on exit
func _exit_tree():
	# Track session end when game closes
	GameGlass.track_session_end()

