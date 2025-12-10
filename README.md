# GameGlass SDK for Godot

Analytics SDK for integrating GameGlass into your Godot game. Track events, monitor concurrent users, and display real-time metrics on your office dashboard.

## Installation

### Recommended: Autoload Singleton

1. Copy the `GameGlass.gd` file to your Godot project (e.g., `res://scripts/GameGlass.gd`)
2. In Godot, go to **Project → Project Settings → Autoload**
3. Click the folder icon next to "Path" and select `GameGlass.gd`
4. Set the **Node Name** to: `GameGlass` (must match exactly, case-sensitive)
5. Check the **Singleton** checkbox
6. Click **Add**

That's it! The SDK is now available globally as `GameGlass` throughout your project.

## Quick Start

### 1. Get Your API Key and Secret

1. Sign up at [gameglass.live](https://gameglass.live)
2. Create a game in your dashboard
3. Generate an API key
4. **Important:** Copy both the API key AND the API secret immediately - you won't be able to see the secret again!

### 2. Initialize the SDK

In your game's main scene or initialization script:

```gdscript
# In _ready() or game initialization
# You need both the API key and secret from your dashboard
func _ready():
    GameGlass.initialize("your-api-key-here", "your-api-secret-here")
```

### 3. Track Events

```gdscript
# Track a level completion
GameGlass.track_event("level_complete", {
    "level": 5,
    "score": 1250,
    "time_seconds": 180
})

# Track a boss defeat
GameGlass.track_event("boss_defeated", {
    "boss_name": "Dragon King",
    "difficulty": "hard",
    "time_taken": 245
})

# Track a purchase
GameGlass.track_event("purchase", {
    "item": "sword_upgrade",
    "price": 9.99,
    "currency": "USD"
})
```

### 4. Track Concurrent Users (CCU)

Call this periodically (e.g., every 60 seconds) with your current player count:

```gdscript
# In a timer or update function
func _on_ccu_timer_timeout():
    var current_players = get_current_player_count()  # Your logic here
    GameGlass.track_ccu(current_players)
```

### 5. Set User Properties

Set properties that will be included in all events:

```gdscript
GameGlass.set_user_property("country", "US")
GameGlass.set_user_property("platform", "Windows")
GameGlass.set_user_property("game_version", "1.2.3")
```

## API Reference

### `initialize(key: String, secret: String = "")`

Initialize the SDK with your API key and secret. Call this once when your game starts.

**Parameters:**
- `key`: Your GameGlass API key
- `secret`: Your GameGlass API secret (optional for now, but recommended)

**Example:**
```gdscript
GameGlass.initialize("gg_live_abc123xyz", "your-secret-here")
```

### `track_event(event_type: String, properties: Dictionary = {})`

Track a custom event.

**Parameters:**
- `event_type`: Name of the event (e.g., "level_complete", "boss_defeated")
- `properties`: Dictionary of event properties (optional)

**Example:**
```gdscript
GameGlass.track_event("player_level_up", {
    "level": 10,
    "experience": 5000
})
```

### `track_ccu(count: int)`

Track Concurrent Users (CCU). Call this periodically with your current player count.

**Parameters:**
- `count`: Current number of concurrent players

**Example:**
```gdscript
GameGlass.track_ccu(1250)
```

### `set_user_property(key: String, value)`

Set a user property that will be included in all subsequent events.

**Parameters:**
- `key`: Property name
- `value`: Property value (will be converted to string)

**Example:**
```gdscript
GameGlass.set_user_property("player_id", "player_12345")
```

### `clear_user_properties()`

Clear all user properties.

**Example:**
```gdscript
GameGlass.clear_user_properties()
```

### `flush()`

Manually flush the event queue. Usually called automatically, but you can call this on game exit.

**Example:**
```gdscript
GameGlass.flush()
```

## Event Batching

The SDK automatically batches events for efficiency:
- Events are collected in memory
- Sent every 60 seconds OR when 50 events accumulate
- Sent immediately on session end
- Failed requests are retried (events re-added to queue)

## Common Event Types

Here are some common event types you might want to track:

- `session_start` - When a player starts a session
- `session_end` - When a player ends a session
- `level_start` - When a player starts a level
- `level_complete` - When a player completes a level
- `level_fail` - When a player fails a level
- `boss_defeated` - When a player defeats a boss
- `purchase` - When a player makes a purchase
- `achievement_unlocked` - When a player unlocks an achievement
- `player_death` - When a player dies
- `item_collected` - When a player collects an item

## Example Integration

Here's a complete example of integrating GameGlass into a Godot game:

```gdscript
extends Node

func _ready():
    # Initialize GameGlass with both API key and secret
    GameGlass.initialize("your-api-key-here", "your-api-secret-here")
    
    # Set user properties
    GameGlass.set_user_property("platform", OS.get_name())
    GameGlass.set_user_property("game_version", "1.0.0")
    
    # Track session start
    GameGlass.track_event("session_start")
    
    # Set up CCU tracking timer
    var ccu_timer = Timer.new()
    ccu_timer.wait_time = 60.0
    ccu_timer.timeout.connect(_on_ccu_timer)
    ccu_timer.autostart = true
    add_child(ccu_timer)

func _on_level_complete(level: int, score: int, time: float):
    GameGlass.track_event("level_complete", {
        "level": level,
        "score": score,
        "time_seconds": time
    })

func _on_boss_defeated(boss_name: String, difficulty: String):
    GameGlass.track_event("boss_defeated", {
        "boss_name": boss_name,
        "difficulty": difficulty
    })

func _on_ccu_timer():
    var current_players = get_current_player_count()
    GameGlass.track_ccu(current_players)

func _exit_tree():
    # Track session end when game closes
    GameGlass.track_session_end()
```

## Common Game Scenarios

For comprehensive examples of tracking different game scenarios, see [examples_comprehensive.gd](examples_comprehensive.gd) which includes examples for:

- **Button clicks and UI interactions** - Track button presses, menu opens, settings changes
- **Scene/level loading** - Track when scenes or levels are loaded
- **Win/lose/draw scenarios** - Track game outcomes with detailed context
- **Player actions** - Track jumps, item collection, deaths, position data
- **Combat events** - Track enemy defeats, boss battles, weapon switches
- **Progression** - Track level ups, achievements, milestones, checkpoints
- **Economy** - Track purchases, currency earned, in-game transactions
- **Tutorial/onboarding** - Track tutorial progress and completion
- **Errors and crashes** - Track errors for debugging
- **Social features** - Track sharing, ad interactions

Here are some quick examples:

### Button Clicks
```gdscript
func _on_button_clicked(button_name: String, button_index: int):
    GameGlass.track_event("button_clicked", {
        "button_name": button_name,
        "button_index": button_index,
        "scene": get_tree().current_scene.name
    })
```

### Scene/Level Loading
```gdscript
func _on_scene_changed(new_scene_name: String):
    GameGlass.track_event("scene_loaded", {
        "scene_name": new_scene_name,
        "previous_scene": previous_scene_name
    })
```

### Win/Lose/Draw
```gdscript
func on_player_wins(score: int, time_seconds: float, level: int):
    GameGlass.track_event("player_wins", {
        "score": score,
        "time_seconds": time_seconds,
        "level": level
    })

func on_player_loses(score: int, level: int, cause: String):
    GameGlass.track_event("player_loses", {
        "score": score,
        "level": level,
        "cause": cause  # e.g., "timeout", "no_lives", "caught"
    })

func on_game_draw():
    GameGlass.track_event("game_draw", {
        "score": current_score,
        "time_seconds": elapsed_time
    })
```

## Troubleshooting

### Events not appearing in dashboard

1. Check that your API key is correct
2. Verify your game is created in the dashboard
3. Check the Godot console for error messages
4. Ensure you have an internet connection

### Performance concerns

The SDK is designed to be lightweight:
- Events are batched automatically
- Network requests are asynchronous
- Failed requests don't block your game

### Debug mode

Check the Godot console for GameGlass messages. Successful requests will show:
```
GameGlass: Request successful (201)
```

Failed requests will show error messages with details.

## Support

- 📧 [Contact Support](https://gameglass.live/contact)
- 📚 [Documentation](https://gameglass.live/docs)
- 💬 [Forum](https://gameglass.live/forum)

## License

MIT License - See LICENSE file for details

