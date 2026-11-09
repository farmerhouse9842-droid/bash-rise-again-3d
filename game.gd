extends Node3D

# Entire prototype is generated at runtime; no external models are needed.
const SPEED := 5.5
const JUMP := 8.5
const GRAVITY := 20.0
var player: CharacterBody3D
var camera: Camera3D
var enemy: Node3D
var bridge: Node3D
var bridge_collision: CollisionShape3D
var level := 1
var lives := 3
var score := 0
var stage := 0
var bridge_ready := false
var failed_once := false
var move_dir := Vector2.ZERO
var jump_requested := false
var message_label: Label
var stats_label: Label
var action_button: Button
var hint_label: Label
var finish_pos := Vector3(0, 4.4, -26)
var checkpoint := Vector3(0, 1.2, 5)
var event_timer := 0.0
var in_menu := true
var paused_game := false
var menu_panel: PanelContainer
var hero_visual: Node3D
var fall_time := 0.0
var fall_spin := 0.0
var animation_clock := 0.0
var hero_model: Node3D
const MAX_LEVEL := 500
const SAVE_PATH := "user://bash_save.cfg"
var toast_timer := 0.0
var fall_recovery := 0.0
var knockback := Vector3.ZERO
var ui_buttons: Array[Button] = []
var menu_subtitle: Label
var style_button: Button
var low_graphics := true
var obstacles: Array[Vector3] = []
var obstacle_cooldown := 0.0

func _ready() -> void:
	_setup_world()
	_setup_ui()
	_load_progress()
	_build_level()
	_show_menu()

func _material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.85
	return m

func _block(parent: Node3D, pos: Vector3, size: Vector3, color: Color, solid := true) -> Node3D:
	var root: Node3D = StaticBody3D.new() if solid else Node3D.new()
	parent.add_child(root)
	root.position = pos
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	mesh.mesh = cube
	mesh.material_override = _material(color)
	root.add_child(mesh)
	if solid:
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		root.add_child(col)
	return root

func _setup_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.57, 0.78, 0.95)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.9, 1)
	env.ambient_light_energy = 0.85
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	sun.light_energy = 1.15
	add_child(sun)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 65
	add_child(camera)
	player = CharacterBody3D.new()
	player.name = "Hero"
	add_child(player)
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.7
	col.shape = capsule
	player.add_child(col)
	hero_visual = Node3D.new()
	player.add_child(hero_visual)
	# Imported black-jacket hero. The mesh is static; procedural motion is a placeholder for a future skeletal rig.
	var hero_scene: PackedScene = load("res://assets/bash_hero_black_jacket.glb")
	if hero_scene != null:
		hero_model = hero_scene.instantiate() as Node3D
		hero_visual.add_child(hero_model)
		hero_model.scale = Vector3.ONE * 0.62
		hero_model.position.y = -0.86
	else:
		_make_person(hero_visual, Color(0.08, 0.08, 0.10), Color(0.94, 0.68, 0.46))

func _make_person(root: Node3D, shirt: Color, skin: Color) -> void:
	_block(root, Vector3(0, 0.1, 0), Vector3(0.75, 0.85, 0.4), shirt, false)
	_block(root, Vector3(0, 0.8, 0), Vector3(0.52, 0.52, 0.52), skin, false)
	_block(root, Vector3(-0.22, -0.57, 0), Vector3(0.22, 0.55, 0.25), Color(0.12, 0.16, 0.25), false)
	_block(root, Vector3(0.22, -0.57, 0), Vector3(0.22, 0.55, 0.25), Color(0.12, 0.16, 0.25), false)
	_block(root, Vector3(-0.51, 0.1, 0), Vector3(0.2, 0.72, 0.22), skin, false)
	_block(root, Vector3(0.51, 0.1, 0), Vector3(0.2, 0.72, 0.22), skin, false)

func _clear_stage() -> void:
	var old := get_node_or_null("Stage")
	if old:
		remove_child(old)
		old.queue_free()

func _build_level() -> void:
	_clear_stage()
	stage = 0
	bridge_ready = false
	failed_once = false
	lives = 3
	fall_recovery = 0.0
	fall_time = 0.0
	obstacles.clear()
	checkpoint = Vector3(0, 1.2, 5)
	player.position = checkpoint
	player.velocity = Vector3.ZERO
	var root := Node3D.new()
	root.name = "Stage"
	add_child(root)
	var chapter := int((level - 1) / 50)
	var ground_colors := [Color(0.34,0.65,0.37), Color(0.66,0.53,0.30), Color(0.37,0.55,0.66), Color(0.47,0.65,0.43), Color(0.6,0.48,0.57)]
	var ground_color: Color = ground_colors[chapter % ground_colors.size()]
	_block(root, Vector3(0, -0.5, 5), Vector3(9, 1, 18), ground_color)
	_block(root, Vector3(0, 1.25, -7.5), Vector3(7, 0.5, 7), Color(0.68, 0.67, 0.61))
	_block(root, Vector3(0, 3.7, -22), Vector3(9, 0.7, 12), Color(0.38, 0.72, 0.43))
	for i in range(5):
		_block(root, Vector3(0, 0.18 + i * 0.26, -2.7 - i * 0.85), Vector3(4, 0.45, 0.85), Color(0.69, 0.64, 0.55))
	# Chapter-based visual changes and moving hazards are intentionally lightweight.
	var variation := (level - 1) % 10
	for j in range(variation % 4):
		var x := -1.6 + float(j) * 1.1
		var z := 3.0 - float(j) * 2.0
		_block(root, Vector3(x, 0.32, z), Vector3(0.25, 0.65, 1.8), Color(0.60, 0.42, 0.14), false)
		obstacles.append(Vector3(x, 0.6, z))
	# Gap between middle and upper platforms; bamboo becomes the bridge.
	bridge = _block(root, Vector3(0, 2.5, -14.5), Vector3(2.3, 0.4, 8.0), Color(0.72, 0.52, 0.19))
	bridge.visible = false
	bridge_collision = bridge.get_node("CollisionShape3D") as CollisionShape3D
	bridge_collision.disabled = true
	# Bamboo pieces that the villain leaves behind.
	for i in range(3):
		_block(root, Vector3(-2.4 + i * 0.5, 1.65, -8.1), Vector3(0.17, 0.17, 2.2), Color(0.65, 0.49, 0.14), false)
	enemy = Node3D.new()
	root.add_child(enemy)
	enemy.position = Vector3(2.3, 2.25, -7.5)
	_make_person(enemy, Color(0.8, 0.16, 0.18), Color(0.91, 0.61, 0.4))
	_block(enemy, Vector3(-0.65, 0.0, 0), Vector3(0.15, 0.15, 2.3), Color(0.69, 0.5, 0.12), false)
	_block(root, finish_pos + Vector3(0, -0.3, 0), Vector3(2.3, 0.3, 2.3), Color(1, 0.78, 0.15), false)
	for i in range(8):
		var x := -7.0 if i % 2 == 0 else 7.0
		_block(root, Vector3(x, 1, 6 - i * 4), Vector3(0.4, 2, 0.4), Color(0.4, 0.3, 0.18), false)
		_block(root, Vector3(x, 2.4, 6 - i * 4), Vector3(1.6, 1.7, 1.6), Color(0.15, 0.5, 0.22), false)
	_update_stats()
	_toast("CHAPTER %d  |  LEVEL %d / 500" % [chapter + 1, level], 4)

func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui)
	stats_label = Label.new()
	stats_label.position = Vector2(20, 25)
	stats_label.add_theme_font_size_override("font_size", 27)
	ui.add_child(stats_label)
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	message_label.position = Vector2(18, 95)
	message_label.size = Vector2(684, 100)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 24)
	ui.add_child(message_label)
	hint_label = Label.new()
	hint_label.position = Vector2(18, 195)
	hint_label.size = Vector2(684, 65)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 21)
	ui.add_child(hint_label)
	var controls := [
		["LEFT", Vector2(35, 1040), Vector2(-1, 0)],
		["RIGHT", Vector2(185, 1040), Vector2(1, 0)],
		["UP", Vector2(110, 950), Vector2(0, -1)],
		["DOWN", Vector2(110, 1130), Vector2(0, 1)]
	]
	for spec in controls:
		var b := Button.new()
		b.text = spec[0]
		b.position = spec[1]
		b.size = Vector2(125, 85)
		b.add_theme_font_size_override("font_size", 23)
		ui.add_child(b)
		ui_buttons.append(b)
		var d: Vector2 = spec[2]
		b.button_down.connect(func(): move_dir += d)
		b.button_up.connect(func(): move_dir -= d)
	var jump := Button.new()
	jump.text = "JUMP"
	jump.position = Vector2(545, 1050)
	jump.size = Vector2(145, 95)
	jump.add_theme_font_size_override("font_size", 27)
	ui.add_child(jump)
	ui_buttons.append(jump)
	jump.pressed.connect(func(): jump_requested = true)
	action_button = Button.new()
	action_button.text = "USE BAMBOO"
	action_button.position = Vector2(455, 940)
	action_button.size = Vector2(235, 85)
	action_button.add_theme_font_size_override("font_size", 23)
	ui.add_child(action_button)
	ui_buttons.append(action_button)
	action_button.pressed.connect(_use_bamboo)
	var retry := Button.new()
	retry.text = "RETRY"
	retry.position = Vector2(550, 25)
	retry.size = Vector2(140, 62)
	ui.add_child(retry)
	ui_buttons.append(retry)
	retry.pressed.connect(_retry)
	var home := Button.new()
	home.text = "HOME"
	home.position = Vector2(545, 100)
	home.size = Vector2(145, 58)
	ui.add_child(home)
	ui_buttons.append(home)
	home.pressed.connect(_show_menu)
	menu_panel = PanelContainer.new()
	menu_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(menu_panel)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.029, 0.043, 0.93)
	panel_style.border_color = Color(0.88, 0.68, 0.27)
	panel_style.set_border_width_all(5)
	panel_style.set_corner_radius_all(24)
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	var center := CenterContainer.new()
	menu_panel.add_child(center)
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(550, 0)
	v.add_theme_constant_override("separation", 22)
	center.add_child(v)
	var title := Label.new()
	title.text = "BASH: RISE AGAIN 3D"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1.0, 0.79, 0.34))
	v.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "FALL. LAUGH. RISE AGAIN.\n500 LEVELS  |  10 CHAPTERS  |  OFFLINE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	v.add_child(subtitle)
	menu_subtitle = subtitle
	for caption in ["PLAY / CONTINUE", "RESTART LEVEL", "HOW TO PLAY", "GRAPHICS: LOW", "QUIT"]:
		var btn := Button.new()
		btn.text = caption
		btn.custom_minimum_size = Vector2(500, 86)
		btn.add_theme_font_size_override("font_size", 25)
		v.add_child(btn)
		var button_style := StyleBoxFlat.new()
		button_style.bg_color = Color(0.14, 0.15, 0.19)
		button_style.border_color = Color(0.80, 0.61, 0.25)
		button_style.set_border_width_all(2)
		button_style.set_corner_radius_all(16)
		btn.add_theme_stylebox_override("normal", button_style)
		v.add_child(btn)
		if caption == "PLAY / CONTINUE":
			btn.pressed.connect(_start_game)
		elif caption == "RESTART LEVEL":
			btn.pressed.connect(_restart_level)
		elif caption == "HOW TO PLAY":
			btn.pressed.connect(func(): subtitle.text = "MOVE + JUMP to climb.\nDodge bamboo, recover from falls.\nUSE BAMBOO to build a bridge.")
		elif caption == "GRAPHICS: LOW":
			style_button = btn
			btn.pressed.connect(_toggle_graphics)
		else:
			btn.pressed.connect(func(): get_tree().quit())

func _toggle_graphics() -> void:
	low_graphics = not low_graphics
	style_button.text = "GRAPHICS: LOW" if low_graphics else "GRAPHICS: HIGH"
	get_viewport().scaling_3d_scale = 0.75 if low_graphics else 1.0

func _update_stats() -> void:
	stats_label.text = "LV %d/500   LIFE %d   SCORE %d" % [level, lives, score]

func _show_menu() -> void:
	in_menu = true
	move_dir = Vector2.ZERO
	menu_panel.visible = true
	for button in ui_buttons: button.visible = false

func _start_game() -> void:
	in_menu = false
	menu_panel.visible = false
	for button in ui_buttons: button.visible = true

func _restart_level() -> void:
	_build_level()
	_start_game()

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		level = clampi(int(cfg.get_value("progress", "level", 1)), 1, MAX_LEVEL)
		score = maxi(0, int(cfg.get_value("progress", "score", 0)))

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "level", level)
	cfg.set_value("progress", "score", score)
	cfg.save(SAVE_PATH)

func _toast(t: String, duration := 3.0) -> void:
	message_label.text = t
	toast_timer = duration

func _retry() -> void:
	player.position = checkpoint
	player.velocity = Vector3.ZERO
	hero_visual.rotation = Vector3.ZERO
	if hero_model: hero_model.position.y = -0.86
	fall_recovery = 0.0
	fall_time = 0.0
	_toast("Try again. Turn the obstacle into a solution!", 3)

func _fall() -> void:
	lives -= 1
	failed_once = true
	_update_stats()
	if lives <= 0:
		lives = 3
		_toast("FAILED! Rise again. Lives restored.", 4)
	else:
		_toast("The villain stopped you! Try again.", 3)
	_retry_position()

func _retry_position() -> void:
	player.position = checkpoint
	player.velocity = Vector3.ZERO
	hero_visual.rotation = Vector3.ZERO
	if hero_model: hero_model.position.y = -0.86
	fall_recovery = 0.0
	fall_time = 0.0
	_update_stats()

func _use_bamboo() -> void:
	if bridge_ready:
		_toast("Bridge is ready. Cross and reach the gold tile!", 3)
		return
	if player.position.distance_to(Vector3(0, 2, -8)) > 6:
		_toast("Get near the bamboo on the middle platform.", 3)
		return
	if not failed_once:
		_toast("Find the obstacle first. The villain is watching!", 3)
		return
	bridge_ready = true
	bridge.visible = true
	bridge_collision.set_deferred("disabled", false)
	score += 100
	_update_stats()
	_toast("SMART! You built a bridge from the bamboo. +100", 4)

func _physics_process(delta: float) -> void:
	if in_menu:
		return
	if obstacle_cooldown > 0.0:
		obstacle_cooldown -= delta
	if fall_recovery > 0.0:
		fall_recovery -= delta
		if fall_recovery <= 0.0:
			_retry_position()
		return
	if fall_time > 0.0:
		fall_time -= delta
		# Comic tumble: a fast sideways tip and wobble after the bamboo hit.
		hero_visual.rotation.z = sin((1.3 - fall_time) * 8.0) * 1.05
		hero_visual.rotation.x = sin((1.3 - fall_time) * 11.0) * 0.42
	else:
		hero_visual.rotation = hero_visual.rotation.lerp(Vector3.ZERO, minf(1.0, delta * 8.0))
	var d := move_dir
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): d.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): d.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): d.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): d.y += 1
	d = d.limit_length(1)
	animation_clock += delta * (11.0 if d.length() > 0.1 else 2.0)
	if hero_model and fall_time <= 0.0:
		# Small walking bounce and idle breathing; not skeletal limb animation.
		hero_model.position.y = -0.86 + (absf(sin(animation_clock)) * 0.055 if d.length() > 0.1 else sin(animation_clock) * 0.012)
	player.velocity.x = d.x * SPEED
	player.velocity.z = d.y * SPEED
	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	if (jump_requested or Input.is_key_pressed(KEY_SPACE)) and player.is_on_floor():
		player.velocity.y = JUMP
	jump_requested = false
	player.move_and_slide()
	if d.length() > 0.05:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-d.x, -d.y), delta * 8)
	# Villain pushes the player away when approaching the bamboo obstacle.
	if not failed_once and player.position.distance_to(Vector3(0, 2, -8)) < 3.0:
		failed_once = true
		_toast("OUCH! Villain used bamboo! Solve it and rise again.", 4)
		player.velocity = Vector3.ZERO
		fall_time = 1.3
		fall_recovery = 1.3
		lives -= 1
		if lives <= 0:
			lives = 3
		_update_stats()
	if player.position.y < -7:
		_fall()
	for obstacle in obstacles:
		if obstacle_cooldown <= 0.0 and player.position.distance_to(obstacle) < 0.85:
			obstacle_cooldown = 2.0
			fall_time = 1.3
			fall_recovery = 1.3
			lives -= 1
			if lives <= 0: lives = 3
			_update_stats()
			_toast("BAMBOO BONK! Get up and keep going!", 2.0)
			break
	if player.position.distance_to(finish_pos) < 2.6 and bridge_ready:
		score += 250
		if level >= MAX_LEVEL:
			_toast("YOU FINISHED ALL 500 LEVELS!", 8)
			_save_progress()
			_show_menu()
		else:
			level += 1
			_save_progress()
			_build_level()
	if toast_timer > 0:
		toast_timer -= delta
		if toast_timer <= 0:
			message_label.text = ""
	hint_label.text = "Use bamboo to bridge the gap!" if failed_once and not bridge_ready else ("Cross the bridge and reach the gold tile!" if bridge_ready else "Move UP to climb. Jump over obstacles!")
	var desired := player.global_position + Vector3(0, 7.5, 12)
	camera.global_position = camera.global_position.lerp(desired, min(delta * 4, 1.0))
	camera.look_at(player.global_position + Vector3(0, 0.5, -3), Vector3.UP)
