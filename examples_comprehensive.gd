## Comprehensive GameGlass SDK Examples for Godot
## This file shows how to track various game scenarios and events

extends Node

# Example: Tracking button clicks
func _on_button_clicked(button_name: String, button_index: int):
	GameGlass.track_event("button_clicked", {
		"button_name": button_name,
		"button_index": button_index,
		"scene": get_tree().current_scene.name
	})

# Example: Tracking scene/level changes
func _on_scene_changed(new_scene_name: String, previous_scene: String):
	GameGlass.track_event("scene_loaded", {
		"scene_name": new_scene_name,
		"previous_scene": previous_scene,
		"load_time": get_load_time()  # Your function to measure load time
	})

# Example: Tracking game state changes
func on_game_start():
	GameGlass.track_event("game_start", {
		"difficulty": current_difficulty,
		"game_mode": current_game_mode
	})

func on_game_pause():
	GameGlass.track_event("game_paused", {
		"pause_time": Time.get_unix_time_from_system(),
		"level": current_level
	})

func on_game_resume():
	GameGlass.track_event("game_resumed", {
		"pause_duration": calculate_pause_duration(),
		"level": current_level
	})

# Example: Tracking win/lose/draw scenarios
func on_player_wins(score: int, time_seconds: float, level: int):
	GameGlass.track_event("player_wins", {
		"score": score,
		"time_seconds": time_seconds,
		"level": level,
		"difficulty": current_difficulty,
		"moves": total_moves,
		"lives_remaining": current_lives
	})

func on_player_loses(score: int, time_seconds: float, level: int, cause: String):
	GameGlass.track_event("player_loses", {
		"score": score,
		"time_seconds": time_seconds,
		"level": level,
		"cause": cause,  # e.g., "timeout", "no_lives", "caught"
		"difficulty": current_difficulty
	})

func on_game_draw():
	GameGlass.track_event("game_draw", {
		"score": current_score,
		"time_seconds": elapsed_time,
		"level": current_level
	})

# Example: Tracking level progression
func on_level_start(level_number: int):
	GameGlass.track_event("level_start", {
		"level": level_number,
		"difficulty": current_difficulty
	})

func on_level_complete(level_number: int, score: int, time_seconds: float, stars: int):
	GameGlass.track_event("level_complete", {
		"level": level_number,
		"score": score,
		"time_seconds": time_seconds,
		"stars": stars,
		"attempts": level_attempts,
		"difficulty": current_difficulty
	})

func on_level_fail(level_number: int, reason: String):
	GameGlass.track_event("level_fail", {
		"level": level_number,
		"reason": reason,  # e.g., "timeout", "died", "quit"
		"attempts": level_attempts,
		"progress": level_progress_percent
	})

# Example: Tracking player actions
func on_player_jump():
	GameGlass.track_event("player_jump", {
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"level": current_level
	})

func on_player_collect_item(item_type: String, item_name: String):
	GameGlass.track_event("item_collected", {
		"item_type": item_type,  # e.g., "coin", "powerup", "key"
		"item_name": item_name,
		"total_collected": items_collected_count,
		"level": current_level
	})

func on_player_death(cause: String, position: Vector2):
	GameGlass.track_event("player_death", {
		"cause": cause,  # e.g., "enemy", "fall", "spike", "timeout"
		"position_x": position.x,
		"position_y": position.y,
		"level": current_level,
		"lives_remaining": current_lives,
		"time_alive": time_since_level_start
	})

# Example: Tracking combat/battle events
func on_enemy_defeated(enemy_type: String, enemy_name: String):
	GameGlass.track_event("enemy_defeated", {
		"enemy_type": enemy_type,
		"enemy_name": enemy_name,
		"level": current_level,
		"weapon_used": current_weapon
	})

func on_boss_defeated(boss_name: String, difficulty: String, time_taken: float):
	GameGlass.track_event("boss_defeated", {
		"boss_name": boss_name,
		"difficulty": difficulty,
		"time_taken": time_taken,
		"level": current_level,
		"damage_taken": total_damage_taken,
		"health_remaining": player_health
	})

# Example: Tracking UI interactions
func on_menu_opened(menu_name: String):
	GameGlass.track_event("menu_opened", {
		"menu_name": menu_name,  # e.g., "settings", "inventory", "pause"
		"scene": get_tree().current_scene.name
	})

func on_settings_changed(setting_name: String, old_value: String, new_value: String):
	GameGlass.track_event("setting_changed", {
		"setting": setting_name,
		"old_value": old_value,
		"new_value": new_value
	})

# Example: Tracking progression/milestones
func on_achievement_unlocked(achievement_id: String, achievement_name: String):
	GameGlass.track_event("achievement_unlocked", {
		"achievement_id": achievement_id,
		"achievement_name": achievement_name,
		"total_achievements": unlocked_achievements_count
	})

func on_player_level_up(new_level: int, experience: int):
	GameGlass.track_event("player_level_up", {
		"new_level": new_level,
		"experience": experience,
		"total_playtime": total_playtime_seconds
	})

# Example: Tracking economy/purchases
func on_item_purchased(item_name: String, price: float, currency: String):
	GameGlass.track_event("purchase", {
		"item": item_name,
		"price": price,
		"currency": currency,
		"balance_after": current_balance,
		"purchase_type": "in_game"  # or "real_money"
	})

func on_currency_earned(amount: int, currency_type: String, source: String):
	GameGlass.track_event("currency_earned", {
		"amount": amount,
		"currency_type": currency_type,  # e.g., "coins", "gems", "gold"
		"source": source,  # e.g., "level_complete", "ad_reward", "purchase"
		"total_balance": current_balance
	})

# Example: Tracking tutorial/onboarding
func on_tutorial_started(tutorial_name: String):
	GameGlass.track_event("tutorial_started", {
		"tutorial_name": tutorial_name,
		"is_first_time": is_first_play
	})

func on_tutorial_completed(tutorial_name: String, time_taken: float):
	GameGlass.track_event("tutorial_completed", {
		"tutorial_name": tutorial_name,
		"time_taken": time_taken,
		"skipped_steps": skipped_tutorial_steps
	})

func on_tutorial_skipped(tutorial_name: String):
	GameGlass.track_event("tutorial_skipped", {
		"tutorial_name": tutorial_name,
		"step_reached": current_tutorial_step
	})

# Example: Tracking errors/crashes
func on_error_occurred(error_type: String, error_message: String, scene: String):
	GameGlass.track_event("error_occurred", {
		"error_type": error_type,  # e.g., "script_error", "null_reference"
		"error_message": error_message,
		"scene": scene,
		"game_version": game_version
	})

# Example: Tracking social/sharing
func on_share_attempted(share_type: String, content: String):
	GameGlass.track_event("share_attempted", {
		"share_type": share_type,  # e.g., "screenshot", "score", "achievement"
		"content": content,
		"platform": get_platform_name()
	})

# Example: Tracking ad interactions (if applicable)
func on_ad_shown(ad_type: String, ad_placement: String):
	GameGlass.track_event("ad_shown", {
		"ad_type": ad_type,  # e.g., "interstitial", "rewarded", "banner"
		"placement": ad_placement,
		"scene": get_tree().current_scene.name
	})

func on_ad_watched(ad_type: String, reward_received: String):
	GameGlass.track_event("ad_watched", {
		"ad_type": ad_type,
		"reward": reward_received,
		"completed": true
	})

# Example: Tracking game-specific mechanics
func on_powerup_used(powerup_name: String, level: int):
	GameGlass.track_event("powerup_used", {
		"powerup": powerup_name,
		"level": level,
		"inventory_count": powerup_inventory_count
	})

func on_weapon_switched(old_weapon: String, new_weapon: String):
	GameGlass.track_event("weapon_switched", {
		"old_weapon": old_weapon,
		"new_weapon": new_weapon,
		"level": current_level
	})

func on_checkpoint_reached(checkpoint_id: String, level: int):
	GameGlass.track_event("checkpoint_reached", {
		"checkpoint_id": checkpoint_id,
		"level": level,
		"time_elapsed": elapsed_time
	})

# Example: Complete initialization with all tracking setup
func _ready():
	# Initialize GameGlass
	GameGlass.initialize("your-api-key-here", "your-api-secret-here")
	
	# Set user properties that will be included in all events
	GameGlass.set_user_property("platform", OS.get_name())
	GameGlass.set_user_property("game_version", "1.0.0")
	GameGlass.set_user_property("device_type", get_device_type())
	
	# Track game start
	on_game_start()
	
	# Set up CCU tracking (if applicable)
	setup_ccu_tracking()
	
	# Connect signals for automatic tracking
	setup_event_connections()

func setup_ccu_tracking():
	# For single-player games, track 1 when game is active
	var ccu_timer = Timer.new()
	ccu_timer.wait_time = 60.0  # Track every 60 seconds
	ccu_timer.timeout.connect(_track_ccu)
	ccu_timer.autostart = true
	add_child(ccu_timer)

func _track_ccu():
	# For single-player: 1 if game is running, 0 if paused/closed
	var active_players = 1 if not is_paused else 0
	GameGlass.track_ccu(active_players)
	
	# For multiplayer: use your actual player count
	# var active_players = get_current_player_count()
	# GameGlass.track_ccu(active_players)

func setup_event_connections():
	# Connect your game's signals to tracking functions
	# Example:
	# button.connect("pressed", _on_button_clicked.bind(button.name, button_index))
	# level_manager.connect("level_complete", on_level_complete)
	# player.connect("died", on_player_death)

func _exit_tree():
	# Track session end when game closes
	GameGlass.track_session_end()

# Helper functions (implement these based on your game)
func get_load_time() -> float:
	# Return scene load time in seconds
	return 0.0

func calculate_pause_duration() -> float:
	# Return how long the game was paused
	return 0.0

func get_device_type() -> String:
	# Return device type (mobile, desktop, etc.)
	return "desktop"

func get_platform_name() -> String:
	# Return platform name
	return OS.get_name()

func get_current_player_count() -> int:
	# Return current number of active players (for multiplayer)
	return 1

