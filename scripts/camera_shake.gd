# scripts/camera_shake.gd
extends Node

@export var shake_duration: float = 0.3
@export var shake_intensity: float = 8.0
@export var shake_frequency: float = 60.0

var _trauma: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO
var _camera: Camera2D

func _ready() -> void:
    _camera = get_viewport().get_camera_2d()

func add_trauma(amount: float) -> void:
    _trauma = min(_trauma + amount, 1.0)

func _process(delta: float) -> void:
    if _trauma > 0.0:
        var shake = pow(_trauma, 2.5) * shake_intensity
        var angle = randf() * TAU
        _shake_offset = Vector2(cos(angle), sin(angle)) * shake
        
        if _camera:
            _camera.offset = _shake_offset
        
        _trauma = max(_trauma - delta / shake_duration, 0.0)
    elif _shake_offset != Vector2.ZERO:
        _shake_offset = Vector2.ZERO
        if _camera:
            _camera.offset = Vector2.ZERO