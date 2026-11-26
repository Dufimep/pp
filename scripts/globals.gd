# scripts/globals.gd
extends Node

# === CONSTANTS ===
const TILE_SIZE: int = 16
const CHUNK_SIZE: int = 64
const CHUNK_PIXELS: int = CHUNK_SIZE * TILE_SIZE
const GRAVITY: float = 980.0
const MOVE_SPEED: float = 220.0
const JUMP_VELOCITY: float = -520.0
const REACH_DISTANCE: float = 6.5 * TILE_SIZE
const MAX_HEALTH: int = 100
const INV_SLOTS: int = 10

# === ENUMS ===
enum TileType {
    AIR = -1,
    DIRT = 0,
    GRASS = 1,
    STONE = 2,
    WOOD = 3,
    ORE_COPPER = 4,
    ORE_IRON = 5,
    ORE_GOLD = 6,
    GEM_AMETHYST = 7,
    GEM_TOPAZ = 8,
    SAND = 9,
    CLAY = 10,
    MUD = 11,
    ASH = 12,
    OBSIDIAN = 13,
    HELLSTONE = 14
}

enum ToolType { PICKAXE, AXE, HAMMER, BLOCK, SWORD, BOW }
enum BiomeType { SURFACE, UNDERGROUND, CAVERN, HELL, JUNGLE, DESERT, SNOW, CORRUPTION, CRIMSON, HOLLOW }

# === SIGNALS ===
signal tile_changed(pos: Vector2i, tile: TileType, biome: BiomeType)
signal tile_broken(pos: Vector2i, tile: TileType, drops: Array[Dictionary])
signal tile_placed(pos: Vector2i, tile: TileType)
signal player_damaged(amount: int, knockback: Vector2)
signal player_healed(amount: int)
signal health_changed(current: int, max: int)
signal mana_changed(current: int, max: int)
signal inventory_changed()
signal biome_changed(biome: BiomeType)
signal day_time_changed(time: float)  # 0.0 - 1.0
signal weather_changed(type: String, intensity: float)

# === HELPERS ===
static func world_to_chunk(pos: Vector2i) -> Vector2i:
    return Vector2i(
        floor(pos.x / CHUNK_SIZE),
        floor(pos.y / CHUNK_SIZE)
    )

static func chunk_to_world(chunk: Vector2i) -> Vector2i:
    return chunk * CHUNK_SIZE

static func is_valid_tile(tile: TileType) -> bool:
    return tile != TileType.AIR

# === BIOME COLORS (for lighting/background) ===
static var BIOME_SKY_COLORS: Dictionary = {
    BiomeType.SURFACE: Color(0.4, 0.65, 0.95),
    BiomeType.UNDERGROUND: Color(0.15, 0.12, 0.2),
    BiomeType.CAVERN: Color(0.08, 0.06, 0.15),
    BiomeType.HELL: Color(0.3, 0.05, 0.02),
    BiomeType.JUNGLE: Color(0.2, 0.5, 0.25),
    BiomeType.DESERT: Color(0.95, 0.85, 0.6),
    BiomeType.SNOW: Color(0.6, 0.75, 0.9),
    BiomeType.CORRUPTION: Color(0.25, 0.05, 0.35),
    BiomeType.CRIMSON: Color(0.35, 0.05, 0.1),
    BiomeType.HOLLOW: Color(0.5, 0.7, 0.9)
}

static var BIOME_FOG_COLORS: Dictionary = {
    BiomeType.SURFACE: Color(0.5, 0.7, 0.9, 0.3),
    BiomeType.UNDERGROUND: Color(0.2, 0.15, 0.3, 0.6),
    BiomeType.CAVERN: Color(0.1, 0.08, 0.2, 0.8),
    BiomeType.HELL: Color(0.4, 0.1, 0.05, 0.7),
    BiomeType.JUNGLE: Color(0.15, 0.4, 0.2, 0.5),
    BiomeType.DESERT: Color(0.9, 0.8, 0.5, 0.4),
    BiomeType.SNOW: Color(0.7, 0.85, 0.95, 0.5),
    BiomeType.CORRUPTION: Color(0.3, 0.1, 0.4, 0.6),
    BiomeType.CRIMSON: Color(0.4, 0.1, 0.15, 0.6),
    BiomeType.HOLLOW: Color(0.6, 0.8, 0.95, 0.4)
}