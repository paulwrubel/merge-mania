class_name Board
extends Node2D

signal current_level_changed(new_current_level)
signal block_progression_advanced(new_block_progression)
signal block_progression_refreshed(new_block_progression)
signal board_filled()

const Column := preload("res://scenes/column/column.tscn")
const Block := preload("res://scenes/block/block.tscn")

var BlockUtils

var new_block_animation_tween_settings = TweenSettings.new(
	0.3,
	Tween.EASE_OUT,
	Tween.TRANS_EXPO
)
var merge_animation_tween_settings = TweenSettings.new(
	0.3,
	Tween.EASE_OUT,
	Tween.TRANS_CUBIC
)
var collapse_animation_tween_settings = TweenSettings.new(
	0.3,
	Tween.EASE_OUT,
	Tween.TRANS_EXPO
)
var remove_block_animation_tween_settings = TweenSettings.new(
	0.5,
	Tween.EASE_IN,
	Tween.TRANS_CUBIC
)

const save_filename_format = "user://save{0}.json"

var active_save_index = 0

var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

const column_count: int = 5
const row_count: int = 6

const pre_block_size: float = 100
const pre_padding: float = 5
const pre_rounding_radius: float = 5
const pre_width: float = (pre_block_size * column_count) + (pre_padding * (column_count + 1))
const pre_height: float = (pre_block_size * row_count) + (pre_padding * (row_count + 1))

var block_symbols: PackedStringArray

var scalar: float = viewport_width / pre_width

var block_size: float = pre_block_size * scalar
var padding: float = pre_padding * scalar
var width: float = pre_width * scalar
var height: float = pre_height * scalar

var steps_above_minimum_to_advance: int = 9
const steps_above_minimum_to_drop: int = 4

const special_block_chance: float = 0.03

var anim_lock: bool = false
var is_active: bool = true

var current_level: int = 0
var block_progression: Array[BlockData] = [
	PowerBlockData.new(0), 
	PowerBlockData.new(0),
]

var blocks: Array[Array] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	BlockUtils = $"/root/BlockUtils"
		
	# initialize columns
	var column_x: float = padding
	for i in range(column_count):
		var column := Column.instantiate()
		column.index = i
		column.position = Vector2(column_x, padding)
		column.size = Vector2(block_size, height - padding * 2)
		column.board = self
		
		add_child(column)
		
		column_x += block_size + padding
		
	# various other setup
	position = Vector2(0, viewport_height - height)

	# load game or initialize empty blocks array
	if not try_load_game():
		# initialize blocks grid
		for x in range(column_count):
			var col = []
			for y in range(row_count):
				col.append(null)
			blocks.append(col)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func set_active_save_index(new_active_save_index: int):
	active_save_index = new_active_save_index
	reset_game()
	try_load_game()


func get_save_filename() -> String:
	return save_filename_format.format([active_save_index])


func save_game():
	var save_file: FileAccess = FileAccess.open(get_save_filename(), FileAccess.WRITE)

	var block_progression_raw = []
	for block_data in block_progression:
		block_progression_raw.append(block_data.save())

	var blocks_raw = []
	for x in range(column_count):
		var col_raw = []
		for y in range(row_count):
			var block = blocks[x][y]
			if block == null:
				col_raw.append(null)
			else:
				# var pos = Vector2i(
				# 	block_raw["x"],
				# 	block_raw["y"],
				# )
				# var block_data = BlockData.load_from_save(block_raw["data"])
				# var block = spawn_block(pos, block_data)
				col_raw.append({
					"x": x,
					"y": y,
					"data": block.data.save(),
				})
		blocks_raw.append(col_raw)

	var save_data = {
		"difficulty": steps_above_minimum_to_advance - 7,
		"current_level": current_level,
		"block_progression": block_progression_raw,
		"blocks": blocks_raw,
	}

	var save_string = JSON.stringify(save_data)
	print("saving: ", save_string)
	save_file.store_line(save_string)


func try_load_game() -> bool:
	var save_filename = get_save_filename()
	if not FileAccess.file_exists(save_filename):
		return false
	
	var save_file: FileAccess = FileAccess.open(save_filename, FileAccess.READ)
	var save_data_raw: String = save_file.get_line()
	print("loading: ", save_data_raw)

	var save_data = JSON.parse_string(save_data_raw)
	if save_data == null:
		return false

	# difficulty
	var difficulty = save_data["difficulty"]
	steps_above_minimum_to_advance = 7 + difficulty
	
	# current level
	current_level = save_data["current_level"]
	current_level_changed.emit(current_level)

	# block progression
	block_progression = []
	var block_progression_raw = save_data["block_progression"]
	for i in range(block_progression_raw.size()):
		var block_data_raw = block_progression_raw[i]
		var block_data = BlockData.load_from_save(block_data_raw)
		block_progression.append(block_data)
	
	# blocks
	blocks = []
	var blocks_raw = save_data["blocks"]
	for x in range(column_count):
		var col = []
		for y in range(row_count):
			var block_raw = blocks_raw[x][y]
			if block_raw == null:
				col.append(null)
			else:
				var pos = Vector2i(
					block_raw["x"],
					block_raw["y"],
				)
				var block_data = BlockData.load_from_save(block_raw["data"])
				var block = spawn_block(pos, block_data)
				col.append(block)
		blocks.append(col)
	return true


func reset_game():
	for x in range(column_count):
		for y in range(row_count):
			var block = blocks[x][y]
			if block != null:
				destroy_block(block)
				blocks[x][y] = null
	
	anim_lock = false
	is_active = true

	current_level = 0
	current_level_changed.emit(0)

	block_progression = [
		PowerBlockData.new(0),
		PowerBlockData.new(0),
	]
	block_progression_refreshed.emit(block_progression)

func get_next_open_index_in_column(x: int) -> int:
	return blocks[x].find(null)


func destroy_block(block: Block):
	remove_child(block)
	block.queue_free()


func try_spawn_initial_block_in(x: int):
	if not anim_lock and blocks[x].any(func(block): return block == null):
		anim_lock = true
		var y: int = get_next_open_index_in_column(x)
		spawn_initial_block_at(Vector2i(x, y), block_progression[0])


func spawn_initial_block_at(pos: Vector2i, data: BlockData):
	var block = spawn_block(Vector2i(pos.x, row_count - 1), data)
	
	var on_animation_finished = func():
		blocks[pos.x][pos.y] = block
		advance_block_progression()
		anim_lock = false
		try_check_merge(pos.x, false, get_on_animation_chain_finished())
		
	animate_blocks([AnimationSubject.new(
		block,
		"position",
		get_actual_location_from_grid(pos),
	)], new_block_animation_tween_settings, on_animation_finished)


func get_new_block(pos: Vector2i, data: BlockData) -> Block:
	var block = Block.instantiate()
	block.setup(
		get_actual_location_from_grid(pos),
		Vector2(block_size, block_size),
		Vector2(1, 1),
		data,
	)
	return block


func spawn_block(pos: Vector2i, data: BlockData) -> Block:
	var block = get_new_block(pos, data)
	add_child(block)
	return block


func select_next_block_in_progression() -> BlockData:
	if randf() < special_block_chance:
		var mag_sample: float = randf()
		var magnitude: int
		if mag_sample < 0.6:
			magnitude = 0
		elif mag_sample < 0.9:
			magnitude = 1
		else:
			magnitude = 2
		return WildcardBlockData.new(
			magnitude,
			BlockUtils.random_cherry_pick_from_array(
				WildcardBlockData.CardinalDirection.values(),
				randi_range(1, 4),
			),
		)
	return PowerBlockData.new(current_level + randi_range(0, steps_above_minimum_to_drop))


func advance_block_progression():
	block_progression.remove_at(0)
	block_progression.push_back(select_next_block_in_progression())
	block_progression_advanced.emit(block_progression)


func get_max_power_active() -> int:
	var max_power = 0
	for column in blocks:
		for block in column:
			if block != null and block.data.type == BlockData.Type.POWER:
				max_power = max((block.data as PowerBlockData).power, max_power)
	return max_power


func get_actual_location_from_grid(grid_loc: Vector2) -> Vector2:
	return Vector2(
		padding + (padding * grid_loc.x) + (block_size * grid_loc.x), 
		height - ((padding * (grid_loc.y + 1)) + (block_size * (grid_loc.y + 1)))
	)


func animate_blocks(subjects: Array[AnimationSubject], tween_settings: TweenSettings, on_finish = null):
	var tween = create_tween() \
		.set_ease(tween_settings.easing) \
		.set_trans(tween_settings.transition)
	for subject in subjects:
		tween.parallel().tween_property(
			subject.subject, 
			subject.property_name, 
			subject.property_value, 
			tween_settings.duration_seconds
		)
	if on_finish != null:
		tween.tween_callback(on_finish)


func try_check_collapse(active_column: int, on_animation_chain_finished: Callable):
	var did_collapse: bool = false
	var subjects: Array[AnimationSubject] = []
	var on_finish_funcs: Array[Callable] = []
	for x in range(column_count):
		var column = blocks[x]
		for y in range(row_count):
			var block = column[y]
			if block == null:
				# there's no block at this position!
				# find the position of the next block above this one
				var next_block_y = -1
				for ny in range(row_count):
					if ny > y and column[ny] != null:
						next_block_y = ny
						break
				if next_block_y != -1:
					# we have a block and a place to move it
					did_collapse = true
					anim_lock = true
					
					var collapsing_block: Block = column[next_block_y]
					var from_pos := Vector2i(x, next_block_y)
					var to_pos := Vector2i(x, y)
					
					subjects.append(AnimationSubject.new(
						collapsing_block,
						"position",
						get_actual_location_from_grid(to_pos),
					))
					
					on_finish_funcs.append(func():
						blocks[to_pos.x][to_pos.y] = collapsing_block
					)
					
					blocks[from_pos.x][from_pos.y] = null
	if did_collapse:
		var callback = func():
			for function in on_finish_funcs:
				function.call()
			anim_lock = false
			try_check_merge(active_column, false, on_animation_chain_finished)
		animate_blocks(subjects, collapse_animation_tween_settings, callback)
	else:
		try_check_merge(active_column, false, on_animation_chain_finished)


func get_new_block_data_of_merge_group(group: Array) -> BlockData:
	var max_power: int = 0
	for pos in group:
		var block: Block = blocks[pos.x][pos.y]
		if block.data.type == BlockData.Type.POWER and (block.data as PowerBlockData).power > max_power:
			max_power = (block.data as PowerBlockData).power
			
	var max_magnitude = 0
	for pos in group:
		var block: Block = blocks[pos.x][pos.y]
		if block.data.type == BlockData.Type.WILDCARD and (block.data as WildcardBlockData).magnitude > max_magnitude:
			max_magnitude = (block.data as WildcardBlockData).magnitude
			
	return PowerBlockData.new(max_power + max_magnitude + group.size() - 1)


func are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return (
		(abs(a.x - b.x) == 1 and abs(a.y - b.y) == 0)
		or (abs(a.x - b.x) == 0 and abs(a.y - b.y) == 1)
	)


func get_center_of_merge_group(group: Array, active_column: int) -> Vector2i:
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
	var max_adjacent_count: int = 0
	var max_adjacent_pos: Vector2i
	for pos_1 in group:
		var adjacent_count: int = 0
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
	var current_group_index: int = -1
	var matched_group_index: int = -1
	for i in range(merge_groups.size()):
		var group: Array = merge_groups[i]
		if current_group_index == -1 and group.any(func(pos): return pos == current):
			current_group_index = i
		if matched_group_index == -1 and group.any(func(pos): return pos == matched):
			matched_group_index = i
	
	if current_group_index == -1 and matched_group_index != -1:
		# matched is in a group, so add current to that group
		new_merge_groups[matched_group_index].append(current)
	elif current_group_index != -1 and matched_group_index == -1:
		# current is in a group, so add matched to that group
		new_merge_groups[current_group_index].append(matched)
	elif current_group_index == -1 and matched_group_index == -1:
		# neither are in any group, so add a new group with both of them
		new_merge_groups.append([current, matched])
	return new_merge_groups


func find_special_merge_groups() -> Array[Array]: # really returns Array[Array[Vector2i]]
	var special_merge_groups: Array[Array] = []
	for x in range(column_count):
		var column: Array = blocks[x]
		for y in range(row_count):
			var this_block: Block = column[y]
			
			# if this spot is empty or not a wildcard, move on
			if this_block == null or this_block.data.type != BlockData.Type.WILDCARD:
				continue
				
			var this_block_data = (this_block.data as WildcardBlockData)
				
			# check north
			if y < row_count - 1 and this_block_data.directions.has(WildcardBlockData.CardinalDirection.NORTH):
				var other_block = column[y + 1]
				if other_block != null and other_block.data.type == BlockData.Type.POWER:
					special_merge_groups = check_and_add_to_interaction_group(
						special_merge_groups,
						Vector2i(x, y),
						Vector2i(x, y + 1)
					)
				
			# check east
			if x < column_count - 1 and this_block_data.directions.has(WildcardBlockData.CardinalDirection.EAST):
				var other_block = blocks[x + 1][y]
				if other_block != null and other_block.data.type == BlockData.Type.POWER:
					special_merge_groups = check_and_add_to_interaction_group(
						special_merge_groups,
						Vector2i(x, y),
						Vector2i(x + 1, y)
					)
				
			# check south
			if y > 0 and this_block_data.directions.has(WildcardBlockData.CardinalDirection.SOUTH):
				var other_block = column[y - 1]
				if other_block != null and other_block.data.type == BlockData.Type.POWER:
					special_merge_groups = check_and_add_to_interaction_group(
						special_merge_groups,
						Vector2i(x, y),
						Vector2i(x, y - 1)
					)
				
			# check west
			if x > 0 and this_block_data.directions.has(WildcardBlockData.CardinalDirection.WEST):
				var other_block = blocks[x - 1][y]
				if other_block != null and other_block.data.type == BlockData.Type.POWER:
					special_merge_groups = check_and_add_to_interaction_group(
						special_merge_groups,
						Vector2i(x, y),
						Vector2i(x - 1, y)
					)
	
	return special_merge_groups


func find_merge_groups() -> Array[Array]: # really returns Array[Array[Vector2i]]
	var merge_groups: Array[Array] = []
	for x in range(column_count):
		var column := blocks[x]
		for y in range(row_count):
			var this_block: Block = column[y]
			
			# if this spot is empty or not a powerblock, move on
			if this_block == null or this_block.data.type != BlockData.Type.POWER:
				continue
				
			var this_block_data = (this_block.data as PowerBlockData)
				
			# check north
			if y < row_count - 1:
				var other_block = column[y + 1]
				if other_block != null and \
					other_block.data.type == BlockData.Type.POWER and \
					(other_block.data as PowerBlockData).power == this_block_data.power:
					merge_groups = check_and_add_to_interaction_group(
						merge_groups,
						Vector2i(x, y),
						Vector2i(x, y + 1)
					)
				
			# check east
			if x < column_count - 1:
				var other_block = blocks[x + 1][y]
				if other_block != null and \
					other_block.data.type == BlockData.Type.POWER and \
					(other_block.data as PowerBlockData).power == this_block_data.power:
					merge_groups = check_and_add_to_interaction_group(
						merge_groups,
						Vector2i(x, y),
						Vector2i(x + 1, y)
					)
				
			# check south
			if y > 0:
				var other_block = column[y - 1]
				if other_block != null and \
					other_block.data.type == BlockData.Type.POWER and \
					(other_block.data as PowerBlockData).power == this_block_data.power:
					merge_groups = check_and_add_to_interaction_group(
						merge_groups,
						Vector2i(x, y),
						Vector2i(x, y - 1)
					)
				
			# check west
			if x > 0:
				var other_block = blocks[x - 1][y]
				if other_block != null and \
					other_block.data.type == BlockData.Type.POWER and \
					(other_block.data as PowerBlockData).power == this_block_data.power:
					merge_groups = check_and_add_to_interaction_group(
						merge_groups,
						Vector2i(x, y),
						Vector2i(x - 1, y)
					)
	
	return merge_groups


func try_check_merge(active_column: int, should_check_special: bool, on_animation_chain_finished: Callable):
	var merge_groups = find_special_merge_groups() if should_check_special else find_merge_groups()
	
	# if we know we're gonna merge, might as well lock it now
	if merge_groups.size() > 0:
		anim_lock = true
		
	# assemble subjects and process changes
	var subjects: Array[AnimationSubject] = []
	var on_finish_funcs: Array[Callable] = []
	for group in merge_groups:
		var group_center = get_center_of_merge_group(group, active_column)
		var new_block_data = get_new_block_data_of_merge_group(group)
		
		var sub_on_finish_funcs: Array[Callable] = []
		for pos in group:
			if pos == group_center:
				# we are the group center!
				# we need to remove ourselves since we are being replaced
				sub_on_finish_funcs.append(func():
					destroy_block(blocks[group_center.x][group_center.y])
				)
				continue
			# create new block, just for animation purposes
			var new_block = spawn_block(pos, new_block_data)
			subjects.append(AnimationSubject.new(
				new_block,
				"position",
				get_actual_location_from_grid(group_center),
			))
			sub_on_finish_funcs.append(func():
				destroy_block(new_block)	
			)
			destroy_block(blocks[pos.x][pos.y])
			blocks[pos.x][pos.y] = null
		
		on_finish_funcs.append(func():
			for function in sub_on_finish_funcs:
				function.call()
			var new_block = spawn_block(group_center, new_block_data)
			blocks[group_center.x][group_center.y] = new_block
		)
	if merge_groups.size() > 0:
		# add animation
		var callback = func():
			for function in on_finish_funcs:
				function.call()
			anim_lock = false
			try_check_collapse(active_column, on_animation_chain_finished)
		animate_blocks(subjects, merge_animation_tween_settings, callback)
	elif not should_check_special:
		try_check_merge(active_column, true, on_animation_chain_finished)
	else:
		on_animation_chain_finished.call()


func is_wildcard_block_position_valid(pos: Vector2i) -> bool:
	var block: Block = blocks[pos.x][pos.y]
	if block == null or block.data.type != BlockData.Type.WILDCARD:
		return true
		
	var block_data: WildcardBlockData = block.data as WildcardBlockData
		
	var has_valid_merge_option = false
	# check north
	if block_data.directions.has(WildcardBlockData.CardinalDirection.NORTH):
		# blocks can always fall to make room
		# or have other blocks placed on top of them
		# so north is never an invalid option
		has_valid_merge_option = true
	# check south
	if block_data.directions.has(WildcardBlockData.CardinalDirection.SOUTH) and pos.y != 0:
		# this block isn't on the bottom row
		# so, while unlikely if it hasn't already,
		# it still can technically merge
		has_valid_merge_option = true
	# check east
	if block_data.directions.has(WildcardBlockData.CardinalDirection.EAST) and pos.x != column_count - 1:
		# this block isn't in the rightmost column
		# so it can definitely merge
		has_valid_merge_option = true
	# check west
	if block_data.directions.has(WildcardBlockData.CardinalDirection.WEST) and pos.x != 0:
		# this block isn't in the leftmost column
		# so it can definitely merge
		has_valid_merge_option = true
	return has_valid_merge_option


# get locations for wildcard blocks that all point to
# each other in a "closed loop", where it is never possible
# for a block to merge with it...
#
# well, technically, part of the group could collapse and
# open the opportunity to merge, but this scenario is so
# esoteric that we will just pretend it will never happen
# and remove the blocks anyways
func get_wildcard_blocks_in_closed_loop() -> Array[Vector2i]:
	var connected_special_groups: Array[Array] = []
	for x in range(column_count):
		var column := blocks[x]
		for y in range(row_count):
			var this_block: Block = column[y]
			var this_pos := Vector2i(x, y)
			
			# if this spot is empty or not a wildcard block, move on
			if this_block == null or this_block.data.type != BlockData.Type.WILDCARD:
				continue
			
			# if we face a wall, we are invalid
			if not is_wildcard_block_position_valid(this_pos):
				var current_group_index = -1
				for i in range(connected_special_groups.size()):
					var group: Array[Vector2i] = connected_special_groups[i]
					for pos in group:
						if pos == this_pos:
							current_group_index = i
				# only add to a new group if we aren't already in one
				# we could be in one because a block pointing at us may have added us
				if current_group_index == -1:
					connected_special_groups.append([this_pos])
					
			# check north
			if y < row_count - 1:
				var other_block: Block = column[y + 1]
				var other_pos: Vector2i = Vector2i(x, y + 1)
				if other_block != null and \
						other_block.data.type == BlockData.Type.WILDCARD and \
						(this_block.data.directions.has(WildcardBlockData.CardinalDirection.NORTH) or \
						other_block.data.directions.has(WildcardBlockData.CardinalDirection.SOUTH)):
					connected_special_groups = check_and_add_to_interaction_group(
						connected_special_groups,
						this_pos,
						other_pos,
					)
					
			# check east
			if x < column_count - 1:
				var other_block: Block = blocks[x + 1][y]
				var other_pos: Vector2i = Vector2i(x + 1, y)
				if other_block != null and \
						other_block.data.type == BlockData.Type.WILDCARD and \
						(this_block.data.directions.has(WildcardBlockData.CardinalDirection.EAST) or \
						other_block.data.directions.has(WildcardBlockData.CardinalDirection.WEST)):
					connected_special_groups = check_and_add_to_interaction_group(
						connected_special_groups,
						this_pos,
						other_pos,
					)
					
			# check south
			if y > 0:
				var other_block: Block = column[y - 1]
				var other_pos: Vector2i = Vector2i(x, y - 1)
				if other_block != null and \
						other_block.data.type == BlockData.Type.WILDCARD and \
						(this_block.data.directions.has(WildcardBlockData.CardinalDirection.SOUTH) or \
						other_block.data.directions.has(WildcardBlockData.CardinalDirection.NORTH)):
					connected_special_groups = check_and_add_to_interaction_group(
						connected_special_groups,
						this_pos,
						other_pos,
					)
					
			# check west
			if x > 0:
				var other_block: Block = blocks[x - 1][y]
				var other_pos: Vector2i = Vector2i(x - 1, y)
				if other_block != null and \
						other_block.data.type == BlockData.Type.WILDCARD and \
						(this_block.data.directions.has(WildcardBlockData.CardinalDirection.WEST) or \
						other_block.data.directions.has(WildcardBlockData.CardinalDirection.EAST)):
					connected_special_groups = check_and_add_to_interaction_group(
						connected_special_groups,
						this_pos,
						other_pos,
					)
	
	var closed_special_groups: Array = []
	for group in connected_special_groups:
		var group_is_valid = false
		for i in range(group.size()):
			var pos: Vector2i = group[i]
			var this_block_data = blocks[pos.x][pos.y].data as WildcardBlockData
			
			# check north
			if (pos.y < row_count - 1 
				and this_block_data.directions.has(WildcardBlockData.CardinalDirection.NORTH)):
				var other_block = blocks[pos.x][pos.y + 1]
				if other_block == null or other_block.data.type != BlockData.Type.WILDCARD:
					group_is_valid = true
					break
					
			# check east
			if (pos.x < column_count - 1 
				and this_block_data.directions.has(WildcardBlockData.CardinalDirection.EAST)):
				var other_block = blocks[pos.x + 1][pos.y]
				if other_block == null or other_block.data.type != BlockData.Type.WILDCARD:
					group_is_valid = true
					break
					
			# check south
			if (pos.y > 0
				and this_block_data.directions.has(WildcardBlockData.CardinalDirection.SOUTH)):
				var other_block = blocks[pos.x][pos.y - 1]
				if other_block == null or other_block.data.type != BlockData.Type.WILDCARD:
					group_is_valid = true
					break
					
			# check east
			if (pos.x > 0
				and this_block_data.directions.has(WildcardBlockData.CardinalDirection.WEST)):
				var other_block = blocks[pos.x - 1][pos.y]
				if other_block == null or other_block.data.type != BlockData.Type.WILDCARD:
					group_is_valid = true
					break
			
		if not group_is_valid:
			closed_special_groups.append(group.duplicate())
		
	var blocks_in_closed_special_group: Array[Vector2i] = []
	for group in closed_special_groups:
		blocks_in_closed_special_group.append_array(group)
		
	return blocks_in_closed_special_group


func try_check_remove_invalid_blocks(on_animation_chain_finished: Callable):
	# remove all on-screen blocks that are considered "invalid"
	# these include:
	# - power blocks below the minimum power
	# - wildcard blocks in a closed chain
	var block_positions_to_remove: Array[Vector2i] = []
	
	var invalid_wildcard_blocks: Array[Vector2i] = get_wildcard_blocks_in_closed_loop()
	block_positions_to_remove.append_array(invalid_wildcard_blocks)
	
	for x in range(column_count):
		var column = blocks[x]
		for y in range(row_count):
			var block = column[y]
			if (block != null 
					and block.data.type == BlockData.Type.POWER 
					and block.data.power < current_level):
				block_positions_to_remove.append(Vector2i(x, y))
	
	var active_column = 0
	var subjects: Array[AnimationSubject] = []
	var on_finish_funcs: Array[Callable] = []
	for pos in block_positions_to_remove:
		var block = blocks[pos.x][pos.y]
		# we'll just set it to whichever we saw last, because why not
		active_column = pos.x
		# this is the removal animation
		subjects.append_array([
			AnimationSubject.new(
				block,
				"position",
				get_actual_location_from_grid(Vector2(pos.x + 0.5, pos.y - 0.5))
			),
			AnimationSubject.new(
				block,
				"scale",
				Vector2(0, 0)
			),
		])
		# just immediately remove it on-record
		on_finish_funcs.append(func():
			destroy_block(block)
			blocks[pos.x][pos.y] = null
		)
	
	if block_positions_to_remove.size() > 0:
		anim_lock = true
		var on_finish = func():
			for function in on_finish_funcs:
				function.call()
			anim_lock = false
			try_check_collapse(active_column, on_animation_chain_finished)
		animate_blocks(subjects, remove_block_animation_tween_settings, on_finish)


func try_check_new_level():
	# update the minimum power
	var new_current_level = max(
		get_max_power_active() - (steps_above_minimum_to_advance - 1),
		0,
	)
	if new_current_level > current_level:
		current_level = new_current_level
		current_level_changed.emit(new_current_level)
		
		# reset power progression
		var filter_func = func(block_data: BlockData):
			return not (
				block_data.type == BlockData.Type.POWER
				and (block_data as PowerBlockData).power < current_level
			)
		var retained_blocks = block_progression.filter(filter_func)
		var new_blocks: Array[BlockData] = []
		for i in range(block_progression.size() - retained_blocks.size()):
			new_blocks.append(select_next_block_in_progression())
			
		block_progression = []
		block_progression.append_array(retained_blocks)
		block_progression.append_array(new_blocks)
		block_progression_refreshed.emit(block_progression)


func try_check_board_filled():
	if board_is_filled():
		is_active = false
		board_filled.emit()


func board_is_filled() -> bool:
	for column in blocks:
		for block in column:
			if block == null:
				return false
	return true


func get_on_animation_chain_finished():
	return func():
		try_check_new_level()
		try_check_remove_invalid_blocks(get_on_animation_chain_finished())
		try_check_board_filled()
		save_game()
