# scripts/virtual_joystick.gd
extends Control
class_name VirtualJoystick

signal moved(direction: Vector2)

@onready var base: TextureRect = %Base
@onready var stick: TextureRect = %Stick

var radius: float = 70.0
var active_finger: int = -1
var center: Vector2
var _deadzone: float = 0.15

func _ready() -> void:
    base.hide()
    stick.hide()
    base.modulate = Color(1, 1, 1, 0.4)
    stick.modulate = Color(1, 1, 1, 0.7)
    base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    stick.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if active_finger == -1:
                var dist = event.position.distance_to(base.global_position + base.size / 2)
                if dist < 180 or base.global_position.distance_to(event.position) < 180:
                    active_finger = event.index
                    base.global_position = event.position - base.size / 2
                    center = event.position
                    base.show()
                    stick.show()
                    _animate_in()
                    _update_stick(event.position)
        elif event.index == active_finger:
            active_finger = -1
            _animate_out()
            moved.emit(Vector2.ZERO)
    elif event is InputEventScreenDrag and event.index == active_finger:
        _update_stick(event.position)

func _update_stick(pos: Vector2) -> void:
    var offset = pos - center
    var dist = offset.length()
    var dir = offset.normalized() if dist > 0 else Vector2.ZERO
    
    if dist > radius:
        offset = dir * radius
        dist = radius
    
    stick.global_position = center + offset
    
    var strength = dist / radius
    if strength < _deadzone:
        strength = 0.0
        dir = Vector2.ZERO
    
    moved.emit(dir * strength)

func _animate_in() -> void:
    base.scale = Vector2(0.5, 0.5)
    stick.scale = Vector2(0.5, 0.5)
    var tween = create_tween()
    tween.tween_property(base, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(stick, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animate_out() -> void:
    var tween = create_tween()
    tween.tween_property(base, "scale", Vector2(0.5, 0.5), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
    tween.tween_property(stick, "scale", Vector2(0.5, 0.5), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
    tween.finished.connect(_hide_elements)

func _hide_elements() -> void:
    base.hide()
    stick.hide()