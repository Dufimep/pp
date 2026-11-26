# scripts/inventory.gd
extends Control
class_name Inventory

signal slot_changed(slot: int)
signal item_used(item: Dictionary)

@onready var container: HBoxContainer = %Container
@onready var tooltip: Label = %Tooltip

var current_slot = 0
var items: Array[Dictionary] = []
var _drag_index = -1
var _drag_preview: TextureRect

func _ready() -> void:
    _create_slots()
    _init_default_items()
    tooltip.hide()
    _drag_preview = TextureRect.new()
    _drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _drag_preview.set_anchors_preset(Control.PRESET_FULL_RECT)
    _drag_preview.hide()
    add_child(_drag_preview)

func _create_slots() -> void:
    for i in range(Globals.INV_SLOTS):
        var btn = TextureButton.new()
        btn.name = "Slot_%d" % i
        btn.custom_minimum_size = Vector2(56, 56)
        btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
        btn.tooltip_text = ""
        btn.gui_input.connect(_on_slot_gui_input.bind(i))
        btn.focus_mode = Control.FOCUS_NONE
        container.add_child(btn)

func _init_default_items() -> void:
    items = [
        {type: Globals.TileType.WOOD, count: 999, max_stack: 999},
        {type: Globals.TileType.DIRT, count: 999, max_stack: 999},
        {type: Globals.TileType.STONE, count: 999, max_stack: 999},
        {type: Globals.TileType.GRASS, count: 999, max_stack: 999},
        {type: Globals.TileType.SAND, count: 999, max_stack: 999},
        {type: Globals.TileType.CLAY, count: 999, max_stack: 999},
        {type: Globals.TileType.ORE_COPPER, count: 999, max_stack: 999},
        {type: Globals.TileType.ORE_IRON, count: 999, max_stack: 999},
        {type: Globals.TileType.GEM_AMETHYST, count: 999, max_stack: 999},
        {type: Globals.TileType.AIR, count: 0, max_stack: 1}
    ]
    refresh()

func refresh() -> void:
    for i in range(Globals.INV_SLOTS):
        var btn = container.get_child(i)
        var item = items[i]
        btn.texture_normal = _get_item_icon(item.type)
        btn.set("item_count", item.count)
        btn.modulate = Color.WHITE if i != current_slot else Color(1, 1, 0.5, 1)
        if item.count > 1:
            btn.tooltip_text = "%s x%d" % [_get_item_name(item.type), item.count]
        else:
            btn.tooltip_text = _get_item_name(item.type)

func _on_slot_gui_input(event: InputEvent, idx: int) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _start_drag(idx, event.position)
        elif _drag_index == idx:
            _end_drag(idx)
    elif event is InputEventScreenDrag and _drag_index == idx:
        _drag_preview.global_position = event.position

func _start_drag(idx: int, pos: Vector2) -> void:
    if items[idx].type == Globals.TileType.AIR:
        return
    _drag_index = idx
    _drag_preview.texture = _get_item_icon(items[idx].type)
    _drag_preview.global_position = pos
    _drag_preview.show()
    _drag_preview.modulate = Color(1, 1, 1, 0.8)

func _end_drag(target_idx: int) -> void:
    if _drag_index == -1 or _drag_index == target_idx:
        _drag_preview.hide()
        _drag_index = -1
        return
    
    # Swap items
    var temp = items[_drag_index]
    items[_drag_index] = items[target_idx]
    items[target_idx] = temp
    
    _drag_preview.hide()
    _drag_index = -1
    refresh()
    slot_changed.emit(current_slot)
    Globals.inventory_changed.emit()

func _on_slot_pressed(idx: int) -> void:
    if _drag_index != -1:
        return
    current_slot = idx
    slot_changed.emit(idx)
    refresh()

func get_selected_tile() -> Globals.TileType:
    return items[current_slot].type

func get_selected_item() -> Dictionary:
    return items[current_slot].duplicate()

func add_item(tile: Globals.TileType, count: int = 1) -> bool:
    # Try stack
    for i, item in enumerate(items):
        if item.type == tile and item.count < item.max_stack:
            var add = min(count, item.max_stack - item.count)
            items[i].count += add
            count -= add
            if count <= 0:
                refresh()
                Globals.inventory_changed.emit()
                return true
    # Find empty
    for i, item in enumerate(items):
        if item.type == Globals.TileType.AIR:
            items[i] = {type: tile, count: count, max_stack: _get_max_stack(tile)}
            refresh()
            Globals.inventory_changed.emit()
            return true
    return false

func consume_selected(count: int = 1) -> bool:
    var item = items[current_slot]
    if item.type == Globals.TileType.AIR:
        return false
    if item.count >= count:
        item.count -= count
        if item.count <= 0:
            item.type = Globals.TileType.AIR
        refresh()
        Globals.inventory_changed.emit()
        return true
    return false

func _get_item_icon(tile: Globals.TileType) -> Texture2D:
    if tile == Globals.TileType.AIR:
        return null
    var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
    match tile:
        Globals.TileType.DIRT: img.fill(Color(0.55, 0.35, 0.2))
        Globals.TileType.GRASS: 
            img.fill(Color(0.3, 0.55, 0.2))
            for x in range(32):
                for y in range(4):
                    img.set_pixel(x, y, Color(0.2, 0.7, 0.15))
        Globals.TileType.STONE: img.fill(Color(0.45, 0.45, 0.45))
        Globals.TileType.WOOD: img.fill(Color(0.65, 0.45, 0.25))
        Globals.TileType.SAND: img.fill(Color(0.85, 0.75, 0.5))
        Globals.TileType.CLAY: img.fill(Color(0.5, 0.3, 0.35))
        Globals.TileType.ORE_COPPER: 
            img.fill(Color(0.45, 0.45, 0.45))
            for i in range(8):
                img.set_pixel(randi()%32, randi()%32, Color(0.8, 0.4, 0.2))
        Globals.TileType.ORE_IRON:
            img.fill(Color(0.45, 0.45, 0.45))
            for i in range(8):
                img.set_pixel(randi()%32, randi()%32, Color(0.6, 0.55, 0.5))
        Globals.TileType.ORE_GOLD:
            img.fill(Color(0.45, 0.45, 0.45))
            for i in range(8):
                img.set_pixel(randi()%32, randi()%32, Color(1.0, 0.85, 0.2))
        Globals.TileType.GEM_AMETHYST:
            img.fill(Color(0.45, 0.45, 0.45))
            for i in range(12):
                img.set_pixel(randi()%32, randi()%32, Color(0.7, 0.3, 0.9))
        Globals.TileType.GEM_TOPAZ:
            img.fill(Color(0.45, 0.45, 0.45))
            for i in range(12):
                img.set_pixel(randi()%32, randi()%32, Color(1.0, 0.6, 0.1))
        Globals.TileType.MUD: img.fill(Color(0.35, 0.25, 0.2))
        Globals.TileType.ASH: img.fill(Color(0.2, 0.2, 0.2))
        Globals.TileType.OBSIDIAN: img.fill(Color(0.1, 0.05, 0.15))
        Globals.TileType.HELLSTONE: 
            img.fill(Color(0.15, 0.05, 0.05))
            for i in range(10):
                img.set_pixel(randi()%32, randi()%32, Color(1.0, 0.3, 0.1))
        _: img.fill(Color(0, 0, 0, 0))
    return ImageTexture.create_from_image(img)

func _get_item_name(tile: Globals.TileType) -> String:
    match tile:
        Globals.TileType.DIRT: return "Dirt"
        Globals.TileType.GRASS: return "Grass"
        Globals.TileType.STONE: return "Stone"
        Globals.TileType.WOOD: return "Wood"
        Globals.TileType.SAND: return "Sand"
        Globals.TileType.CLAY: return "Clay"
        Globals.TileType.ORE_COPPER: return "Copper Ore"
        Globals.TileType.ORE_IRON: return "Iron Ore"
        Globals.TileType.ORE_GOLD: return "Gold Ore"
        Globals.TileType.GEM_AMETHYST: return "Amethyst"
        Globals.TileType.GEM_TOPAZ: return "Topaz"
        Globals.TileType.MUD: return "Mud"
        Globals.TileType.ASH: return "Ash"
        Globals.TileType.OBSIDIAN: return "Obsidian"
        Globals.TileType.HELLSTONE: return "Hellstone"
        _: return "Unknown"

func _get_max_stack(tile: Globals.TileType) -> int:
    match tile:
        Globals.TileType.GEM_AMETHYST, Globals.TileType.GEM_TOPAZ: return 99
        Globals.TileType.ORE_COPPER, Globals.TileType.ORE_IRON, Globals.TileType.ORE_GOLD: return 999
        _: return 999