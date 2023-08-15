class_name Board
extends Node2D

const COLUMN_SCENE := preload("res://Scenes/column.tscn")
const BLOCK_SCENE := preload("res://Scenes/block.tscn")
#const ANIMATED_SCENE := preload("res://Scenes/animated.tscn")

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

const column_count: int = 5
const row_count: int = 6

const pre_block_size := 100
const pre_padding := 5
const pre_rounding_radius := 5
const pre_width := (pre_block_size * column_count) + (pre_padding * (column_count + 1))
const pre_height := (pre_block_size * row_count) + (pre_padding * (row_count + 1))

var block_symbols: PackedStringArray

var scalar := viewport_width / pre_width

var block_size := pre_block_size * scalar
var padding := pre_padding * scalar
var width := pre_width * scalar
var height := pre_height * scalar

var color_progression: Array[Color] = [
#	Color.html("#DDDDDD"),
#	Color.html("#222222"),
	# end test
	Color.html("#BAFF29"),
	Color.html("#D90DA3"),
	Color.html("#34E4EA"),
	Color.html("#625AFF"),
	Color.html("#D68FD6"),
	Color.html("#CBC0AD"),
	Color.html("#FE5F55"),
	Color.html("#279AF1"),
	Color.html("#FFDD78"),
	Color.html("#B118C8"),
]

const steps_above_minimum_to_advance := 9
const steps_above_minimum_to_drop := 4

var anim_lock := false
var current_level := 1608
var block_progression: Array[BlockData] = [PowerBlockData.new(0), PowerBlockData.new(0)]

var blocks: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize blocks grid
	for x in range(column_count):
		var col = []
		for y in range(row_count):
			col.append(null)
		blocks.append(col)
	
	# initialize columns
	var column_x: float = padding
	for i in range(column_count):
		var column := COLUMN_SCENE.instantiate()
		column.index = i
		column.position = Vector2(column_x, padding)
		column.size = Vector2(block_size, height - padding * 2)
		column.background_color = Color.DIM_GRAY
		column.board = self
		
		add_child(column)
		
		column_x += block_size + padding
		
	# various other setup
	position = Vector2(0, viewport_height - height)
	block_symbols = build_block_symbols()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func build_block_symbols() -> PackedStringArray:
	var static_symbols = PackedStringArray([""]) + "kmgtpezyrq".split()
	var dynamic_symbols_level_1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split()
	var dynamic_symbols_level_2: PackedStringArray = []
	for symbol_1 in dynamic_symbols_level_1:
		for symbol_2 in dynamic_symbols_level_1:
			dynamic_symbols_level_2.append(symbol_1 + symbol_2)
			
	return static_symbols + dynamic_symbols_level_1 + dynamic_symbols_level_2
	
	
func get_formatted_block_text(block: BlockData) -> String:
	match block.type:
		BlockData.Type.POWER:
			var power = (block as PowerBlockData).power
			var symbol_index: int = -1
			for i in range(block_symbols.size()):
				if power >= i * 10 && power - (i * 10) < 10:
					symbol_index = i
					break
			return str(2 ** (power - 10 * symbol_index)) + block_symbols[symbol_index]
		BlockData.Type.WILDCARD:
			return str(2 ** (block as WildcardBlockData).magnitude)
		_:
			return "?"
	
	
func get_block_background_color(block: BlockData) -> Color:
	match block.type:
		BlockData.Type.POWER:
			return color_progression[(block as PowerBlockData).power % color_progression.size()]
		BlockData.Type.WILDCARD:
			return color_progression[(block as WildcardBlockData).magnitude % color_progression.size()]
		_:
			return Color.WHITE

func get_next_open_index_in_column(x: int) -> int:
	return blocks[x].find(null)
	
#func add_block_to_column(index: int):
#	var row_index = get_next_open_index_in_column(index)
#	if row_index != -1:
#		# spawn a block
#		add_block_at(Vector2i(index, row_index), block_progression[0])
##		spawn_initial_block_at(Vector2(index, row_index), block_progression[0])
	
func set_block_at(loc: Vector2i, block: Block):
	blocks[loc.x][loc.y] = block
	
func remove_block_at(loc: Vector2i):
	var block = blocks[loc.x][loc.y]
	remove_child(block)
	block.queue_free()
	blocks[loc.x][loc.y] = null
	
func try_spawn_initial_block_in(x: int):
	if !anim_lock && blocks[x].any(func(block): return block == null):
		anim_lock = true
		var y = get_next_open_index_in_column(x)
		spawn_initial_block_at(Vector2i(x, y), block_progression[0])
	
func spawn_initial_block_at(pos: Vector2i, data: BlockData):
	var block = spawn_block(Vector2i(pos.x, row_count - 1), data)
	
	var on_animation_finished = func():
		set_block_at(pos, block)
		advance_block_progression()
		anim_lock = false
		try_check_merge(pos.x, false, get_on_animation_chain_finished())
		
	animate_blocks([{
		"block": block,
		"prop_name": "position",
		"prop_value": get_actual_location_from_grid(pos),
	}], 0.3, on_animation_finished)
	
#	spawn_animated_block(Vector2i(pos.x, row_count - 1), pos, data, on_animation_finished)
	
func get_new_block(pos: Vector2i, data: BlockData) -> Block:
	var block = BLOCK_SCENE.instantiate()
	block.initialize({
		"grid_position": pos,
#		"grid_position_initial": from_pos,
#		"grid_position_final": to_pos,
		"size": Vector2(block_size, block_size),
		"board": self,
		"color": get_block_background_color(data),
		"data": data,
#		"animation_callback": on_animation_finished,
	})
	return block
	
func spawn_block(pos: Vector2i, data: BlockData) -> Block:
	var block = get_new_block(pos, data)
	add_child(block)
	return block
	
#func spawn_animated_block(from_pos: Vector2i, to_pos: Vector2i, data: BlockData, on_animation_finished: Callable) -> Block:
#	var block = get_new_block(from_pos, data)
#	var animated = ANIMATED_SCENE.instantiate()
#	animated.parent_property_name = "position"
#	animated.parent_property_value = get_actual_location_from_grid(to_pos)
#	animated.duration_seconds = 0.2
#	animated.ease = Tween.EASE_OUT
#	animated.trans = Tween.TRANS_EXPO
#	animated.on_finished = on_animation_finished
#	block.add_child(animated)
#	add_child(block)
#	return block
	
func select_next_block_in_progression():
#	if (Math.random() < specialBlockOdds) {
#		const magSample = Math.random();
#		const magnitude = magSample < 0.6 ? 0 : magSample < 0.9 ? 1 : 2;
#		return {
#			type: "wildcard",
#			magnitude: magnitude,
#			directions: randomCherryPickFromArray(
#				["north", "south", "east", "west"],
#				randRangeInt(1, 4),
#			),
#		};
#	}
	return PowerBlockData.new(current_level + randi_range(0, steps_above_minimum_to_drop))
	
func advance_block_progression():
	block_progression.remove_at(0)
	block_progression.push_back(select_next_block_in_progression())
	
func get_max_power_active() -> int:
	var max_power = 0
	for column in blocks:
		for block in column:
			if block.type == BlockData.Type.POWER:
				max_power = max((block as PowerBlockData).power, max_power)
	return max_power

func get_actual_location_from_grid(grid_loc: Vector2) -> Vector2:
	return Vector2(
		padding + (padding * grid_loc.x) + (block_size * grid_loc.x), 
		height - ((padding * (grid_loc.y + 1)) + (block_size * (grid_loc.y + 1)))
	)
	
func animate_blocks(subjects: Array[Dictionary], duration_seconds: float, on_finish: Callable):
	var tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	for subject in subjects:
		tween.parallel().tween_property(subject.block, subject.prop_name, subject.prop_value, duration_seconds)
	var callback = func():
		on_finish.call()
	tween.tween_callback(callback)
	
func try_check_collapse(active_column: int, on_animation_chain_finished: Callable):
	var did_collapse = false
	var subjects: Array[Dictionary] = []
	var on_finish_funcs: Array[Callable] = []
	for x in range(column_count):
		var column = blocks[x]
		for y in range(row_count):
			var block = column[y]
			if block == null:
				# there's no block at this position!
				# find the position of the next block above this one
				var next_block_y = -1
				for ny in range(column_count):
					if ny > y && column[ny] != null:
						next_block_y = ny
						break
				if next_block_y != -1:
					did_collapse = true
					anim_lock = true
					
					var collapsing_block = column[next_block_y]
					var from_pos = Vector2i(x, next_block_y)
					var to_pos = Vector2i(x, y)
					
					subjects.append({
						"block": collapsing_block,
						"prop_name": "position",
						"prop_value": get_actual_location_from_grid(to_pos)
					})
					
					on_finish_funcs.append(func():
						set_block_at(to_pos, collapsing_block)
					)
					
					blocks[from_pos.x][from_pos.y] = null
					
#					var on_finish = func():
#						add_block_at(pos, block)
#						advance_block_progression()
#						anim_lock = false
						
#					spawn_animated_block(from_pos, to_pos, new_block_data, on_finish)
					
#					remove_block_at(from_pos)
	if did_collapse:
		var callback = func():
			for function in on_finish_funcs:
				function.call()
			anim_lock = false
			try_check_merge(active_column, false, on_animation_chain_finished)
		animate_blocks(subjects, 0.2, callback)
	else:
		try_check_merge(active_column, false, on_animation_chain_finished)

func get_new_block_data_of_merge_group(group: Array[Vector2i]) -> BlockData:
	var max_power = 0
	for pos in group:
		var block: Block = blocks[pos.x][pos.y]
		if block.data.type == BlockData.Type.POWER && (block.data as PowerBlockData).power > max_power:
			max_power = (block.data as PowerBlockData).power
			
	var max_magnitude = 0
	for pos in group:
		var block: Block = blocks[pos.x][pos.y]
		if block.data.type == BlockData.Type.WILDCARD && (block.data as WildcardBlockData).magnitude > max_magnitude:
			max_magnitude = (block.data as WildcardBlockData).magnitude
			
	return PowerBlockData.new(max_power + max_magnitude + group.size() - 1)
	
func are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return \
		(abs(a.x - b.x) == 1 && abs(a.y - b.y) == 0) || \
		(abs(a.x - b.x) == 0 && abs(a.y - b.y) == 1)
	
func get_center_of_merge_group(group: Array[Vector2i], active_column: int) -> Vector2i:
	if group.size() == 2:
		if group[0].x == group[1].x:
			# same x coordinate, so these are vertically stacked
			# we should return the one on the bottom
			return group[0] if group[0].y < group[1].y else group[1]
		else:
			# these must be horizontal
			# we should return the one closest to the active column
			if abs(group[0].x - active_column) < abs(group[1].x - active_column):
				return group[0]
			else:
				return group[1]
				
	# for a group size of > 3, it will be sufficient to fine the
	# location that borders the most other group members
	var max_adjacent_count = 0
	var max_adjacent_pos: Vector2i
	for pos_1 in group:
		var adjacent_count = 0
		for pos_2 in group:
			if are_adjacent(pos_1, pos_2):
				# add an additional neighbor to the running count
				adjacent_count += 1
		# if we found a new winner...
		if adjacent_count > max_adjacent_count:
			# ...increase the count...
			max_adjacent_count = adjacent_count
			# ...and save our position as the current "king"
			max_adjacent_pos = pos_1
	
	return max_adjacent_pos
	
# helper function
# check if this location is in some group already
# and return that group's index if it is
# 
# NOTE: merge_groups is of type Array[Array[Vector2i]]
func check_and_add_to_interaction_group(merge_groups: Array[Array], current: Vector2i, matched: Vector2i) -> Array[Array]:
	var new_merge_groups: Array[Array] = merge_groups.duplicate(true)
	var current_group_index := -1
	var matched_group_index := -1
	for i in range(merge_groups.size()):
		var group: Array[Vector2i] = merge_groups[i]
		if current_group_index == -1 && group.any(func(pos): return pos == current):
			current_group_index = i
		if matched_group_index == -1 && group.any(func(pos): return pos == matched):
			matched_group_index = i
	
	if current_group_index == -1 && matched_group_index != -1:
		# matched is in a group, so add current to that group
		new_merge_groups[matched_group_index].append(current)
	elif current_group_index != -1 && matched_group_index == -1:
		# current is in a group, so add matched to that group
		new_merge_groups[current_group_index].append(matched)
	elif current_group_index == -1 && matched_group_index == -1:
		# neither are in any group, so add a new group with both of them
		new_merge_groups.append([current, matched])
	return new_merge_groups

func find_special_merge_groups() -> Array[Array]: # really returns Array[Array[Vector2i]]
	return [[Vector2i(0, 0)]]
	
func find_merge_groups() -> Array[Array]: # really returns Array[Array[Vector2i]]
	return [[Vector2i(0, 0)]]
	
func try_check_merge(active_column: int, should_check_special: bool, on_animation_chain_finished: Callable):
	pass
	
func is_wildcard_block_position_valid(pos: Vector2i) -> bool:
	return false
	
func get_wildcard_blocks_in_closed_loop() -> Array[Vector2i]:
	return [Vector2i(0, 0)]
	
func try_check_remove_invalid_blocks(on_animation_chain_finished: Callable):
	pass
	
func try_check_new_level():
	pass

func get_on_animation_chain_finished():
	return func():
		pass
#		try_check_new_level()
#		try_check_remove_invalid_blocks(on_animation_chain_finished)
# 		TODO: save
	
