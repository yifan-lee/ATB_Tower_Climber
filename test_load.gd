extends SceneTree
const SaveManager = preload("res://core/save_manager.gd")
func _init():
	var test_dict = {"(10, 5)": {"some": "data"}, "(1, 1)": "other"}
	var restored = SaveManager._restore_vector2i_keys(test_dict)
	print("Restored keys: ", restored.keys())
	for k in restored.keys():
		print("Type of key: ", typeof(k))
	quit()
