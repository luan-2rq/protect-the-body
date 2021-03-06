extends KinematicBody2D
class_name Enemy

export (int) var speed
export (AudioStream) var die_sfx

var rng = RandomNumberGenerator.new()
var resolution = OS.get_window_size()
var acel
var vetor = Vector2()
var plain
var side
var initPos = Vector2()
var state
var raio
var M
var ang
var amp
var t = 0
var theta = 0
var points_mult
var inside_window : bool

signal die

func _ready():
	$AudioStreamPlayer2D.stream = die_sfx
	$AnimationPlayer.play("IDLE")
	
	rng.seed = 300
	rng.randomize()
	
	plain = rng.randi_range(1,4)
	side = rng.randi_range(0,1)
	match plain:
		1:
			if side == 0:
				initPos.x = rng.randf_range(0,resolution.x/2.0)
				initPos.y = -20
			else:
				initPos.x = -20
				initPos.y = rng.randf_range(0,resolution.y/2.0)
		2:
			if side == 0:
				initPos.x = rng.randf_range(resolution.x/2.0,resolution.x)
				initPos.y = -20
			else:
				initPos.x = resolution.x + 20.0
				initPos.y = rng.randf_range(resolution.y/2.0,resolution.y)
		3:
			if side == 0:
				initPos.x = rng.randf_range(0,resolution.x/2.0)
				initPos.y = resolution.y + 20
			else:
				initPos.x = -20
				initPos.y = rng.randf_range(resolution.y/2.0,resolution.y)
		4:
			if side == 0:
				initPos.x = rng.randf_range(resolution.x/2.0,resolution.x)
				initPos.y = resolution.y + 20
			else:
				initPos.x = resolution.x + 20
				initPos.y = rng.randf_range(resolution.y/2.0,resolution.y)
	
	self.position = initPos
	vetor = (resolution/2.0 - self.position).normalized()
	acel = vetor*(speed)
	
	ang = acel.angle()
	M = Transform2D(Vector2(cos(ang),-sin(ang)),Vector2(sin(ang),cos(ang)),self.position)
	
	$Area2D.connect("mouse_entered", self, "_on_Area2D_mouse_entered")

func _physics_process(delta):
	self.position = parametric_function(state, delta)

func parametric_function(state, delta):
	t = t + delta*speed
	match state:
		1:
			return self.position + acel
		2:
			return self.position + Vector2(raio*cos(t) + acel.x, raio*sin(t) + acel.y)
		3:
			return Vector2(M[0].x * 10.0*t + M[0].y * raio*sin(t/2) + M[2].x,
							M[1].x * 10.0*t + M[1].y * raio*sin(t/2) + M[2].y)
		4:
			theta += 0.3 * delta
			amp -= 5 * delta
			return Vector2(resolution.x / 2, resolution.y / 2) - Vector2(amp*(sin(5*theta)*cos(theta) + 2*cos(theta)),
																		 (amp*(sin(5*theta)*sin(theta) + 2*sin(theta))))
		5:
			return
		6:
			return Vector2(10*t,100.0*4.0/10 *(t-10/2.0 * floor(2.0*t/10 + 0.5))*pow(-1,floor(2.0*t/10 + 0.5)))

func die(mult = 1):
	$AudioStreamPlayer2D.playing = true
	$Area2D.call_deferred("free") #buga algumas vezes
	$AnimationPlayer.play("die")
	points_mult = mult
	var points = preload("res://assets/HUD/Points/Point animation.tscn").instance()
	var explosion = preload("res://assets/scenes/Explosion.tscn").instance()
	var particle_color = explosion.get_node("Particles2D").get_process_material().get_color_ramp().get_gradient()
	#for i in particle_color.get_point_count():
	#	print(particle_color.get_color(i))
	#particle_color.set_color(1,"green")
	add_child(points)
	add_child(explosion)
	points.get_node("AnimationPlayer").connect("animation_finished", self, "_on_Points_Animation_finished")
	points.get_node("AnimationPlayer").play("IDLE")
	
	emit_signal("die")
	$CollisionShape2D.set_deferred("disabled", true)
	$CPUParticles2D.set_deferred("visible", false)
	set_physics_process(false)

func _restart():
	self.position = initPos

func _on_Points_Animation_finished(IDLE):
	call_deferred("free")

func _on_Area2D_mouse_entered():
	if Global.ninja:
		self.die()
