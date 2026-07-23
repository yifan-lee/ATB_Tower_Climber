# res://config/map_db.gd
class_name MapDB

const TILE_RES = {
	"floor": "res://assets/sprites/map/floor1.tres",
	"wall": "res://assets/sprites/map/wall1.tres",
	"door_closed": "res://assets/sprites/map/door_closed.tres",
	"door_opened": "res://assets/sprites/map/door_opened.tres",
	"stair_up": "res://assets/sprites/map/stair_up.tres",
	"stair_down": "res://assets/sprites/map/stair_down.tres",
	"portal_closed": "res://assets/sprites/map/portal_closed.tres",
	"portal_open": "res://assets/sprites/map/portal_opened.tres",
	"pedal_switch": "res://assets/sprites/map/pedal_switch.tres",
	"pedal_trap": "res://assets/sprites/map/pedal_trap.tres"
}

static var _fallback_texture: Texture2D = null
static var _texture_cache: Dictionary = {}

static func get_texture(type: String) -> Texture2D:
	if _texture_cache.has(type):
		return _texture_cache[type]

	if TILE_RES.has(type):
		var path = TILE_RES[type]
		if ResourceLoader.exists(path):
			var tex = load(path) as Texture2D
			if tex != null:
				_texture_cache[type] = tex
				return tex

	return get_fallback_texture()

static func get_fallback_texture() -> Texture2D:
	if _fallback_texture == null:
		var img = Image.create(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, false, Image.FORMAT_RGB8)
		img.fill(Color(1.0, 0.0, 1.0)) # Pink placeholder to indicate missing resource
		_fallback_texture = ImageTexture.create_from_image(img)
	return _fallback_texture
