extends CharacterBody3D
class_name  Unit

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_timer: float = 0.0
var knockback_duration: float = 0.2
@export var max_health: int = 100
var current_health
enum element_type {NONE, RED, YELLOW, BLUE, GREEN }
var element_dmg_multipliers: Dictionary[element_type, int] = { element_type.NONE:1, element_type.RED:1, element_type.YELLOW:1, element_type.BLUE:1, element_type.GREEN:1}
@export var element_colors: Array[Color] = [Color(), Color(1.0, 0.0, 0.0, 1.0), Color(1.0, 1.0, 0.0, 1.0), Color(0.0, 0.0, 1.0, 1.0), Color(0.0, 1.0, 0.0, 1.0)]
@export var shield_type: element_type
var shield_obj: Node3D
@onready var shield_scene = preload("res://Prefabs/shield.tscn")
@export var max_mana: float = 10
var current_mana: float = 5
@export var mana_regen: float = 1

func _ready() -> void:
	current_health = max_health
	current_mana = max_mana
	if shield_type != element_type.NONE:
		give_shield(shield_type)

func _process(delta: float) -> void:
	current_mana = clamp(current_mana + (mana_regen * delta), 0, max_mana)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	combine_move_and_knock(delta)

func combine_move_and_knock(delta: float):
	if knockback_timer > 0:
		velocity = velocity.lerp(knockback_velocity, knockback_timer/knockback_duration)
		knockback_timer -= delta
	move_and_slide()

func apply_knockback(source_position: Vector3, power: float = 5):
	knockback_velocity = ((global_position - source_position).normalized()+Vector3(0,1,0)) * power
	knockback_timer = knockback_duration

func give_shield(type: element_type):
	shield_type = type
	if shield_obj == null:
		shield_obj = shield_scene.instantiate()
		add_child(shield_obj)
	var color = element_colors[type]
	color.a = 0.5
	set_color(color, shield_obj.get_child(0))
	shield_obj.scale = scale*1.2
	shield_obj.position = Vector3(0,1,0)

func destroy_shield():
	shield_type = element_type.NONE
	if shield_obj != null:
		shield_obj.queue_free()

func hit(dmg_ammount: int = 1000, dmg_type: element_type = element_type.NONE, piercing: bool = false):
	if shield_type == element_type.NONE:
		take_damage(dmg_ammount * element_dmg_multipliers[dmg_type])
		print("hit enemy")
	elif shield_type == dmg_type && piercing:
		print("hit shield")
		destroy_shield()
	else:
		print("hit blocked")
	
func take_damage(ammount: int):
	current_health -= ammount
	update_hp()
	if current_health <= 0:
		kill()

func update_hp():
	pass

func set_element_dmg_multipliers(N: int, R: int, Y: int, B: int, G: int):
	element_dmg_multipliers[element_type.NONE]=N
	element_dmg_multipliers[element_type.RED]=R
	element_dmg_multipliers[element_type.YELLOW]=Y
	element_dmg_multipliers[element_type.BLUE]=B
	element_dmg_multipliers[element_type.GREEN]=G
	
func set_color(color: Color, target: MeshInstance3D = $MeshInstance3D):
	var material = target.get_active_material(0)
	if material == null:
		material = StandardMaterial3D.new()
	else:
		material = material.duplicate() # Create a unique copy of the material
	material.albedo_color = color
	target.material_override = null
	target.set_surface_override_material(0, material) # Assign the unique material back
	print("origonal ", target.get_active_material(0).albedo_color, "target ", color)

func kill():
	queue_free()
