extends CanvasLayer

"""Inventory UI overlay.

Shows a toast notification when items are collected,
and a full inventory panel toggled with the inventory action.
Built programmatically to avoid .tscn dependencies.
"""

const TOAST_DURATION: float = 2.0
const TOAST_FADE: float = 0.5
const PANEL_MARGIN: int = 16
const ITEM_LINE_HEIGHT: int = 28

var _panel: PanelContainer
var _panel_vbox: VBoxContainer
var _toast_label: Label
var _toast_timer: Timer
var _toast_tween: Tween
var _is_panel_open: bool = false


func _ready() -> void:
	layer = 100
	_build_toast()
	_build_panel()
	inventory.item_added.connect(_on_item_added)
	inventory.inventory_changed.connect(_refresh_panel)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_toggle_panel()


func _build_toast() -> void:
	"""Create the toast notification label."""
	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 16)
	_toast_label.add_theme_color_override("font_color", Color.YELLOW)
	_toast_label.add_theme_color_override(
		"font_shadow_color", Color(0, 0, 0, 1)
	)
	_toast_label.add_theme_constant_override("shadow_offset_x", 2)
	_toast_label.add_theme_constant_override("shadow_offset_y", 2)
	_toast_label.anchors_preset = Control.PRESET_CENTER_TOP
	_toast_label.position = Vector2(-200, 60)
	_toast_label.size = Vector2(400, 40)
	_toast_label.visible = false
	add_child(_toast_label)

	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(_on_toast_timeout)
	add_child(_toast_timer)


func _build_panel() -> void:
	"""Create the inventory panel."""
	_panel = PanelContainer.new()
	_panel.anchors_preset = Control.PRESET_CENTER
	_panel.position = Vector2(-150, -120)
	_panel.custom_minimum_size = Vector2(300, 240)
	_panel.visible = false
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", PANEL_MARGIN)
	margin.add_theme_constant_override("margin_right", PANEL_MARGIN)
	margin.add_theme_constant_override("margin_top", PANEL_MARGIN)
	margin.add_theme_constant_override("margin_bottom", PANEL_MARGIN)
	_panel.add_child(margin)

	_panel_vbox = VBoxContainer.new()
	margin.add_child(_panel_vbox)

	var title := Label.new()
	title.text = "Inventory"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel_vbox.add_child(title)

	var sep := HSeparator.new()
	_panel_vbox.add_child(sep)


func _toggle_panel() -> void:
	_is_panel_open = not _is_panel_open
	_panel.visible = _is_panel_open
	get_tree().paused = _is_panel_open
	if _is_panel_open:
		_refresh_panel()


func _refresh_panel() -> void:
	"""Rebuild the item list in the panel."""
	if not _panel_vbox:
		return
	# Remove old item labels (keep title + separator = 2 children):
	while _panel_vbox.get_child_count() > 2:
		var child: Node = _panel_vbox.get_child(2)
		_panel_vbox.remove_child(child)
		child.queue_free()

	var items: Dictionary = inventory.get_all_items()
	if items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Empty..."
		empty_label.add_theme_color_override(
			"font_color", Color(0.6, 0.6, 0.6)
		)
		_panel_vbox.add_child(empty_label)
		return

	for item_id: String in items:
		var qty: int = items[item_id]
		var line := Label.new()
		line.text = item_id
		if qty > 1:
			line.text += " x" + str(qty)
		line.add_theme_font_size_override("font_size", 14)
		_panel_vbox.add_child(line)


func _on_item_added(item_id: String, quantity: int) -> void:
	"""Show a toast notification."""
	var text: String = "+ " + item_id
	if quantity > 1:
		text += " x" + str(quantity)
	_show_toast(text)


func _show_toast(text: String) -> void:
	_toast_label.text = text
	_toast_label.modulate = Color(1, 1, 1, 1)
	_toast_label.visible = true
	_toast_timer.start(TOAST_DURATION)


func _on_toast_timeout() -> void:
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(
		_toast_label, "modulate:a", 0.0, TOAST_FADE
	)
	_toast_tween.tween_callback(_toast_label.set.bind("visible", false))
