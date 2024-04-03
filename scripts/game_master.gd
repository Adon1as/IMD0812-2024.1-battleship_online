extends Node

var player_ships =[3,2,2,1,1]
var ws
var mainLabel
var enemyHP
var playerHP
var shipsUI

var finding_mach = true
var battle_mode = false
var waiting_hit = false

var player_life
var enemy_life


func _ready():

	ws = get_node("WebSocketPeer")
	mainLabel	= get_node("mainLabel")
	enemyHP	= get_node("enemyHP")
	playerHP = get_node("playerHP")
	shipsUI = get_node("ShipsUI")

	mainLabel.get_child(0).text = "Finding mach..."

	var sum = 0
	var count = 1
	for s in player_ships:
		shipsUI.get_child(count-1).text = str(s)
		sum += (s*count)
		count += 1


	player_life = sum
	enemy_life = sum
	enemyHP.text = "HP: " + str(sum)
	playerHP.text = "HP: " + str(sum)

	ws.package_readed.connect(_on_ws_read_packet)
	ws.round_go.connect(_on_ws_round_go)
	ws.round_pause.connect(_on_ws_round_pause)
	ws.battle_start.connect(_on_ws_battle_start)
	ws.enemy_dc.connect(_on_ws_enemy_dc)


func _process(delta):
	pass

func gerar_metadata():
	pass

func gerar_matriz():
	pass

func validar_tile_incert():
	pass

func get_status():
	pass

func load_player2_comand():
	pass

func draw_ship(tile, status):
	if battle_mode:
		return false

	if player_ships[status-1] <= 0:
		return false

	var lp = tile.get_list_position()
	var grid = get_node("Grid1/GridContainer")


	if status > 1 and !grid.is_ship_valid(lp,status):
		return false

	if status == 1:
		if !grid.is_tile_valid(lp):
			return false
		else:
			tile.reload(status)

	if status == 2:
		if !grid.is_tile_valid(lp):
			return false
		elif !grid.is_tile_valid(lp+1):
			return false
		else:
			tile.reload(status)
			grid.get_child(lp+1).reload(status)

	if status == 3:
		if !grid.is_tile_valid(lp):
			return false
		elif !grid.is_tile_valid(lp+2):
			return false
		elif !grid.is_tile_valid(lp-11+1):
			return false
		else:
			tile.reload(status)
			grid.get_child(lp+2).reload(status)
			grid.get_child(lp-11+1).reload(status)

	if status == 4:
		if !grid.is_tile_valid(lp):
			return false
		elif !grid.is_tile_valid(lp+1):
			return false
		elif !grid.is_tile_valid(lp+2):
			return false
		elif !grid.is_tile_valid(lp+3):
			return false
		else:
			tile.reload(status)
			grid.get_child(lp+1).reload(status)
			grid.get_child(lp+2).reload(status)
			grid.get_child(lp+3).reload(status)

	if status == 5:
		if !grid.is_tile_valid(lp):
			return false
		elif !grid.is_tile_valid(lp+1):
			return false
		elif !grid.is_tile_valid(lp+2):
			return false
		elif !grid.is_tile_valid(lp+3):
			return false
		elif !grid.is_tile_valid(lp+4):
			return false
		else:
			tile.reload(status)
			grid.get_child(lp+1).reload(status)
			grid.get_child(lp+2).reload(status)
			grid.get_child(lp+3).reload(status)
			grid.get_child(lp+4).reload(status)

	#player_ships[status-1] -= 1
	updateShipList(status,-1)

func trade_hit(tile):
	if waiting_hit:
		return false

	if !battle_mode:
		return false

	if (ws.send_hit(tile.name)):
		waiting_hit = true
		print("trade_hit "+tile.name)
		ws.get_hit()
		return true

func draw_hit(tile,p):
	if battle_mode:
		if tile.status == 0:
			tile.get_child(0).text="X"
			tile.reload(6)
		elif 1 <= tile.status && tile.status <= 5:
			tile.get_child(0).text="O"
			tile.reload(7)
			if p:
				take_damege()
			else:
				deal_damege()


func _on_reset_pressed():
	player_ships =[3,2,2,1,1]
	var count = 0
	for s in player_ships:
		shipsUI.get_child(count).text = str(s)
		count +=1
	get_child(0).reset_grid()


func _on_start_pressed():
	for s in player_ships:
		if s != 0:
			return false

	battle_mode = true
	var status_list = get_child(0).get_child(0).get_tile_status_list()
	mainLabel.visible = true
	mainLabel.get_child(0).text = "Waiting..."
	if ws.send_status_list(status_list):
		ws.get_enemy_status_list()
		

func _on_ws_read_packet():
	print(ws.gameData["subject"])
	if(ws.gameData["subject"]=="hit"):
		draw_hit(get_node("Grid1/GridContainer/"+ws.gameData["data"]),true)
	elif(ws.gameData["type"]=="update"):
		pass
	elif(ws.gameData["subject"]=="grid"):
		mainLabel.visible = false
		get_node("Grid2").get_child(0).set_enemy_grid(ws.gameData["data"])

func _on_ws_round_go():
	waiting_hit = false

func _on_ws_round_pause():
	waiting_hit = true

func _on_ws_battle_start():
	print("_on_ws_battle_start")
	finding_mach = false
	mainLabel.visible = false

func take_damege():
	player_life -=1
	playerHP.text = "HP: " + str(player_life)

	if player_life==0:
		to_lose()

func deal_damege():
	enemy_life -=1
	enemyHP.text = "HP: " + str(enemy_life)

	if enemy_life ==0:
		to_win()

func updateShipList(s,i):
	player_ships[s-1] += i
	shipsUI.get_child(s-1).text = str(player_ships[s-1])

func _on_ws_enemy_dc():
	to_win()

func to_win():
	mainLabel.visible = true
	mainLabel.get_child(0).text = "WON!"
	ws.to_close()


func to_lose():
	mainLabel.visible = true
	mainLabel.get_child(0).text = "LOST!"
	ws.to_close()


