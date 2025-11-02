extends Node3D

@onready var label_top = $screen/label_top
@onready var label_bottom = $screen/label_bot

@onready var screen = $screen
@onready var light = $light

@onready var material_green = load("res://materials/accept_green.tres")
@onready var material_red = load("res://materials/deny_red.tres")
@onready var material_orange = load("res://materials/query_orange.tres")

@onready var anim = $anim

var is_player_inside = false
var activated = false

func _ready() -> void:
	$"../../../../input_catcher".interact.connect(player_interacted)

func _on_area_body_entered(body: Node3D) -> void:
	if activated:
		return
	if body.is_in_group("player"):
		is_player_inside = true
		screen.material_override = material_green
		light.visible = true

func _on_area_body_exited(body: Node3D) -> void:
	if activated:
		return
	if body.is_in_group("player"):
		is_player_inside = false

func player_interacted():
	if activated or !is_player_inside:
		return
	screen.material_override = material_orange
	anim.play("intro_boot_up")
	label_bottom.text = "Installing..."
	activated = true
