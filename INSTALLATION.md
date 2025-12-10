# GameGlass SDK for Godot - Installation Guide

## Quick Installation (5 minutes)

### Step 1: Download the SDK

1. Download `GameGlass.gd` from this repository
2. Or clone the entire repository:
   ```bash
   git clone https://github.com/GameGlassLive/godot-sdk.git
   ```

### Step 2: Add to Your Godot Project

**Option A: Manual Installation (Recommended for beginners)**

1. Copy `GameGlass.gd` to your Godot project folder (e.g., `res://scripts/` or `res://addons/gameglass/`)
2. Open your Godot project
3. Go to **Project → Project Settings → Autoload**
4. Click the folder icon next to "Path" and select `GameGlass.gd`
5. Set the **Node Name** to: `GameGlass`
6. Check the **Singleton** checkbox
7. Click **Add**

**Note:** The SDK is designed to be used as an autoload singleton, not as a plugin. This is the recommended and most reliable method.

### Step 3: Get Your API Key and Secret

1. Sign up at [gameglass.live](https://gameglass.live) (if you haven't already)
2. Log in to your dashboard
3. Create a new game (or select an existing one)
4. Go to **API Keys** section
5. Click **Generate New API Key**
6. **Important:** Copy both the API key AND the API secret immediately - you won't be able to see the secret again!

### Step 4: Initialize in Your Game

In your main game script (usually your main scene's `_ready()` function):

```gdscript
func _ready():
    # Replace with your actual API key and secret from the dashboard
    GameGlass.initialize("your-api-key-here", "your-api-secret-here")
```

**Note:** The API secret is required for authentication. Make sure to copy both values when creating your API key.

That's it! The SDK is now ready to use.

## Testing the Installation

Add this to test that everything works:

```gdscript
func _ready():
    GameGlass.initialize("your-api-key-here", "your-api-secret-here")
    
    # Test event - this should appear in your dashboard
    GameGlass.track_event("test_event", {
        "message": "SDK is working!"
    })
    # Manually flush to send immediately (for testing)
	GameGlass.flush()
```

Then check your GameGlass dashboard - you should see the test event appear within a few seconds.

## Next Steps

- Read the [README.md](README.md) for full API documentation
- Check [example_usage.gd](example_usage.gd) for code examples
- Visit [gameglass.live/docs](https://gameglass.live/docs) for more guides

## Troubleshooting

### "GameGlass: Not initialized" warning

- Make sure you've added `GameGlass.gd` as an autoload singleton
- Verify the Node Name is exactly `GameGlass` (case-sensitive)
- Check that you've called `GameGlass.initialize()` before tracking events

### Events not appearing in dashboard

- Verify your API key and secret are correct
- Check that your game is created in the dashboard
- Look for error messages in the Godot console
- Ensure you have an internet connection
- Make sure you're passing both the API key and secret to `initialize()`

### Can't find GameGlass in autoload

- Make sure the file path is correct
- Try using an absolute path: `res://scripts/GameGlass.gd`
- Restart Godot after adding the autoload

## Support

Need help? 
- 📧 [Contact Support](https://gameglass.live/contact)
- 📚 [Documentation](https://gameglass.live/docs)
- 💬 [Forum](https://gameglass.live/forum)

