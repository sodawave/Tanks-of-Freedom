
extends AnimatedSprite

export var player = -1
export var position_on_map = Vector2(0,0)
const MAX_HICCUP_DEPTH = 5
var move_positions = []
var current_map_terrain
var current_map
var health_bar
var icon_shield
var anim
var type = 0
var kills = 0

var life
var max_life
var attack
var plain
var road
var river
var max_ap
var attack_ap
var max_attacks_number
var ap
var attacks_number
var visibility

var group = 'unit'

var explosion_template = preload('res://particle/explosion.xscn')
var explosion_big_template = preload('res://particle/explosion_big.xscn')
var explosion
var floating_damage_template = preload('res://particle/hit_points.xscn')
var floating_damage
var die = false
var parent

var sprite_offset_for_64x64 = Vector2(0,8);

func set_no_ap_idle():
	if ap == 0:
		self.anim.play('idle_no_ap')
	else:
		self.anim.play('move')

func set_ap(value):
	ap = value
	self.set_no_ap_idle()

func get_ap():
	return ap;

func get_player():
	return player

func get_type():
	return type

func get_pos_map():
	return position_on_map

func add_move(position):
	self.move_positions.push_back(position)

func get_initial_pos():
	position_on_map = current_map_terrain.world_to_map(self.get_pos())
	self.add_move(position_on_map)
	return position_on_map

func get_stats():
	return {'life' : life, 'attack' : attack, 'ap' : get_ap(), 'attack_ap': attack_ap, 'attacks_number' : attacks_number}

func set_stats(new_stats):
	life = new_stats.life
	attack = new_stats.attack
	ap = new_stats.ap
	attacks_number = new_stats.attacks_number
	self.update_healthbar()
	self.update_shield()
	self.set_no_ap_idle()

func update_ap(new_ap):
	ap = new_ap
	self.update_shield()
	self.set_no_ap_idle()

func reset_ap():
	ap = max_ap
	attacks_number = max_attacks_number
	self.update_shield()
	self.update_healthbar()
	self.set_no_ap_idle()

func set_pos_map(new_position):
	if new_position.x > position_on_map.x:
		self.set_flip_h(true)
	elif new_position.x < position_on_map.x:
		self.set_flip_h(false)
	if new_position.y < position_on_map.y:
		self.set_flip_h(true)
	elif new_position.y > position_on_map.y:
		self.set_flip_h(false)

	self.set_pos(current_map_terrain.map_to_world(new_position) + sprite_offset_for_64x64)
	self.add_move(position_on_map)
	position_on_map = new_position

func check_hiccup(new_position):
	var depth = MAX_HICCUP_DEPTH
	var count = move_positions.size()
	if count == 0:
		return false

	if MAX_HICCUP_DEPTH > count:
		depth = count

	var start = count - depth - 1
	if start < 0:
		start = 0

	for index in range(start, count - 1):
		if new_position == move_positions[index]:
			return true

	return false

func can_attack():
	if self.ap >= self.attack_ap && self.attacks_number > 0:
		return true
	return false

func can_defend():
	if self.ap >= self.attack_ap:
		return true
	return false

func die():
	self.queue_free()

func set_damaged():
	return

func get_life_status():
	return self.life / (self.max_life * 1.0 )

func update_healthbar():
	var life_status = self.get_life_status()
	var new_frame = floor((1.0 - life_status)*10)
	self.health_bar.set_frame(new_frame)

func show_explosion():
	explosion = explosion_template.instance()
	explosion.unit = self
	self.add_child(explosion)

func show_big_explosion():
	explosion = explosion_big_template.instance()
	explosion.unit = self
	self.add_child(explosion)
	current_map.shake_camera()

func clear_explosion():
	self.remove_child(explosion)
	explosion.queue_free()
	if die:
		parent.remove_child(self)
		self.die()

func show_floating_damage(amount):
	floating_damage = floating_damage_template.instance()
	floating_damage.set_text(str(amount))
	floating_damage.unit = self
	self.add_child(floating_damage)

func clear_floating_damage():
	self.remove_child(floating_damage)
	floating_damage.queue_free()

func die_after_explosion(ysort):
	die = true
	parent = ysort
	self.show_big_explosion()

func update_shield():
	if ap >= attack_ap:
		self.icon_shield.show()
	else:
		self.icon_shield.hide()

func score_kill():
	kills = kills + 1

func takeAllAP():
	self.ap = 0
	self.icon_shield.hide()
	self.set_no_ap_idle()

func fix_initial_pos():
	self.set_pos(self.get_pos() + sprite_offset_for_64x64)

func _ready():
	self.add_to_group("units")
	self.anim = self.get_node("anim")
	if self.get_node("/root/game"):
		self.current_map_terrain = self.get_node("/root/game").current_map_terrain
		self.current_map = self.get_node("/root/game").current_map
	self.health_bar = self.get_node("health")
	self.icon_shield = self.get_node("shield")
	self.fix_initial_pos()
	self.anim.play("move")
	pass


