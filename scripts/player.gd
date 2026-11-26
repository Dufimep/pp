# scripts/player.gd
extends CharacterBody2D
class_name Player

@export var move_speed: float = Globals.MOVE_SPEED
@export var jump_velocity: float = Globals.JUMP_VELOCITY
@export var reach: float = Globals.REACH_DISTANCE
@export var tool_power: int = 1

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var camera: Camera2D = %Camera
@onready var ray_break: RayCast2D = %RayBreak
@onready var ray_place: RayCast2D = %RayPlace
@onready var collision: CollisionShape2D = %Collision
@onready var light_occluder: LightOccluder2D = %LightOccluder
@onready var hurt_flash: ShaderMaterial = %HurtFlash

var velocity = Vector2.ZERO
var move_input = 0.0
var jump_pressed = false
var break_pressed = false
var place_pressed = false
var inventory_slot = 0
var health = Globals.MAX_HEALTH
var max_health = Globals.MAX_HEALTH
var _hurt_timer = 0.0
var _coyote_time = 0.0
var _jump_buffer = 0.0
var _last_ground = false

signal health_changed(current: int, max: int)

func _ready() -> void:
    _setup_animations()
    _connect_hud()
    health = max_health
    Globals.health_changed.emit(health, max_health)

func _setup_animations() -> void:
    animated_sprite.animation_finished.connect(_on_anim_finished)

func _connect_hud() -> void:
    var hud = get_tree().root.get_node("World/HUD")
    hud.joystick.moved.connect(_on_joystick_moved)
    hud.action_buttons.jump_pressed.connect(_on_jump_pressed)
    hud.action_buttons.jump_released.connect(_on_jump_released)
    hud.action_buttons.break_pressed.connect(_on_break_pressed)
    hud.action_buttons.break_released.connect(_on_break_released)
    hud.action_buttons.place_pressed.connect(_on_place_pressed)
    hud.action_buttons.place_released.connect(_on_place_released)
    hud.inventory.slot_changed.connect(_on_slot_changed)

func _physics_process(delta: float) -> void:
    _handle_coyote_and_buffer(delta)
    _handle_horizontal_movement()
    _handle_gravity(delta)
    _handle_jump()
    _update_animations()
    _update_raycasts()
    _handle_actions()
    _update_hurt_flash(delta)
    
    move_and_slide()

func _handle_coyote_and_buffer(delta: float) -> void:
    if is_on_floor():
        _coyote_time = 0.1
        _last_ground = true
    else:
        _coyote_time -= delta
        if _last_ground:
            _last_ground = false
    
    if jump_pressed:
        _jump_buffer = 0.1
        jump_pressed = false
    else:
        _jump_buffer -= delta

func _handle_horizontal_movement() -> void:
    velocity.x = move_input * move_speed
    
    if move_input > 0.1:
        animated_sprite.flip_h = false
        _update_light_occluder(false)
    elif move_input < -0.1:
        animated_sprite.flip_h = true
        _update_light_occluder(true)

func _handle_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += Globals.GRAVITY * delta
    else:
        velocity.y = 0

func _handle_jump() -> void:
    if _jump_buffer > 0 and _coyote_time > 0:
        velocity.y = jump_velocity
        _jump_buffer = 0
        _coyote_time = 0
        _spawn_jump_dust()

func _spawn_jump_dust() -> void:
    var dust = ParticlePool.get("jump_dust")
    if dust:
        dust.global_position = global_position + Vector2(0, 14)
        dust.restart()

func _update_animations() -> void:
    if not is_on_floor():
        if velocity.y < 0:
            animated_sprite.play("jump")
        else:
            animated_sprite.play("fall")
    elif abs(move_input) > 0.1:
        animated_sprite.play("run")
    else:
        animated_sprite.play("idle")

func _update_raycasts() -> void:
    var target = get_global_mouse_position()
    var dir = (target - global_position).normalized()
    ray_break.target_position = dir * reach
    ray_place.target_position = dir * (reach + Globals.TILE_SIZE)

func _handle_actions() -> void:
    if break_pressed:
        _try_break()
        break_pressed = false
    if place_pressed:
        _try_place()
        place_pressed = false

func _try_break() -> void:
    if ray_break.is_colliding():
        var world_pos = ray_break.get_collision_point()
        var world = get_parent()
        if world.has_method("break_tile_at"):
            world.break_tile_at(world_pos, tool_power)

func _try_place() -> void:
    if ray_place.is_colliding():
        var world_pos = ray_place.get_collision_point()
        var tile = Globals.TileType.WOOD
        var inv = get_tree().root.get_node("World/HUD/Inventory")
        if inv:
            tile = inv.get_selected_tile()
        var world = get_parent()
        if world.has_method("place_tile_at"):
            world.place_tile_at(world_pos, tile)

func _update_hurt_flash(delta: float) -> void:
    if _hurt_timer > 0:
        _hurt_timer -= delta
        hurt_flash.set_shader_parameter("flash_amount", _hurt_timer / 0.2)
    else:
        hurt_flash.set_shader_parameter("flash_amount", 0.0)

func take_damage(amount: int, knockback: Vector2) -> void:
    health = max(health - amount, 0)
    _hurt_timer = 0.2
    velocity += knockback
    Globals.health_changed.emit(health, max_health)
    Globals.player_damaged.emit(amount, knockback)
    
    if health <= 0:
        _die()

func heal(amount: int) -> void:
    health = min(health + amount, max_health)
    Globals.health_changed.emit(health, max_health)
    Globals.player_healed.emit(amount)

func _die() -> void:
    # Respawn logic
    global_position = Vector2(0, -200)
    health = max_health
    velocity = Vector2.ZERO
    Globals.health_changed.emit(health, max_health)

func _spawn_landing_dust() -> void:
    var dust = ParticlePool.get("landing_dust")
    if dust:
        dust.global_position = global_position + Vector2(0, 14)
        dust.restart()

func _on_anim_finished() -> void:
    pass

# Touch/Input bridges
func _on_joystick_moved(dir: Vector2) -> void:
    move_input = dir.x

func _on_jump_pressed() -> void: jump_pressed = true
func _on_jump_released() -> void: jump_pressed = false
func _on_break_pressed() -> void: break_pressed = true
func _on_break_released() -> void: break_pressed = false
func _on_place_pressed() -> void: place_pressed = true
func _on_place_released() -> void: place_pressed = false
func _on_slot_changed(slot: int) -> void: inventory_slot = slot

func _update_light_occluder(flip: bool) -> void:
    light_occluder.flip_h = flip

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            match event.keycode:
                KEY_A, KEY_LEFT: move_input = -1
                KEY_D, KEY_RIGHT: move_input = 1
                KEY_SPACE, KEY_W, KEY_UP: jump_pressed = true
                KEY_E: break_pressed = true
                KEY_Q: place_pressed = true
        else:
            match event.keycode:
                KEY_A, KEY_LEFT: move_input = 0 if move_input < 0 else move_input
                KEY_D, KEY_RIGHT: move_input = 0 if move_input > 0 else move_input