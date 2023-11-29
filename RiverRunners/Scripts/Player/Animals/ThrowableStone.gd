extends Node2D

var stone = load("res://GameComponents/Player/stone.tscn")
var throwableStone = null
const tilewidth: int = 380
const tileheight: int = 190
var pos_original = Vector2.ZERO
var is_throwing = false
var throwGravity = 400
var throwSpeedX = 2.5
var throwSpeedY = 500
var throwTime = 0
var throwoffset = 0
var waterheight = 30 #to adjust where the stone hits the water
var aux_x = 0
var aux_y = 0
var aux1_y = 0
var logNode
var referenceposition = Vector2.ZERO

enum States {IDLE, THROWING, PAUSED}

var current_state = States.IDLE
var previous_state = States.IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	logNode = get_node("../Log")
	Events.connect("otter_position", throw)

	Events.connect("on_dialog_start", onPause)
	Events.connect("on_dialog_end", onResume)

	Events.connect("pause_game", onPause)
	Events.connect("resume_game", onResume)

	#self.connect("area_entered", onAreaEntered)

func throw(otter_position):
	if current_state == States.IDLE and throwableStone == null:
		throwableStone = stone.instantiate()
		add_child(throwableStone)
		throwableStone.visible = false
		throwableStone.z_index += 1
		throwableStone.position = logNode.position
		referenceposition = logNode.position
		pos_original = otter_position
		pos_original.y += throwoffset
		current_state = States.THROWING
		throwTime = 0

func handle_throw(delta):
	throwTime += delta
	if throwableStone.position.y - waterheight <= position.y + referenceposition.y - (tileheight * (throwableStone.position.x - position.x - referenceposition.x)/tilewidth) && throwTime >= 0: 
		#criar variaveis auxiliares para x e para y onde depois guardo no final na position da stone
		aux_x = pos_original.x + tilewidth/2 * throwTime * throwSpeedX
		aux_y = pos_original.y - tileheight/2 * throwTime * throwSpeedX
		aux1_y = aux_y - (throwSpeedY + throwGravity * throwTime * -1) * throwTime
		throwableStone.position = Vector2(aux_x, aux1_y)
		throwableStone.visible = true
	elif throwTime >= 0:
		current_state = States.IDLE
		if not throwableStone == null: 
			#splash animation
			throwableStone.queue_free()
			throwableStone = null

func _process(delta):

	match current_state:
		States.IDLE:
			pass

		States.THROWING:
			handle_throw(delta)

		States.PAUSED:
			pass

func onPause():
	previous_state = current_state
	current_state = States.PAUSED

func onResume():
	current_state = previous_state

#func onAreaEntered(area):
#	if area.has_method("stone_collided"):
#		area.stone_collided()