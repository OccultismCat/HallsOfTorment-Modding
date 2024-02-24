extends Control

var mods:Array
var mod_log : Array
var mods_folder := OS.get_executable_path().get_base_dir() + "/mods/"
var mods_dir := DirAccess.open(mods_folder)
var mods_loaded : bool = false
var input_timer = 0.0
#const mod = "res://addons/debug_mode/debug_mode.gd"



# we load and instantiate the new scene manually, according to
# https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html#custom-scene-switcher
# so that we have a little more control over it than using change_scene...

func toggle_autoplayer(value: bool):
	ProjectSettings.set_setting("halls_of_torment/development/enable_autoplayer", value)
	var setting = ProjectSettings.get_setting("halls_of_torment/development/enable_autoplayer")
	print('ENABLE_AUTOPLAYER: ', setting)
	
func get_all_mods():
	if mods_dir:
		mods_dir.list_dir_begin()
		var file = mods_dir.get_next()
		while file != "":
			if not file.ends_with('.gd'):
				load_mods_from_folder(mods_folder + file)
			mods.append(file)
			file = mods_dir.get_next()
	if not mods_dir:
		DirAccess.make_dir_absolute(mods_folder)
	
func load_mod(mod_path):
	for mod in mods:
		print(mod)
		var mod_script = ResourceLoader.load(mods_folder + mod)
		if mod_script:
			mod_log.append("Mod Loaded: " + mods_folder + mod)
			add_child(mod_script.new())
			
func load_mods_from_folder(path):
	var inner_mod_folder = DirAccess.open(path)
	if inner_mod_folder:
		inner_mod_folder.list_dir_begin()
		var file = inner_mod_folder.get_next()
		while file != "":
			mod_log.append("Mod Loaded: " + path + '/' + file)
			file = inner_mod_folder.get_next()
			
func print_loaded_mods():
	for log in mod_log:
		print(log)
	
func on_cooldown() -> bool:
	return input_timer < 5.0
	#return (Engine.get_process_frames() - input_timer) < (60 * 3)
	
func reset_cooldown():
	input_timer = 0.0
	
func _ready():
	get_all_mods()
	toggle_autoplayer(false)
	load_mod(false)
	
func _process(delta):
	input_timer += delta
	if Input.is_key_pressed(KEY_1) and not on_cooldown():
		#input_timer = Engine.get_process_frames()
		#var time = int(Engine.get_process_frames() / 60)
		#print(time)
		print_loaded_mods()
		reset_cooldown()
	if mods_loaded == false:
		if GameState.CurrentState == GameState.States.Overworld:
			pass
			#mods_loaded = true
	
#func load_mods():
#	var project_path = OS.get_executable_path()
#	print(str(project_path))
