# scripts/background_parallax.gd
extends Node2D
class_name BackgroundParallax

@onready var sky: ColorRect = %Sky
@onready var far_mountains: ParallaxBackground = %FarMountains
@onready var mid_mountains: ParallaxBackground = %MidMountains
@onready var clouds: ParallaxBackground = %Clouds
@onready var sun_moon: Sprite2D = %SunMoon
@onready var stars: GPUParticles2D = %Stars

var _time_of_day: float = 0.5
var _target_sky_color: Color
var _current_biome: Globals.BiomeType = Globals.BiomeType.SURFACE

func _ready() -> void:
    _setup_parallax()
    _update_sky_color()

func _setup_parallax() -> void:
    # Far mountains (slowest)
    var far_layer = ParallaxLayer.new()
    far_layer.motion_scale = Vector2(0.05, 0.02)
    far_layer.motion_offset = Vector2(0, 200)
    far_mountains.add_child(far_layer)
    
    # Mid mountains
    var mid_layer = ParallaxLayer.new()
    mid_layer.motion_scale = Vector2(0.15, 0.05)
    mid_layer.motion_offset = Vector2(0, 150)
    mid_mountains.add_child(mid_layer)
    
    # Clouds (fastest)
    var cloud_layer = ParallaxLayer.new()
    cloud_layer.motion_scale = Vector2(0.3, 0.1)
    cloud_layer.motion_offset = Vector2(0, 50)
    clouds.add_child(cloud_layer)
    
    # Generate procedural background sprites
    _generate_background_sprites(far_layer, 5, Color(0.3, 0.35, 0.5), 300)
    _generate_background_sprites(mid_layer, 8, Color(0.4, 0.4, 0.55), 200)
    _generate_cloud_sprites(cloud_layer, 12, Color(0.8, 0.8, 0.9, 0.6), 100)

func _generate_background_sprites(parent: ParallaxLayer, count: int, base_color: Color, y_base: float) -> void:
    for i in range(count):
        var sprite = Sprite2D.new()
        var img = Image.create(512, 256, false, Image.FORMAT_RGBA8)
        img.fill(Color(0, 0, 0, 0))
        
        # Draw mountain silhouette
        var points = []
        var x = 0
        while x < 512:
            var w = randi_range(30, 80)
            var h = randi_range(60, 150)
            for px in range(w):
                var py = int(h * (1.0 - abs(px - w/2) / (w/2)))
                for dy in range(py):
                    if x + px < 512 and y_base + dy < 256:
                        img.set_pixel(x + px, 255 - (y_base + dy), base_color)
            points.append(Vector2(x, 255 - y_base))
            x += w
        
        sprite.texture = ImageTexture.create_from_image(img)
        sprite.position = Vector2(i * 550 - 1000, -y_base)
        parent.add_child(sprite)

func _generate_cloud_sprites(parent: ParallaxLayer, count: int, color: Color, y_base: float) -> void:
    for i in range(count):
        var sprite = Sprite2D.new()
        var img = Image.create(256, 128, false, Image.FORMAT_RGBA8)
        img.fill(Color(0, 0, 0, 0))
        
        # Draw cloud
        var cx = 128
        var cy = 64
        for x in range(256):
            for y in range(128):
                var dx = (x - cx) / 80.0
                var dy = (y - cy) / 40.0
                var dist = sqrt(dx*dx + dy*dy)
                if dist < 1.0 + randf() * 0.3:
                    var alpha = (1.0 - dist) * color.a * 0.8
                    img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
        
        sprite.texture = ImageTexture.create_from_image(img)
        sprite.position = Vector2(i * 600 - 2000, -y_base - randi_range(0, 100))
        sprite.modulate = color
        parent.add_child(sprite)

func set_time_of_day(time: float) -> void:
    _time_of_day = time
    _update_sky_color()
    _update_sun_moon()
    _update_stars()

func _update_sky_color() -> void:
    var biome_color = Globals.BIOME_SKY_COLORS.get(_current_biome, Globals.BIOME_SKY_COLORS[Globals.BiomeType.SURFACE])
    var night_color = Color(0.05, 0.05, 0.15)
    var day_color = biome_color
    
    var day_factor = max(0.0, sin(_time_of_day * TAU))
    var final_color = night_color.lerp(day_color, day_factor)
    
    # Dawn/dusk colors
    if _time_of_day > 0.2 && _time_of_day < 0.3:
        var dawn = Color(1.0, 0.5, 0.3)
        final_color = final_color.lerp(dawn, 0.5)
    elif _time_of_day > 0.7 && _time_of_day < 0.8:
        var dusk = Color(0.8, 0.3, 0.4)
        final_color = final_color.lerp(dusk, 0.5)
    
    sky.color = final_color
    _target_sky_color = final_color

func _update_sun_moon() -> void:
    var angle = _time_of_day * TAU - PI/2
    var radius = 600.0
    var pos = Vector2(cos(angle), sin(angle)) * radius
    sun_moon.global_position = pos + get_viewport().get_visible_rect().size / 2
    
    if _time_of_day > 0.25 && _time_of_day < 0.75:
        # Sun
        sun_moon.modulate = Color(1.0, 1.0, 0.8, 1.0)
        sun_moon.scale = Vector2(1.5, 1.5)
    else:
        # Moon
        sun_moon.modulate = Color(0.9, 0.9, 1.0, 0.8)
        sun_moon.scale = Vector2(1.0, 1.0)
    
    # Rotate to face center
    sun_moon.rotation = -angle + PI/2

func _update_stars() -> void:
    if _time_of_day > 0.3 && _time_of_day < 0.7:
        stars.emitting = false
        stars.amount = 0
    else:
        stars.emitting = true
        var intensity = 1.0 - abs(_time_of_day - 0.5) * 2.0
        stars.amount = int(200 * intensity)

func set_biome(biome: Globals.BiomeType) -> void:
    _current_biome = biome
    _update_sky_color()
    
    # Update mountain colors
    var biome_color = Globals.BIOME_SKY_COLORS.get(biome, Color(0.4, 0.65, 0.95))
    var darkened = Color(biome_color.r * 0.4, biome_color.g * 0.4, biome_color.b * 0.5)
    
    for layer in [far_mountains, mid_mountains]:
        for child in layer.get_children():
            if child is ParallaxLayer:
                for sprite in child.get_children():
                    if sprite is Sprite2D:
                        sprite.modulate = darkened