extends RigidBody3D


# can the player roll etc
var rigid = false
var playerAcceleration = 0.4
var playerAccelerationForce = 4
var jumpForce = 9
var maxPlayerVelocity = 20.0

var inputVector : Vector2 = Vector2.ZERO
var jumpRequested : bool = false

func _ready() -> void:
	setRigid(true)


func _physics_process(delta: float) -> void:
	checkMovementInput()


func checkMovementInput():
	inputVector = Input.get_vector("left", "right", "backward", "forward")
	inputVector = inputVector.normalized()

	if Input.is_action_just_pressed("jump"):
		jumpRequested = true

	if Input.is_action_just_pressed("toggle rigid"):
		setRigid(!rigid)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:

	## TODO - make acceleration less powerful at higher speeds

	# we split it between directly modifying linear_velocity and also applying a central force
	# as the force takes friction into account. Therefore while grounded, the direct modification
	# only really is shown. However while airborne you experience both.
	
	var movementVector = inputVector * playerAcceleration

	state.linear_velocity.x -= movementVector.x
	state.linear_velocity.z += movementVector.y

	var forcesToApply = Vector3(-movementVector.x, 0.0, movementVector.y) * playerAccelerationForce
	state.apply_central_force(forcesToApply)

	if jumpRequested:
		state.apply_central_impulse(Vector3.UP * jumpForce)
		jumpRequested = false

	var currentVelocity = state.linear_velocity
	currentVelocity.x = clampf(currentVelocity.x, -maxPlayerVelocity, maxPlayerVelocity)
	currentVelocity.z = clampf(currentVelocity.z, -maxPlayerVelocity, maxPlayerVelocity)

	state.linear_velocity = currentVelocity
	

# TODO - needs to make player stand back up
func setRigid(makeRigid : bool):
	self.axis_lock_angular_x = makeRigid
	self.axis_lock_angular_z = makeRigid
	rigid = makeRigid
