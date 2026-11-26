# scripts/save_system.gd
extends Node
class_name SaveSystem

signal save_request
signal load_request(data: Dictionary)

const SAVE_PATH: String = "user://world.save"
const CHUNK_SAVE_PATH: String = "user://chunks/"

var _save_timer: float = 0.0
const AUTO_SAVE_INTERVAL: float = 30.0

func _ready() -> void:
    DirAccess.make_dir_recursive_absolute(CHUNK_SAVE_PATH)
    save_request.connect(_on_save_request)
    load_request.connect(_on_load_request)

func _process(delta: float) -> void:
    _save_timer += delta
    if _save_timer >= AUTO_SAVE_INTERVAL:
        _save_timer = 0.0
        save_request.emit()

func _on_save_request() -> void:
    # World saves itself via signal, we just ensure directory exists
    pass

func _on_load_request(data: Dictionary) -> void:
    # World handles loading, we just provide the data
    pass

func save_world(data: Dictionary) -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(data)
        file.close()
        print("World saved to ", SAVE_PATH)

func load_world() -> Dictionary:
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var data = file.get_var()
        file.close()
        print("World loaded from ", SAVE_PATH)
        return data
    return {}

func save_chunk(chunk: Vector2i, tiles: Array[Dictionary]) -> void:
    var key = "%d,%d" % [chunk.x, chunk.y]
    var path = CHUNK_SAVE_PATH + key + ".chunk"
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_var(tiles)
        file.close()

func load_chunk(chunk: Vector2i) -> Array[Dictionary]:
    var key = "%d,%d" % [chunk.x, chunk.y]
    var path = CHUNK_SAVE_PATH + key + ".chunk"
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var data = file.get_var()
        file.close()
        return data
    return []

func delete_chunk_save(chunk: Vector2i) -> void:
    var key = "%d,%d" % [chunk.x, chunk.y]
    var path = CHUNK_SAVE_PATH + key + ".chunk"
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)