extends SceneTree

func _init():
    var arr = []
    arr.resize(11)
    for y in range(11):
        arr[y] = []
        arr[y].resize(11)
    print("arr size: ", arr.size())
    print("arr[10] size: ", arr[10].size())
    var a = arr[10][10]
    print("success")
    quit()
