extends SceneTree

func _init():
    var base = load("res://scenes/maps/base_map.gd")
    var maps = [
        "res://scenes/maps/floor_1.gd",
        "res://scenes/maps/floor_2.gd",
        "res://scenes/maps/floor_3.gd",
        "res://scenes/maps/floor_4.gd",
        "res://scenes/maps/floor_5.gd"
    ]
    for map_path in maps:
        var map_script = load(map_path)
        var map = map_script.new()
        print("Successfully loaded: ", map_path)
    quit()
