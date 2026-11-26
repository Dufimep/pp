# scripts/action_buttons.gd
extends Control
class_name ActionButtons

signal jump_pressed
signal jump_released
signal break_pressed
signal break_released
signal place_pressed
signal place_released
signal inventory_toggled

@onready var btn_jump: TextureButton = %Jump
@onready var btn_break: TextureButton = %Break
@onready var btn_place: TextureButton = %Place
@onready var btn_inv: TextureButton = %Inventory

var jump_finger = -1
var break_finger = -1
var place_finger = -1

func _ready() -> void:
    for btn in [btn_jump, btn_break, btn_place, btn_inv]:
        btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
        btn.gui_input.connect(_on_btn_gui_input.bind(btn))
    
    _style_buttons()

func _style_buttons() -> void:
    for btn in [btn_jump, btn_break, btn_place, btn_inv]:
        btn.set_theme_override_constant("outline_size", 2)
        btn.set_theme_override_color("font_outline_color", Color(0, 0, 0, 0.8))

func _on_btn_gui_input(event: InputEvent, btn: TextureButton) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _press(btn, event.index)
        elif event.index in [jump_finger, break_finger, place_finger]:
            _release(btn, event.index)

func _press(btn: TextureButton, finger: int) -> void:
    btn.scale = Vector2(0.9, 0.9)
    match btn:
        btn_jump:  jump_finger = finger; jump_pressed.emit()
        btn_break: break_finger = finger; break_pressed.emit()
        btn_place: place_finger = finger; place_pressed.emit()
        btn_inv: inventory_toggled.emit()

func _release(btn: TextureButton, finger: int) -> void:
    btn.scale = Vector2(1, 1)
    match btn:
        btn_jump:  jump_finger = -1; jump_released.emit()
        btn_break: break_finger = -1; break_released.emit()
        btn_place: place_finger = -1; place_released.emit()