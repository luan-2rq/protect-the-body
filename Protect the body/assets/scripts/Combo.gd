extends Control

var counter : int = 0
var first : bool = true
var combo_show : bool = false
var mult_show : bool = false

func _update_mult() -> void:
	counter += 1
	
	if first:
		_appear($Combo_Text/AnimationPlayer)
		first = false
		combo_show = true
	else:
		_disappear($Multiplier/AnimationPlayer)
		mult_show = false
		yield($Multiplier/AnimationPlayer, "animation_finished")
	
	$Multiplier.text = ("x%s" % counter)
	_appear($Multiplier/AnimationPlayer)
	mult_show = true
	
	Global.velocity_modifier += 0.1
	$Timer.start()

func _reset_mult() -> void:
	counter = 0
	Global.velocity_modifier = 1.0
	
	if combo_show:
		_disappear($Combo_Text/AnimationPlayer)
		combo_show = false
	
	if mult_show:
		_disappear($Multiplier/AnimationPlayer)
		mult_show = false
		yield($Multiplier/AnimationPlayer, "animation_finished")
		$Multiplier.text = ("x%s" % counter)
	elif !first:
		$Multiplier.text = ("x%s" % counter)
	
	first = true

func _appear(child) -> void:
	child.play("Appearing")

func _disappear(child) -> void:
	child.play("Disappearing")

func _on_Timer_timeout() -> void:
	_reset_mult()
