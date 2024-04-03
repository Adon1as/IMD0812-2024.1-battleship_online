extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_side_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_tile_valid(p):
	
	if int(p)%11 < 1:
		print(int(p)%11)
		return false 
		
	if p > 110:
		return false
		
	if get_child(p) == null or get_child(p).status != 0:
		return false
		
	if get_child(p+1) == null or get_child(p+1).status != 0:
		return false
	
	if get_child(p-1) == null or get_child(p-1).status != 0:
		return false
		
	if get_child(p+11) == null or get_child(p+11).status != 0:
		return false
	
	if get_child(p-11) == null or get_child(p-11).status != 0:
		return false
	
	if get_child(p+12) == null or get_child(p+12).status != 0:
		return false
	
	if get_child(p-12) == null or get_child(p-12).status != 0:
		return false
	
	if get_child(p+10) == null or get_child(p+10).status != 0:
		return false
	
	if get_child(p-10) == null or get_child(p-10).status != 0:
		return false

	return true
func is_ship_valid(p, s):
	if int(p+s-1)%11 < 10 and int(p)%11+s > 11:
		return false
	return true

func get_tile_status_list():
	var status_list = []
	for tile in get_children():
		status_list.append(tile.status)
	return status_list
	
	
func set_enemy_grid(status_list):
	var count = 0
	for tile in get_children():
		tile.status = int(status_list[count])
		count += 1

func draw_side_labels():
	for i in range(10):
		get_child((i*10)+i).get_child(0).text = str(i+1)
		get_child(i+111).get_child(0).text = char(65+i)

	
