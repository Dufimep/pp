# scripts/hud.gd
extends CanvasLayer
class_name HUD

@onready var joystick: VirtualJoystick = %VirtualJoystick
@onready var action_buttons: ActionButtons = %ActionButtons
@onready var inventory: Inventory = %Inventory
@onready var health_bar: HealthBar = %HealthBar
@onready var hotbar: Hotbar = %Hotbar
@onready var minimap: Minimap = %Minimap
@onready var debug_info: Label = %DebugInfo

func _ready() -> void:
    Globals.health_changed.connect(_on_health_changed)
    Globals.inventory_changed.connect(_on_inventory_changed)
    Globals.biome_changed.connect(_on_biome_changed)
    set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _process(delta: float) -> void:
    _update_debug()

func _update_debug() -> void:
    var player = get_tree().root.get_node("World/Player")
    if player:
        debug_info.text = "FPS: %d\nPos: (%.0f, %.0f)\nChunk: (%d, %d)" % [
            Engine.get_frames_per_second(),
            player.global_position.x, player.global_position.y,
            Globals.world_to_chunk(Vector2i(player.global_position)).x,
            Globals.world_to_chunk(Vector2i(player.global_position)).y
        ]

func _on_health_changed(current: int, max: int) -> void:
    health_bar.set_health(current, max)

func _on_inventory_changed() -> void:
    hotbar.refresh()
    inventory.refresh()

func _on_biome_changed(biome: Globals.BiomeType) -> void:
    minimap.update_biome(biome)