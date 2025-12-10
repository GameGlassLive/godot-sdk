extends Node

## GameGlass Analytics SDK for Godot
## Main singleton for tracking game analytics events

signal event_sent(event_type: String, success: bool)
signal batch_sent(events_count: int, success: bool)

const API_BASE_URL = "https://gameglass.live/api/v1"
const BATCH_SIZE = 50
const BATCH_INTERVAL = 60.0  # seconds

var api_key: String = ""
var api_secret: String = ""
var session_id: String = ""
var is_initialized: bool = false
var event_queue: Array = []
var user_properties: Dictionary = {}

var _http_client: HTTPRequest
var _batch_timer: Timer
var _is_requesting: bool = false
var _pending_batch: Array = []

func _ready():
	# Create HTTP client
	_http_client = HTTPRequest.new()
	add_child(_http_client)
	_http_client.request_completed.connect(_on_request_completed)
	
	# Create batch timer
	_batch_timer = Timer.new()
	_batch_timer.wait_time = BATCH_INTERVAL
	_batch_timer.timeout.connect(_flush_queue)
	_batch_timer.autostart = true
	add_child(_batch_timer)

## Initialize the SDK with your API key and secret
## Call this once when your game starts
## Note: You can use just the key for now, but secret will be required in future versions
func initialize(key: String, secret: String = "") -> void:
	if key.is_empty():
		push_error("GameGlass: API key cannot be empty")
		return
	
	api_key = key
	api_secret = secret
	session_id = _generate_session_id()
	is_initialized = true
	
	# Track session start
	track_event("session_start", {
		"session_id": session_id,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	print("GameGlass: Initialized with session ID: ", session_id)

## Track a custom event
## event_type: Name of the event (e.g., "level_complete", "boss_defeated")
## properties: Dictionary of event properties (optional)
func track_event(event_type: String, properties: Dictionary = {}) -> void:
	if not is_initialized:
		push_warning("GameGlass: Not initialized. Call initialize() first.")
		return
	
	if event_type.is_empty():
		push_error("GameGlass: Event type cannot be empty")
		return
	
	var event = {
		"event_type": event_type,
		"session_id": session_id,
		"properties": properties.duplicate(),
		"occurred_at": Time.get_datetime_string_from_system(true, true)
	}
	
	# Add user properties if set
	if not user_properties.is_empty():
		for key in user_properties:
			event.properties[key] = user_properties[key]
	
	event_queue.append(event)
	
	# Flush if queue is full
	if event_queue.size() >= BATCH_SIZE:
		_flush_queue()

## Track Concurrent Users (CCU)
## Call this periodically (e.g., every 60 seconds) with current player count
func track_ccu(count: int) -> void:
	if not is_initialized:
		push_warning("GameGlass: Not initialized. Call initialize() first.")
		return
	
	# If a request is in progress, queue the CCU as an event instead
	if _is_requesting:
		track_event("ccu_update", {"ccu": count})
		return
	
	_is_requesting = true
	
	var url = API_BASE_URL + "/metrics/ccu"
	var headers = [
		"X-API-Key: " + api_key,
		"Content-Type: application/json"
	]
	if not api_secret.is_empty():
		headers.append("X-API-Secret: " + api_secret)
	
	var body = JSON.stringify({
		"ccu": count
	})
	
	var error = _http_client.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		_is_requesting = false
		push_error("GameGlass: Failed to send CCU request: " + str(error))
		# Fallback to event tracking if CCU endpoint fails
		track_event("ccu_update", {"ccu": count})
		_try_send_pending()

## Set a user property that will be included in all events
## key: Property name
## value: Property value (will be converted to string)
func set_user_property(key: String, value) -> void:
	if key.is_empty():
		push_error("GameGlass: User property key cannot be empty")
		return
	
	user_properties[key] = str(value)

## Clear all user properties
func clear_user_properties() -> void:
	user_properties.clear()

## Manually flush the event queue
## Usually called automatically, but you can call this on game exit
func flush() -> void:
	_flush_queue()

## Track session end
## Call this when the game is closing
func track_session_end() -> void:
	if not is_initialized:
		return
	
	track_event("session_end", {
		"session_id": session_id,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	# Flush immediately on session end
	_flush_queue()

func _flush_queue() -> void:
	if event_queue.is_empty():
		return
	
	if not is_initialized:
		return
	
	# Copy queue and clear it
	var events_to_send = event_queue.duplicate()
	event_queue.clear()
	
	# If a request is already in progress, queue this batch
	if _is_requesting:
		_pending_batch.append_array(events_to_send)
		return
	
	# Send batch
	_send_batch(events_to_send)

func _send_batch(events: Array) -> void:
	if events.is_empty():
		return
	
	# If already requesting, queue this batch
	if _is_requesting:
		_pending_batch.append_array(events)
		return
	
	_is_requesting = true
	
	var url = API_BASE_URL + "/events/batch"
	var headers = [
		"X-API-Key: " + api_key,
		"Content-Type: application/json"
	]
	if not api_secret.is_empty():
		headers.append("X-API-Secret: " + api_secret)
	
	var payload = {
		"events": events
	}
	
	var body = JSON.stringify(payload)
	
	var error = _http_client.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		_is_requesting = false
		push_error("GameGlass: Failed to send batch request: " + str(error))
		# Re-add events to queue on failure (with limit to prevent memory issues)
		if event_queue.size() < 1000:
			event_queue.append_array(events)
		# Try to send pending batch if any
		_try_send_pending()

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_requesting = false
	
	if response_code >= 200 and response_code < 300:
		print("GameGlass: Request successful (", response_code, ")")
	else:
		var response_body = body.get_string_from_utf8()
		push_error("GameGlass: Request failed (", response_code, "): ", response_body)
	
	# Try to send any pending batches
	_try_send_pending()

func _try_send_pending() -> void:
	if not _pending_batch.is_empty() and not _is_requesting:
		var batch = _pending_batch.duplicate()
		_pending_batch.clear()
		_send_batch(batch)

func _generate_session_id() -> String:
	# Generate a unique session ID
	var timestamp = str(Time.get_unix_time_from_system())
	var random = str(randi() % 1000000)
	return timestamp + "_" + random

func _exit_tree():
	# Track session end when game closes
	track_session_end()

