# scripts/particle_pool.gd
extends Node

@export var pool_size: int = 200

var _pools: Dictionary = {}
var _active: Dictionary = {}

func _ready() -> void:
    # Pre-warm common pools
    _create_pool("break_dirt", preload("res://scenes/tile_break_particle.tscn"), 50)
    _create_pool("break_stone", preload("res://scenes/tile_break_particle.tscn"), 50)
    _create_pool("break_grass", preload("res://scenes/tile_break_particle.tscn"), 30)
    _create_pool("break_wood", preload("res://scenes/tile_break_particle.tscn"), 30)
    _create_pool("break_ore", preload("res://scenes/tile_break_particle.tscn"), 20)
    _create_pool("place_effect", preload("res://scenes/tile_place_effect.tscn"), 30)
    _create_pool("damage_number", preload("res://scenes/damage_number.tscn"), 40)
    _create_pool("jump_dust", preload("res://scenes/jump_dust.tscn"), 20)
    _create_pool("landing_dust", preload("res://scenes/landing_dust.tscn"), 20)

func _create_pool(key: String, scene: PackedScene, size: int) -> void:
    _pools[key] = []
    _active[key] = []
    for i in range(size):
        var instance = scene.instantiate()
        instance.set_deferred("visible", false)
        instance.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
        add_child(instance)
        _pools[key].append(instance)

func get(key: String) -> Node:
    if not _pools.has(key):
        push_error("Pool not found: ", key)
        return null
    
    if _pools[key].size() == 0:
        # Expand pool
        var scene = _active[key][0].get_class()  # hacky, better store scene ref
        var instance = scene.instantiate()
        add_child(instance)
        _pools[key].append(instance)
    
    var particle = _pools[key].pop_back()
    _active[key].append(particle)
    particle.visible = true
    particle.process_mode = Node.PROCESS_MODE_INHERIT
    return particle

func return_particle(key: String, particle: Node) -> void:
    if not _pools.has(key):
        return
    if particle in _active[key]:
        _active[key].erase(particle)
    particle.visible = false
    particle.process_mode = Node.PROCESS_MODE_DISABLED
    _pools[key].append(particle)

func return_all(key: String) -> void:
    if not _active.has(key):
        return
    for p in _active[key]:
        p.visible = false
        p.process_mode = Node.PROCESS_MODE_DISABLED
        _pools[key].append(p)
    _active[key].clear()

func get_active_count(key: String) -> int:
    return _active[key].size() if _active.has(key) else 0