extends Control
var rGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	rGrid = get_child(0).duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_grid():
	get_child(0).queue_free()
	remove_child(get_child(0))
	add_child(rGrid.duplicate())
	

		
