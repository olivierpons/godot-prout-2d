extends Node2D

"""Level: The Village of Questionable Residents.

A level where the player meets various NPCs with
completely unhinged dialog. Serves as an introduction
to NPCs and the inventory system.
"""

@onready var game_manager: Node = $GameManager
@onready var player: CharacterBody2D = $Player

# NPCs - assign in editor after instancing npc.tscn:
@onready var mushroom_npc: Npc = $NpcMushroom
@onready var skeleton_npc: Npc = $NpcSkeleton
@onready var chicken_npc: Npc = $NpcChicken
@onready var frog_npc: Npc = $NpcFrog


func _ready() -> void:
	await get_tree().process_frame
	game_manager.all_coins_collected.connect(_on_all_coins_collected)
	_setup_mushroom_dialogs()
	_setup_skeleton_dialogs()
	_setup_chicken_dialogs()
	_setup_frog_dialogs()

	# Intro bubble after a short delay:
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.6
	timer.one_shot = true
	timer.connect("timeout", _on_intro_timeout)
	timer.start()


func _on_intro_timeout() -> void:
	player.bubble_talk("What is this\nweird place?!")


func _on_all_coins_collected() -> void:
	player.bubble_talk("Finally!\nNow let me OUT!")


# =========================================================================
#  NPC Dialog Setup
#  Each NPC gets its dialogs created in code for easy iteration.
#  For production, create .tres resources in the editor instead.
# =========================================================================

func _make_dialog(
	id: String,
	pages: Array[String],
	priority: int = 0,
	one_shot: bool = false,
	required_item: String = "",
	reward_item: String = "",
	reward_qty: int = 1,
) -> NpcDialog:
	"""Helper to create NpcDialog resources in code."""
	var d := NpcDialog.new()
	d.dialog_id = id
	d.pages = pages
	d.priority = priority
	d.one_shot = one_shot
	d.required_item = required_item
	d.reward_item = reward_item
	d.reward_quantity = reward_qty
	return d


func _setup_mushroom_dialogs() -> void:
	"""The Philosopher Mushroom: questions everything."""
	mushroom_npc.npc_name = "Champignoble"
	mushroom_npc.dialogs = [
		# First encounter (one-shot, highest priority):
		_make_dialog("mush_intro", [
			"Ah, a bipedal visitor!\nHow original.",
			"Did you know that gravity\nis just the earth hugging\nus too tight?",
			"I filed a complaint.\nNo response.",
			"Here, take this.\nIt fell from the sky.\nOr maybe from my hat.",
		] as Array[String], 10, true, "", "Mysterious Spore", 1),

		# If player has the skeleton's poem:
		_make_dialog("mush_poem", [
			"A poem? Let me see...",
			"...",
			"This is the worst thing\nI've ever absorbed\nthrough my mycelium.",
			"And I once absorbed\na philosophy textbook.\nIN GERMAN.",
		] as Array[String], 5, true, "Bad Poem"),

		# Default repeatable dialog:
		_make_dialog("mush_default", [
			"If a coin falls in a forest\nand no one collects it...",
			"...does it still count\ntoward your score?",
			"I asked the dev.\nHe said 'no'.\nCapitalism wins again.",
		] as Array[String]),
	]


func _setup_skeleton_dialogs() -> void:
	"""The Romantic Skeleton: aspiring poet, terrible at it."""
	skeleton_npc.npc_name = "Sir Bones McRhyme"
	skeleton_npc.dialogs = [
		# First encounter:
		_make_dialog("skel_intro", [
			"Roses are red,\nI have no skin...",
			"Please give me a coat,\nit's cold herein.",
			"*bows*\nThank you, thank you.\nI wrote that myself.",
			"Take this poem.\nShare it with the world.\nOr don't. I'm dead inside.\nLiterally.",
		] as Array[String], 10, true, "", "Bad Poem", 1),

		# If player has "Mysterious Spore":
		_make_dialog("skel_spore", [
			"Is that a spore?\nFrom the mushroom?",
			"Last time I touched one\nI grew moss in places\nI didn't know I had.",
			"And I'm a SKELETON.\nI shouldn't HAVE places.",
		] as Array[String], 5, true, "Mysterious Spore"),

		# Default:
		_make_dialog("skel_default", [
			"New poem!\nAhem...",
			"'Twas the night\nbefore respawn,",
			"and all through the level,\nnot a pixel was stirring...",
			"...except that one slime.\nHe never stops.\nI respect the hustle.",
		] as Array[String]),
	]


func _setup_chicken_dialogs() -> void:
	"""The Paranoid Chicken: conspiracy theorist extraordinaire."""
	chicken_npc.npc_name = "Colonel Clucksworth"
	chicken_npc.dialogs = [
		# First encounter:
		_make_dialog("chick_intro", [
			"PSST! You! Come here!",
			"Those COINS!\nThey're WATCHING us!",
			"I saw one BLINK!\nI SWEAR!",
			"Don't collect them!\n...well, ok, collect them.\nBut CAREFULLY.",
			"Here, take this tin foil.\nFor protection.",
		] as Array[String], 10, true, "", "Tin Foil Hat", 1),

		# If player has all chicken items:
		_make_dialog("chick_foil", [
			"You're still wearing\nthe tin foil? GOOD.",
			"The mushroom told me\nI'm paranoid.",
			"THAT'S EXACTLY WHAT\nSOMEONE BEING CONTROLLED\nBY SPORES WOULD SAY!",
		] as Array[String], 5, true, "Mysterious Spore"),

		# Default:
		_make_dialog("chick_default", [
			"Did you know the exit door\nonly opens when you\ncollect all coins?",
			"SUSPICIOUS.\nWho designed this system?",
			"Someone who WANTS you\nto touch the spy-coins.\nThat's who.",
			"I'm watching you.\nAnd the coins.\nMostly the coins.",
		] as Array[String]),
	]


func _setup_frog_dialogs() -> void:
	"""The Merchant Frog: sells absolutely useless items."""
	frog_npc.npc_name = "Frogsworth the Dealer"
	frog_npc.dialogs = [
		# First encounter:
		_make_dialog("frog_intro", [
			"*ribbit*\nWelcome to my shop!",
			"Today's special:\nInvisible Sword!\nIt's right here.\nYou just can't see it.",
			"Also in stock:\nBottled Air from Level 3.\nVintage. Very rare.",
			"And my best seller:\nSecond-Hand Gravity.\nSlightly used. Still pulls.",
			"No money? No problem!\nTake a free sample.\nOn the house. *ribbit*",
		] as Array[String], 10, true, "", "Bottled Air", 1),

		# If player has the Tin Foil Hat:
		_make_dialog("frog_foil", [
			"Nice hat!\nIs that tin foil?",
			"I can upgrade it\nto ALUMINUM foil\nfor just 47 coins!",
			"...you don't have pockets?\nNeither do I.\nFrogs don't wear pants.",
			"This is the worst\neconomy I've ever seen.",
		] as Array[String], 5, true, "Tin Foil Hat"),

		# Default:
		_make_dialog("frog_default", [
			"*ribbit*\nBusiness is slow today.",
			"A slime came by earlier.\nWanted to buy a body.\nI don't sell those.",
			"...anymore.",
			"*nervous ribbit*",
		] as Array[String]),
	]
