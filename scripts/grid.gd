extends Node2D
class_name Grid

## Adjustable tilemap grid.
## Cells are either plain dirt or graves containing a decomposing body.
## The grid is purely spatial — the player (wormbeetle) moves freely in world space
## and queries the grid via world_to_cell() / has_body() / consume_body().

@export var grid_width: int = 9:
	set(v):
		grid_width = v
		if is_inside_tree():
			_build()

@export var grid_height: int = 9:
	set(v):
		grid_height = v
		if is_inside_tree():
			_build()

@export var tile_size: int = 32:
	set(v):
		tile_size = v
		if is_inside_tree():
			_build()

## Fraction of cells that start as graves (0 – 1).
@export_range(0.0, 1.0) var grave_probability: float = 0.25:
	set(v):
		grave_probability = v
		if is_inside_tree():
			_build()

## Change this to get a different layout while keeping the same settings.
@export var random_seed: int = 0:
	set(v):
		random_seed = v
		if is_inside_tree():
			_build()

## When true the grid is centered on this node's position.
@export var centered: bool = true:
	set(v):
		centered = v
		if is_inside_tree():
			_build()
@export var grave_scene: PackedScene 

const _SOURCE_ID := 0
const _TILE_EMPTY := Vector2i(0, 0)
const _TILE_GRAVE := Vector2i(1, 0)

var _layer: TileMapLayer = null
## Vector2i cell -> float  (body content: 1.0 = full, 0.0 = empty)
var _graves: Dictionary = {}

signal grave_consumed(cell: Vector2i)


func _ready() -> void:
	_build()


# ---------------------------------------------------------------------------
# Grid construction
# ---------------------------------------------------------------------------

func _build() -> void:
	if is_instance_valid(_layer):
		remove_child(_layer)
		_layer.queue_free()

	_layer = TileMapLayer.new()
	_layer.tile_set = _make_tileset()
	add_child(_layer)

	_layer.position = (
		Vector2(-grid_width * tile_size * 0.5, -grid_height * tile_size * 0.5)
		if centered else Vector2.ZERO
	)

	_graves.clear()
	_fill_grid()


func _make_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(tile_size, tile_size)

	var source := TileSetAtlasSource.new()
	source.texture = _make_atlas()
	source.texture_region_size = Vector2i(tile_size, tile_size)
	source.create_tile(_TILE_EMPTY)
	source.create_tile(_TILE_GRAVE)

	ts.add_source(source, _SOURCE_ID)
	return ts


func _make_atlas() -> ImageTexture:
	# Atlas layout: [empty/dirt | grave]
	var img := Image.create(tile_size * 2, tile_size, false, Image.FORMAT_RGBA8)

	# Dirt tile
	_img_fill(img, 0, 0, tile_size, tile_size, Color(0.55, 0.40, 0.25))
	_img_border(img, 0, 0, tile_size, tile_size, Color(0.35, 0.22, 0.12))

	# Grave tile
	_img_fill(img, tile_size, 0, tile_size, tile_size, Color(0.22, 0.20, 0.18))
	_img_border(img, tile_size, 0, tile_size, tile_size, Color(0.12, 0.10, 0.08))
	_img_cross(
		img,
		tile_size + tile_size / 2,
		tile_size / 2,
		tile_size / 5,
		3,
		Color(0.65, 0.60, 0.55)
	)

	return ImageTexture.create_from_image(img)


func _fill_grid() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	for x in range(grid_width):
		for y in range(grid_height):
			var cell := Vector2i(x, y)
			if rng.randf() < grave_probability:
				_layer.set_cell(cell, _SOURCE_ID, _TILE_EMPTY)
				_graves[cell] = 1.0
				if grave_scene:
					var g := grave_scene.instantiate()
					g.position = _layer.map_to_local(cell)
					g.scale = Vector2.ONE * (float(tile_size) / 32.0)
					_layer.add_child(g)
			else:
				_layer.set_cell(cell, _SOURCE_ID, _TILE_EMPTY)


# ---------------------------------------------------------------------------
# Image helpers
# ---------------------------------------------------------------------------

func _img_fill(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for px in range(x, x + w):
		for py in range(y, y + h):
			img.set_pixel(px, py, c)


func _img_border(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for px in range(x, x + w):
		img.set_pixel(px, y, c)
		img.set_pixel(px, y + h - 1, c)
	for py in range(y, y + h):
		img.set_pixel(x, py, c)
		img.set_pixel(x + w - 1, py, c)


func _img_cross(img: Image, cx: int, cy: int, half_len: int, thickness: int, c: Color) -> void:
	for i in range(-half_len, half_len + 1):
		for t in range(-thickness / 2, thickness / 2 + 1):
			_img_safe_set(img, cx + i, cy + t, c)
			_img_safe_set(img, cx + t, cy + i, c)


func _img_safe_set(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		img.set_pixel(x, y, c)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## True if `cell` is a grave (regardless of whether a body remains).
func is_grave(cell: Vector2i) -> bool:
	return _graves.has(cell)


## True if the grave at `cell` still has an unconsumed body.
func has_body(cell: Vector2i) -> bool:
	return _graves.get(cell, 0.0) > 0.0


## Eat the body at `cell`. Returns true on success, false if already consumed or not a grave.
func consume_body(cell: Vector2i) -> bool:
	if has_body(cell):
		_graves.erase(cell)
		_layer.set_cell(cell, _SOURCE_ID, _TILE_EMPTY)
		grave_consumed.emit(cell)
		return true
	return false


## Convert a world-space position to the grid cell it falls within.
func world_to_cell(world_pos: Vector2) -> Vector2i:
	return _layer.local_to_map(_layer.to_local(world_pos))


## World-space centre of a grid cell.
func cell_center(cell: Vector2i) -> Vector2:
	return _layer.to_global(_layer.map_to_local(cell))


## All cells that still contain an unconsumed body.
func get_active_graves() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell: Vector2i in _graves:
		if _graves[cell] > 0.0:
			result.append(cell)
	return result


## Grid dimensions in cells.
func get_grid_bounds() -> Rect2i:
	return Rect2i(Vector2i.ZERO, Vector2i(grid_width, grid_height))


## Gradually drain body content. Returns the amount actually drained (≤ amount).
## Use this for the player's slow eating; consume_body() for instant removal.
func eat_body(cell: Vector2i, amount: float) -> float:
	var content: float = _graves.get(cell, 0.0)
	if content <= 0.0:
		return 0.0
	var drained := minf(content, amount)
	_graves[cell] = content - drained
	if _graves[cell] <= 0.0:
		_graves.erase(cell)
		_layer.set_cell(cell, _SOURCE_ID, _TILE_EMPTY)
		grave_consumed.emit(cell)
	return drained


## Spawn a new grave on a random empty (non-grave) cell. Returns the cell, or (-1,-1) if full.
func spawn_random_grave() -> Vector2i:
	var empty_cells: Array[Vector2i] = []
	for x in range(grid_width):
		for y in range(grid_height):
			var cell := Vector2i(x, y)
			if not _graves.has(cell):
				empty_cells.append(cell)
	if empty_cells.is_empty():
		return Vector2i(-1, -1)
	var cell: Vector2i = empty_cells[randi() % empty_cells.size()]
	_layer.set_cell(cell, _SOURCE_ID, _TILE_GRAVE)
	_graves[cell] = 1.0
	return cell


## World-space Rect2 covering the entire grid (top-left origin, pixel size).
func get_world_bounds() -> Rect2:
	if not is_instance_valid(_layer):
		return Rect2()
	var origin := _layer.to_global(Vector2.ZERO)
	return Rect2(origin, Vector2(grid_width * tile_size, grid_height * tile_size))
