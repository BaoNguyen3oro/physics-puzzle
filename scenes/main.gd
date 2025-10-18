extends Node2D

# Preload all the different object types we can spawn
var box_scene = preload("res://scenes/box.tscn")

# Current level configuration
var current_level = 1
var max_level = 5

# Resource management - this makes the game a puzzle, not a sandbox
var box_limit = 10  # How many objects player can spawn this level
var boxes_spawned = 0  # How many have been used so far
var boxes_in_target = 0  # How many are currently in target
var goal_amount = 3  # How many needed to win

# Currently selected object type
var selected_object = "box"  # Can be: "box", "circle", "heavy", "bouncy"

# Game state
var game_won = false
var game_lost = false  # New: you can lose if you run out of boxes!

# References to scene objects
var target_zone = null
var ui_layer = null

# Level definitions - each level has different challenges
var level_configs = {
	1: {
		"goal": 3,
		"box_limit": 8,
		"description": "Basic: Fill the target",
		"target_pos": Vector2(576, 550),
		"obstacles": []
	},
	2: {
		"goal": 3,
		"box_limit": 7,
		"description": "Elevated: Target on platform",
		"target_pos": Vector2(576, 400),
		"obstacles": [
			{"type": "platform", "pos": Vector2(576, 450), "size": Vector2(250, 20)}
		]
	},
	3: {
		"goal": 4,
		"box_limit": 8,
		"description": "Danger Zone: Avoid the red area",
		"target_pos": Vector2(750, 550),
		"obstacles": [
			{"type": "hazard", "pos": Vector2(576, 550), "size": Vector2(150, 150)},
			{"type": "wall", "pos": Vector2(650, 500), "size": Vector2(20, 100)}
		]
	},
	4: {
		"goal": 5,
		"box_limit": 10,
		"description": "Bridge Builder: Cross the gap",
		"target_pos": Vector2(850, 550),
		"obstacles": [
			{"type": "platform", "pos": Vector2(300, 550), "size": Vector2(200, 20)},
			{"type": "platform", "pos": Vector2(850, 550), "size": Vector2(200, 20)},
			{"type": "hazard", "pos": Vector2(576, 580), "size": Vector2(300, 100)}
		]
	},
	5: {
		"goal": 6,
		"box_limit": 12,
		"description": "Master Challenge: Use all tools wisely",
		"target_pos": Vector2(576, 300),
		"obstacles": [
			{"type": "platform", "pos": Vector2(576, 350), "size": Vector2(180, 20)},
			{"type": "hazard", "pos": Vector2(400, 550), "size": Vector2(120, 120)},
			{"type": "hazard", "pos": Vector2(750, 550), "size": Vector2(120, 120)},
			{"type": "wall", "pos": Vector2(480, 450), "size": Vector2(20, 150)},
			{"type": "wall", "pos": Vector2(670, 450), "size": Vector2(20, 150)}
		]
	}
}

func _ready():
	print("=== ENHANCED PHYSICS PUZZLE GAME ===")
	print("Unique Gameplay Mechanics:")
	print("- Limited boxes per level (you must plan ahead!)")
	print("- Multiple object types with different physics")
	print("- Obstacles and hazards to overcome")
	print("- Progressive difficulty across 5 levels")
	print("")
	
	# Find the target zone
	target_zone = get_node_or_null("Target")
	if target_zone:
		target_zone.body_entered.connect(_on_target_body_entered)
		target_zone.body_exited.connect(_on_target_body_exited)
	
	# Load the current level
	load_level(current_level)
	
	# Create UI overlay
	create_ui()

# Create visual UI that shows game state on screen
func create_ui():
	# Create a CanvasLayer so UI appears on top of everything
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Create a container for all UI elements
	var ui_container = Control.new()
	ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(ui_container)
	
	# Level title at top
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.position = Vector2(20, 20)
	level_label.add_theme_font_size_override("font_size", 24)
	ui_container.add_child(level_label)
	
	# Resources remaining
	var resource_label = Label.new()
	resource_label.name = "ResourceLabel"
	resource_label.position = Vector2(20, 60)
	resource_label.add_theme_font_size_override("font_size", 20)
	ui_container.add_child(resource_label)
	
	# Goal progress
	var goal_label = Label.new()
	goal_label.name = "GoalLabel"
	goal_label.position = Vector2(20, 90)
	goal_label.add_theme_font_size_override("font_size", 20)
	ui_container.add_child(goal_label)
	
	# Controls info at bottom
	var controls_label = Label.new()
	controls_label.name = "ControlsLabel"
	controls_label.position = Vector2(20, 620)
	controls_label.add_theme_font_size_override("font_size", 16)
	controls_label.text = "1-4: Select object type | Click: Place | R: Reset level"
	ui_container.add_child(controls_label)
	
	# Selected object type indicator
	var selected_label = Label.new()
	selected_label.name = "SelectedLabel"
	selected_label.position = Vector2(20, 120)
	selected_label.add_theme_font_size_override("font_size", 18)
	ui_container.add_child(selected_label)
	
	update_ui()

# Update all UI text based on current game state
func update_ui():
	if not ui_layer:
		return
	
	var ui_container = ui_layer.get_child(0)
	
	# Update level info
	var level_config = level_configs[current_level]
	var level_label = ui_container.get_node("LevelLabel")
	level_label.text = "Level " + str(current_level) + ": " + level_config["description"]
	
	# Update resources with color coding
	var resource_label = ui_container.get_node("ResourceLabel")
	var remaining = box_limit - boxes_spawned
	resource_label.text = "Objects Remaining: " + str(remaining) + "/" + str(box_limit)
	if remaining <= 2:
		resource_label.add_theme_color_override("font_color", Color.RED)
	elif remaining <= 4:
		resource_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		resource_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Update goal progress
	var goal_label = ui_container.get_node("GoalLabel")
	goal_label.text = "Goal: " + str(boxes_in_target) + "/" + str(goal_amount) + " objects in target"
	if boxes_in_target >= goal_amount:
		goal_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		goal_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Update selected object type
	var selected_label = ui_container.get_node("SelectedLabel")
	var object_names = {
		"box": "Regular Box (balanced)",
		"heavy": "Heavy Box (stable, slow)",
		"circle": "Circle (rolls easily)",
		"bouncy": "Bouncy Ball (high rebound)"
	}
	selected_label.text = "Selected: " + object_names.get(selected_object, "Box")

# Load a specific level configuration
func load_level(level_num):
	# Clear any existing objects except ground
	clear_level()
	
	# Reset game state
	boxes_spawned = 0
	boxes_in_target = 0
	game_won = false
	game_lost = false
	
	# Get level configuration
	var config = level_configs[level_num]
	goal_amount = config["goal"]
	box_limit = config["box_limit"]
	
	# Position the target
	if target_zone:
		target_zone.position = config["target_pos"]
		var target_rect = target_zone.get_node("ColorRect")
		target_rect.color = Color(0.2, 0.8, 0.3, 0.5)  # Reset to green
	
	# Create obstacles for this level
	for obstacle in config["obstacles"]:
		create_obstacle(obstacle)
	
	update_ui()
	
	print("\n=== LEVEL " + str(level_num) + " LOADED ===")
	print(config["description"])
	print("Goal: Get " + str(goal_amount) + " objects into target")
	print("Box Limit: " + str(box_limit) + " objects available")

# Create obstacles based on level configuration
func create_obstacle(obstacle_data):
	if obstacle_data["type"] == "platform":
		# Create a static platform
		var platform = StaticBody2D.new()
		platform.position = obstacle_data["pos"]
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = obstacle_data["size"]
		collision.shape = shape
		platform.add_child(collision)
		
		var visual = ColorRect.new()
		visual.size = obstacle_data["size"]
		visual.position = -obstacle_data["size"] / 2
		visual.color = Color(0.3, 0.3, 0.3, 1.0)  # Gray platform
		platform.add_child(visual)
		
		add_child(platform)
		
	elif obstacle_data["type"] == "hazard":
		# Create a danger zone that destroys boxes
		var hazard = Area2D.new()
		hazard.position = obstacle_data["pos"]
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = obstacle_data["size"]
		collision.shape = shape
		hazard.add_child(collision)
		
		var visual = ColorRect.new()
		visual.size = obstacle_data["size"]
		visual.position = -obstacle_data["size"] / 2
		visual.color = Color(0.9, 0.1, 0.1, 0.6)  # Red danger zone
		hazard.add_child(visual)
		
		# Connect signal to destroy objects that enter
		hazard.body_entered.connect(_on_hazard_entered)
		
		add_child(hazard)
		
	elif obstacle_data["type"] == "wall":
		# Create a wall obstacle
		var wall = StaticBody2D.new()
		wall.position = obstacle_data["pos"]
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = obstacle_data["size"]
		collision.shape = shape
		wall.add_child(collision)
		
		var visual = ColorRect.new()
		visual.size = obstacle_data["size"]
		visual.position = -obstacle_data["size"] / 2
		visual.color = Color(0.5, 0.5, 0.5, 1.0)  # Gray wall
		wall.add_child(visual)
		
		add_child(wall)

# Handle objects entering hazard zones
func _on_hazard_entered(body):
	if body is RigidBody2D:
		print("Object destroyed by hazard!")
		body.queue_free()

# Clear all dynamic objects from the level
func clear_level():
	for child in get_children():
		# Remove anything that's not the ground, target, or UI
		if child is RigidBody2D or (child is StaticBody2D and child.name != "Ground") or (child is Area2D and child.name != "Target"):
			child.queue_free()

func _input(event):
	# Don't allow input if game is over
	if game_won or game_lost:
		if event is InputEventKey and event.pressed and event.keycode == KEY_R:
			if game_won and current_level < max_level:
				# Advance to next level
				current_level += 1
				load_level(current_level)
			else:
				# Retry current level
				load_level(current_level)
		return
	
	# Number keys select object type
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			selected_object = "box"
			update_ui()
			print("Selected: Regular Box")
		elif event.keycode == KEY_2:
			selected_object = "heavy"
			update_ui()
			print("Selected: Heavy Box")
		elif event.keycode == KEY_3:
			selected_object = "circle"
			update_ui()
			print("Selected: Circle")
		elif event.keycode == KEY_4:
			selected_object = "bouncy"
			update_ui()
			print("Selected: Bouncy Ball")
		elif event.keycode == KEY_R:
			load_level(current_level)
	
	# Mouse click spawns selected object
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if boxes_spawned < box_limit:
				spawn_object(event.position, selected_object)
			else:
				print("No objects remaining! You must work with what you have.")
				check_loss_condition()

func spawn_object(pos: Vector2, object_type: String):
	var new_object = null
	
	# Create different object types with unique physics properties
	if object_type == "box":
		new_object = create_box(pos, 1.0, Color(0.8, 0.2, 0.2), 0.3)  # Normal box
	elif object_type == "heavy":
		new_object = create_box(pos, 3.0, Color(0.3, 0.1, 0.1), 0.8)  # Heavy and high friction
	elif object_type == "circle":
		new_object = create_circle(pos, 1.0, Color(0.2, 0.2, 0.8), 0.1)  # Light and low friction
	elif object_type == "bouncy":
		new_object = create_circle(pos, 0.5, Color(0.8, 0.8, 0.2), 0.0, 0.9)  # Light, no friction, high bounce
	
	if new_object:
		add_child(new_object)
		boxes_spawned += 1
		update_ui()
		print("Spawned " + object_type + " (" + str(boxes_spawned) + "/" + str(box_limit) + " used)")

# Helper function to create box objects with custom properties
func create_box(pos: Vector2, mass: float, color: Color, friction: float = 0.3) -> RigidBody2D:
	var box = RigidBody2D.new()
	box.position = pos
	box.mass = mass
	box.physics_material_override = PhysicsMaterial.new()
	box.physics_material_override.friction = friction
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 64)
	collision.shape = shape
	box.add_child(collision)
	
	var visual = ColorRect.new()
	visual.size = Vector2(64, 64)
	visual.position = Vector2(-32, -32)
	visual.color = color
	box.add_child(visual)
	
	return box

# Helper function to create circular objects with custom properties
func create_circle(pos: Vector2, mass: float, color: Color, friction: float = 0.1, bounce: float = 0.3) -> RigidBody2D:
	var circle = RigidBody2D.new()
	circle.position = pos
	circle.mass = mass
	circle.physics_material_override = PhysicsMaterial.new()
	circle.physics_material_override.friction = friction
	circle.physics_material_override.bounce = bounce
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 32
	collision.shape = shape
	circle.add_child(collision)
	
	# Create a visual circle using ColorRect (simple approach)
	var visual = ColorRect.new()
	visual.size = Vector2(64, 64)
	visual.position = Vector2(-32, -32)
	visual.color = color
	circle.add_child(visual)
	
	return circle

func _on_target_body_entered(body):
	if body is RigidBody2D:
		boxes_in_target += 1
		print("Object in target! Progress: " + str(boxes_in_target) + "/" + str(goal_amount))
		update_ui()
		check_win_condition()

func _on_target_body_exited(body):
	if body is RigidBody2D:
		boxes_in_target -= 1
		print("Object left target. Progress: " + str(boxes_in_target) + "/" + str(goal_amount))
		update_ui()

func check_win_condition():
	if boxes_in_target >= goal_amount and not game_won:
		game_won = true
		print("\n" + "=".repeat(50))
		print("LEVEL " + str(current_level) + " COMPLETE!")
		print("Objects used: " + str(boxes_spawned) + "/" + str(box_limit))
		if current_level < max_level:
			print("Press R to continue to next level")
		else:
			print("CONGRATULATIONS! You completed all levels!")
			print("Press R to replay")
		print("=".repeat(50))
		
		# Change target to gold
		if target_zone:
			var target_rect = target_zone.get_node("ColorRect")
			target_rect.color = Color(1.0, 0.8, 0.0, 0.8)

func check_loss_condition():
	# Check if player used all boxes but hasn't won
	if boxes_spawned >= box_limit and boxes_in_target < goal_amount and not game_won:
		game_lost = true
		print("\n" + "=".repeat(50))
		print("LEVEL FAILED!")
		print("You ran out of objects before reaching the goal.")
		print("Think carefully about placement and object types!")
		print("Press R to retry this level")
		print("=".repeat(50))
		
		# Change target to dark red to show failure
		if target_zone:
			var target_rect = target_zone.get_node("ColorRect")
			target_rect.color = Color(0.6, 0.1, 0.1, 0.7)

func _process(_delta):
	# Continuously check if player should lose
	if not game_won and not game_lost and boxes_spawned >= box_limit:
		# Give physics a moment to settle before declaring loss
		await get_tree().create_timer(2.0).timeout
		if not game_won and boxes_in_target < goal_amount:
			check_loss_condition()
