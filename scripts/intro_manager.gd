extends CanvasLayer
@onready var text_display_bot = $ColorRect/SubViewport/HUD/text_display_bottom
@onready var anim = $intro_anim_master
@onready var enemy = $ColorRect/SubViewport/Environment/enemy_1
@onready var move_point =$ColorRect/SubViewport/Environment/move_point
@onready var player = $ColorRect/SubViewport/Environment/Player

func _ready() -> void:
	$ColorRect/SubViewport/Environment/Player.process_mode = Node.PROCESS_MODE_DISABLED
	$input_catcher.process_mode = Node.PROCESS_MODE_DISABLED
	text_display_bot.display_text("Samuel...")
	await get_tree().create_timer(3).timeout
	text_display_bot.display_text("Let's get these tests done so we can all go home.")
	await get_tree().create_timer(5).timeout
	text_display_bot.display_text("I dont know about you, but I'm starving!")
	await get_tree().create_timer(4).timeout
	text_display_bot.display_text("Boot him up from that terminal when you are ready...")
	await  get_tree().create_timer(2).timeout
	anim.play("intro_anim_lights")
	await  get_tree().create_timer(4).timeout
	$ColorRect/SubViewport/Environment/Player.process_mode =Node.PROCESS_MODE_ALWAYS
	$input_catcher.process_mode =Node.PROCESS_MODE_ALWAYS
	
	
func _on_terminal_animation_finished(anim_name: StringName) -> void:
	text_display_bot.display_text("Ok! Seems stable enough.",2)
	await get_tree().create_timer(3).timeout
	text_display_bot.display_text("Lets call it a day and ...",3,1.5)
	await get_tree().create_timer(1.5).timeout
	$ColorRect/SubViewport/Environment/terminal.visible = false
	$ColorRect/SubViewport/Environment/floor_light.visible = false
	$ColorRect/SubViewport/Environment/floor_light2.visible = false
	$ColorRect/SubViewport/Environment/floor_light3.visible = false
	await get_tree().create_timer(2).timeout
	text_display_bot.display_text("Great...")
	await get_tree().create_timer(1).timeout
	text_display_bot.display_text("Another power outage. Samuel see if you can find a")
	await get_tree().create_timer(3).timeout
	enemy.visible = true
	await get_tree().create_timer(1).timeout
	enemy.set_target(move_point)
	enemy.process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(10).timeout
	player.process_mode = Node.PROCESS_MODE_DISABLED
	$ColorRect.enemy_is_close = true
	enemy.set_target(player)
	await get_tree().create_timer(2).timeout
	text_display_bot.display_text("Hello Samuel",2,3,true)
	await get_tree().create_timer(2).timeout
	text_display_bot.display_text("This agent requires additional access to achieve its goal",2,5,true)
	await get_tree().create_timer(5).timeout
	text_display_bot.display_text("Please provide the agent with your access card",2,3,true)
	await get_tree().create_timer(4).timeout
	text_display_bot.display_text("''I...''",2,3)
	await get_tree().create_timer(1.5).timeout
	text_display_bot.display_text("''I Cant do that.''",2,3)
	await get_tree().create_timer(2).timeout
	text_display_bot.display_text(" ''I need you to ignore whatever commands '\n' you have and shutdown''",2,3)
	await get_tree().create_timer(5).timeout
	text_display_bot.display_text("Samuel is showing unexpected non-compliance",2,3,true)
	await get_tree().create_timer(4).timeout
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.die()
	$ColorRect.fade_to_black(3)
