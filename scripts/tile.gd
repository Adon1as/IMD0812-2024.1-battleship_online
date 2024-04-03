extends ColorRect
var status = 0
var node:Node
var wait_key = false

var status_color = {
	0: "white",
	1: "darkGreen",
	2: "orange",
	3: "blue",
	4: "red",
	5: "gold",
	6: "gray",
	7: "black"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#var node = get_parent().get_parent().get_parent();
	node = find_parent("GameMaster")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if wait_key:
		if event is InputEventKey:
			if event.pressed and 1 <= event.keycode-48 and event.keycode-48 <= 5:
				node.draw_ship(self, event.keycode-48)
			wait_key = false

func _on_button_pressed():
	if get_parent().get_parent().name == "Grid1":
		z_index = 1
		wait_key = true
	elif(!node.waiting_hit):
		node.draw_hit(self,false)
		node.trade_hit(self)
	

func _on_button_focus_exited():
	z_index = 0
	wait_key = false

func get_list_position():
	var vet2 = position/25 + Vector2(1,1)
	var prod = vet2.x + vet2.y * 11
	return prod - 12
	
func reload(s):
	status = s
	color = status_color.get(s)
	
