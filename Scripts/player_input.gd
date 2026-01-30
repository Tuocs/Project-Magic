extends MultiplayerSynchronizer

@onready var player = $".."
@onready var cast_ui = $"../Cast UI"
var input_dir
@export var singleplayer = false



func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if singleplayer:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.rotation.y -= event.relative.x * player.mouse_sensitivity
		player.rotation.y = wrapf(player.rotation.y, 0.0, TAU)
		player.cam.get_parent().get_parent().rotation.x -= event.relative.y * player.mouse_sensitivity
		player.cam.get_parent().get_parent().rotation.x = clamp(player.cam.get_parent().get_parent().rotation.x, -PI/2, PI/4)
	
func _process(delta: float) -> void:
	if singleplayer:
		singleplayer_process(delta)
	else:
		multiplayer_process(delta)
	if Globals.toggle_spell_window:
		if Input.is_action_just_pressed("edit_magic") && cast_ui.is_active:
			cast_ui.deactivate()
		elif Input.is_action_just_pressed("edit_magic"):
			cast_ui.activate()
	else:
		if Input.is_action_just_released("edit_magic"):
			cast_ui.deactivate()
		elif Input.is_action_just_pressed("edit_magic"):
			cast_ui.activate()

func prepare_spell(_spell: Globals.spell_type, _mods: Array[bool]):
	if singleplayer:
		var spell_cost = 1
		spell_cost += Globals.count_array_values(_mods,true)
		player.set_spell_type(_spell)
		player.set_spell_mods(_mods)
		player.spell_cost = spell_cost
	else:
		finish_spell.rpc(_spell, _mods)

func singleplayer_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		player.do_jump = true
	if Input.is_action_just_pressed("magic_cast") && !cast_ui.is_active:
		player.do_cast = true

func multiplayer_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("magic_cast") && !cast_ui.is_active:
		cast.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true

@rpc("call_local")
func cast():
	if multiplayer.is_server():
		player.do_cast = true

@rpc("call_local")
func finish_spell(_spell: Globals.spell_type, _mods: Array[bool]):
	if multiplayer.is_server():
		var spell_cost = 1
		spell_cost += Globals.count_array_values(_mods,true)
		player.set_spell_type(_spell)
		player.set_spell_mods(_mods)
		player.spell_cost = spell_cost
