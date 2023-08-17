extends Control

var BLOCK_SCENE = preload("res://scenes/block/block.tscn")

@export var board: Board

var display_block: Block

# Called when the node enters the scene tree for the first time.
func _ready():
	board.current_level_changed.connect(_on_current_level_changed)
	
	display_block = spawn_block(
		Vector2(0, 0), 
		PowerBlockData.new(board.current_level + board.steps_above_minimum_to_advance),
	)
#	reset_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_current_level_changed(new_level: int):
	destroy_block(display_block)
	display_block = spawn_block(
		Vector2(0, 0), 
		PowerBlockData.new(board.current_level + board.steps_above_minimum_to_advance),
	)
#	reset_size()
	
func get_new_block(pos: Vector2, data: BlockData) -> Block:
	var block = BLOCK_SCENE.instantiate()
	block.initialize({
		"position": pos,
		"size": Vector2(board.block_size, board.block_size),
		"scale": Vector2(1, 1),
		"board": board,
		"color": board.get_block_background_color(data),
		"data": data,
	})
	return block
	
func spawn_block(pos: Vector2, data: BlockData) -> Block:
	var block = get_new_block(pos, data)
	add_child(block)
	return block
	
func destroy_block(block: Block):
	remove_child(block)
	block.queue_free()
