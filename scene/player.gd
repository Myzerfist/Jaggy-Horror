extends CharacterBody3D


var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera: Camera3D = $head/Camera3D
@onready var head: Node3D = $head
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const bob_freq = 2.0
const bob_amp = 0.09
var t_bob = 0.0
const SENSITIVITY = 0.01
var sprinting = false
var stamina = 10
@onready var label: Label = $"../Control/Label"
@onready var jaggy: CharacterBody3D = $"../Jaggy"
var deaths = 0
@onready var label_2: Label = $"../Control/Label2"

func save_game():
	var data = {
		"deaths": deaths
	}
	var file = FileAccess.open("user://save.owlstudios", FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()
	return data

func load_game():
	if FileAccess.file_exists("user://save.owlstudios"):
		var file = FileAccess.open("user://save.owlstudios", FileAccess.READ)
		var data = {}
		data = JSON.parse_string(file.get_line())
		deaths = data.values()[0]
	else:
		save_game()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	load_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func is_caught():
	save_game()
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("shift"):
		if sprinting == true:
			SPEED -= 5.0
			sprinting = false
			if camera.fov > 75:
				camera.fov = 75
		elif sprinting == false and stamina > 0:
			SPEED += 5.0
			sprinting = true
			if camera.fov < 85:
				camera.fov = 85
	if sprinting == true:
		animation_player.speed_scale = 1.2
		stamina -= 0.05
		print(stamina)
		if stamina <= 0:
			sprinting = false
			SPEED -= 5.0
	if sprinting == false:
		animation_player.speed_scale = 1.0
	
	if sprinting == false and stamina < 10:
		stamina += 0.03
		print(stamina)
	
	label.text = "Stamina: " + str(stamina)
	label_2.text = "Deaths: " + str(deaths)
	print(deaths)
	var input_dir := Input.get_vector("right", "left", "back", "forward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		animation_player.play("head_bob")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		animation_player.stop()
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	deaths += 1
	is_caught()
