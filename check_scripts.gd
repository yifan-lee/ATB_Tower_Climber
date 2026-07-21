extends SceneTree

func _init():
	print("Checking scripts...")
	var errors = 0
	var dir = DirAccess.open("res://")
	if dir:
		errors += _check_dir("res://")
	if errors == 0:
		print("All scripts OK")
	else:
		print(errors, " errors found")
	quit()

func _check_dir(path: String) -> int:
	var errors = 0
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != ".." and file_name != "addons":
					errors += _check_dir(path + file_name + "/")
			elif file_name.ends_with(".gd"):
				var script_path = path + file_name
				var script = load(script_path) as GDScript
				if script == null:
					print("Failed to load script: ", script_path)
					errors += 1
			file_name = dir.get_next()
	return errors
