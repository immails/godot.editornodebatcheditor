@tool
extends EditorPlugin

var button: Button
var recent: String # This saves recent path for you

func _enter_tree() -> void:
	var SceneTab = findSceneTab();
	button = SceneTab.get_child(0).get_child(0).duplicate()
	button.shortcut = null
	button.icon = EditorInterface.get_base_control().get_theme_icon(&"Script", "EditorIcons")
	button.tooltip_text = "Run script for current tree nodes"
	button.pressed.connect(_click);
	SceneTab.get_child(0).add_child(button)
	SceneTab.get_child(0).move_child(button, 2)
	flashAnimation(button)
	showHelp();

func showHelp():
	print_rich("[center][font_size=16]Editor nodes script executor is enabled")
	print_rich("[center]Button is located in [b]Scene[/b] tab")
	print_rich("[center]Look into [code]addons/editor-nodes-script-executor/template_script.gd[/code]")

func _exit_tree() -> void:
	button.queue_free()

func findSceneTab() -> Control:
	var hasSceneTab = func(dock): return dock.has_node("Scene");
	var getSceneTab = func(dock): return dock.get_node("Scene");
	var screen = EditorInterface.get_inspector()
	var ScreenDocksSplit = screen.get_node("../../../../../../../")

	var FarLeftDocks = ScreenDocksSplit.get_child(0)
	if hasSceneTab.call(FarLeftDocks.get_child(0)):
		return getSceneTab.call(FarLeftDocks.get_child(0))

	if hasSceneTab.call(FarLeftDocks.get_child(1)):
		return getSceneTab.call(FarLeftDocks.get_child(1))

	var NearLeftDocks = ScreenDocksSplit.get_child(1).get_child(0)
	if hasSceneTab.call(NearLeftDocks.get_child(0)):
		return getSceneTab.call(NearLeftDocks.get_child(0))

	if hasSceneTab.call(NearLeftDocks.get_child(1)):
		return getSceneTab.call(NearLeftDocks.get_child(1))

	var NearRightDocks = ScreenDocksSplit.get_child(1).get_child(1).get_child(1).get_child(0)
	if hasSceneTab.call(NearRightDocks.get_child(0)):
		return getSceneTab.call(NearRightDocks.get_child(0))

	if hasSceneTab.call(NearRightDocks.get_child(1)):
		return getSceneTab.call(NearRightDocks.get_child(1))

	var FarRightDocks = ScreenDocksSplit.get_child(1).get_child(1).get_child(1).get_child(1)
	if hasSceneTab.call(FarRightDocks.get_child(0)):
		return getSceneTab.call(FarRightDocks.get_child(0))

	if hasSceneTab.call(FarRightDocks.get_child(1)):
		return getSceneTab.call(FarRightDocks.get_child(1))

	return null;

func flashAnimation(node: Node):
	node.modulate = Color.RED
	create_tween().tween_property(node, "modulate", Color.WHITE, 10)

func _click():
	var FileSelect = EditorFileDialog.new();
	FileSelect.add_filter("*.gd")
	FileSelect.current_path = recent;
	FileSelect.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	FileSelect.display_mode = EditorFileDialog.DISPLAY_LIST
	EditorInterface.get_base_control().add_child(FileSelect)
	FileSelect.popup_centered_ratio(0.75)
	FileSelect.file_selected.connect(_file_chosen.bind(FileSelect));
	await FileSelect.canceled
	FileSelect.queue_free();

func _file_chosen(file: String, FileSelect: EditorFileDialog):
	FileSelect.queue_free();
	var script = load(file).new();
	recent = file;
	script.run(EditorInterface.get_edited_scene_root(), EditorInterface.get_selection().get_selected_nodes())
