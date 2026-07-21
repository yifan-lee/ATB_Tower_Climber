extends SceneTree
func _init():
	var d = {Vector2i(10, 5): "test"}
	var json_str = JSON.stringify(d)
	print("JSON: ", json_str)
	var json = JSON.new()
	json.parse(json_str)
	var d2 = json.get_data()
	print("Parsed Keys: ", d2.keys())
	for k in d2.keys():
		print("Type of key: ", typeof(k))
	quit()
