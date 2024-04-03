extends Node

var socket = WebSocketPeer.new()
var gameData = null

signal package_readed
signal round_go
signal round_pause
signal battle_start
signal enemy_dc

func _ready():
	socket.connect_to_url("ws://localhost:8080")

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			await read_packet()
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.


func send_status_list(text):
	var json = json_generatior("send","start",text)
	socket.send_text(json)
	return true
func get_enemy_status_list():
	var json = json_generatior("request","enemy_list")
	socket.send_text(json)

func send_hit(text):
	var json = json_generatior("send","hit",text)
	socket.send_text(json)
	return true
func get_hit():
	var json = json_generatior("request","hit")
	print(json)
	socket.send_text(json)

func read_packet() :
	var data_to_send = socket.get_packet().get_string_from_utf8()
	var json_string = JSON.stringify(data_to_send)
	# Save data
	# ...
	# Retrieve data
	var json = JSON.new()
	var error = json.parse(data_to_send)
	if error == OK:
		var data_received = json.data

		if typeof(data_received) == TYPE_DICTIONARY:
			gameData = data_received
			emit_signal("package_readed")
			print(data_received)
			match data_received["round_status"]:
				"pause":
					emit_signal("round_pause")
				"on":
					emit_signal("round_go")
				"start":
					emit_signal("battle_start")
				"dc":
					emit_signal("enemy_dc")

			return true # Prints array
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	return false

func json_generatior(type,subject, data='', round_status = ''):
	var dictionary = {
		"type":type,
		"round_status":round_status,
		"subject":subject,
		"data":data
	}
	return JSON.stringify(dictionary)

func to_close():
	await get_tree().create_timer(10.0).timeout
	socket.close()
