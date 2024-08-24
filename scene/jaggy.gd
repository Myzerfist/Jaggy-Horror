extends CharacterBody3D

@onready var navigation_agent_3d = $NavigationAgent3D
var SPEED = 6

func _physics_process(delta: float) -> void:
	var c_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity = (next_location - c_location).normalized() * SPEED

	velocity = new_velocity
	move_and_slide()

func update_target_location(target_location):
	navigation_agent_3d.set_target_position(target_location)
