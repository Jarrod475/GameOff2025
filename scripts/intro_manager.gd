extends CanvasLayer
@onready var text_display_bot = $ColorRect/SubViewport/HUD/text_display_bottom
@onready var anim = $intro_anim_master

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
	
	
	
