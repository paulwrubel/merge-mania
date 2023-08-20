extends Node2D

var Block = preload("res://scenes/block/block.tscn")

@export var board: Board

var display_block: Block

# Called when the node enters the scene tree for the first time.
func _ready():
	board.current_level_changed.connect(_on_current_level_changed)
	
	display_block = spawn_block(
		Vector2(0, $GoalLabel.size.y), 
		PowerBlockData.new(board.current_level + board.steps_above_minimum_to_advance),
	)
	
	$GoalLabel.size.x = display_block.size.x * display_block.scale.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_current_level_changed(_new_level: int):
	destroy_block(display_block)
	display_block = spawn_block(
		Vector2(0, $GoalLabel.size.y), 
		PowerBlockData.new(board.current_level + board.steps_above_minimum_to_advance),
	)


func get_new_block(pos: Vector2, data: BlockData) -> Block:
	var block = Block.instantiate()
	block.setup(
		pos,
		Vector2(board.block_size, board.block_size),
		Vector2(1, 1) * 0.8,
		data,
	)
	return block


func spawn_block(pos: Vector2, data: BlockData) -> Block:
	var block = get_new_block(pos, data)
	add_child(block)
	return block


func destroy_block(block: Block):
	remove_child(block)
	block.queue_free()
