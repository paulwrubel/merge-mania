extends Node2D

var BLOCK_SCENE = preload("res://scenes/block/block.tscn")

@export var board: Board

var block_progression: Array[Block]

var block_size := 100
var padding := 5

var slide_blocks_animation_tween_settings = TweenSettings.new(
	0.3,
	Tween.EASE_OUT,
	Tween.TRANS_EXPO,
)

# Called when the node enters the scene tree for the first time.
func _ready():
	board.block_progression_advanced.connect(_on_block_progression_advanced)
	board.block_progression_refreshed.connect(_on_block_progression_refreshed)
	
	build_initial_block_progression(board.block_progression.duplicate())
		
	var window_width = get_window().content_scale_size.x
	position = Vector2(
		window_width - (padding * 3 + board.block_size * 1.8),
		0
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_block_progression_advanced(new_block_progression_data: Array[BlockData]):
	# add the newly generated block to the end of our array
	# note: we haven't yet remove the placed block, so we are 
	# oversized after this, which is intentional
	block_progression.append(spawn_block(block_progression.size(), new_block_progression_data[-1]))
	# animate all blocks expect the first, since it was placed
	var subjects: Array[AnimationSubject] = []
	for i in range(1, block_progression.size()):
		var block = block_progression[i]
		subjects.append(AnimationSubject.new(
			block,
			"position",
			get_actual_position_from_index(i - 1),
		))
		# if we are the second block, we additionally need
		# to grow slightly in size
		if i == 1:
			subjects.append_array([
				AnimationSubject.new(
					block,
					"scale",
					Vector2(1, 1),
				),
			])
	board.animate_blocks(subjects, slide_blocks_animation_tween_settings)
	
	
	# finally, get rid of the first block
	destroy_block(block_progression[0])
	block_progression.remove_at(0)
	
	
func _on_block_progression_refreshed(new_block_progression: Array[BlockData]):
	for block in block_progression:
		destroy_block(block)
	build_initial_block_progression(new_block_progression.duplicate())
	
func build_initial_block_progression(block_progression_data: Array[BlockData]):
	block_progression = []
	for i in range(block_progression_data.size()):
		var data = block_progression_data[i]
		block_progression.append(spawn_block(i, data))
	
func get_new_block(index: int, data: BlockData) -> Block:
	var block = BLOCK_SCENE.instantiate()
	var scale = Vector2(1, 1)
	if index > 0:
		scale *= 0.8
	block.initialize({
		"position": get_actual_position_from_index(index),
		"size": Vector2(board.block_size, board.block_size),
		"scale": scale,
		"board": board,
		"color": board.get_block_background_color(data),
		"data": data,
	})
	return block
	
func spawn_block(index: int, data: BlockData) -> Block:
	var block = get_new_block(index, data)
	add_child(block)
	return block
	
func destroy_block(block: Block):
	remove_child(block)
	block.queue_free()
	
func get_actual_position_from_index(index: int) -> Vector2:
	return Vector2(
		(padding * (index + 1)) + (min(index, 1) * board.block_size) + (max(index - 1, 0) * board.block_size * 0.8),
		padding
	)
