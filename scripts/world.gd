# === WORLD.GD (CONTINUED) ===

func _tile_collides_with_player(tile_pos: Vector2i, player: Node2D) -> bool:
    var tile_rect = Rect2(tilemap.map_to_local(tile_pos), Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE))
    var player_rect = Rect2(player.global_position - Vector2(7, 14), Vector2(14, 28))
    return tile_rect.intersects(player_rect)

func _check_chunk_edges(pos: Vector2i) -> void:
    var chunk = Globals.world_to_chunk(pos)
    if pos.x % Globals.CHUNK_SIZE == 0:
        _load_chunks_around(_player_chunk + Vector2i(-1, 0))
    if pos.x % Globals.CHUNK_SIZE == Globals.CHUNK_SIZE - 1:
        _load_chunks_around(_player_chunk + Vector2i(1, 0))

func _on_tile_changed(pos: Vector2i, tile: Globals.TileType, biome: Globals.BiomeType) -> void:
    _set_tile_data(pos, tile)
    _update_light_at(pos)

func _update_light_at(pos: Vector2i) -> void:
    # Simple light propagation (can be expanded)
    var key = "%d,%d" % [pos.x, pos.y]
    if tile != Globals.TileType.AIR:
        _light_data[key] = 0.0  # blocks light
    else:
        _light_data[key] = 1.0

func _on_day_time_changed(time: float) -> void:
    _time_of_day = time
    _update_background_sky()

func _update_background_sky() -> void:
    background.set_time_of_day(_time_of_day)

func _generate_world_seed() -> void:
    # Could use fixed seed for reproducibility
    pass

# === SAVE/LOAD ===
func _on_save_request() -> void:
    var data = {
        tiles: _tile_data,
        time: _time_of_day,
        player_chunk: [_player_chunk.x, _player_chunk.y]
    }
    SaveSystem.save_world(data)

func _on_load_request(data: Dictionary) -> void:
    _tile_data = data.tiles
    _time_of_day = data.time
    var pc = data.player_chunk
    _load_chunks_around(Vector2i(pc[0], pc[1]))