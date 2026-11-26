#!/usr/bin/env python3
"""
Generate procedural tile atlas for Terraria Polish
Run with: python3 generate_atlas.py
Requires: pip install pillow
"""

from PIL import Image, ImageDraw
import random

# Atlas layout: 7 cols x 3 rows = 21 tiles (16x16 each)
TILE_SIZE = 16
COLS = 7
ROWS = 3
ATLAS_W = COLS * TILE_SIZE
ATLAS_H = ROWS * TILE_SIZE

img = Image.new('RGBA', (ATLAS_W, ATLAS_H), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Tile definitions: (x, y, base_color, noise_color, noise_count, special)
tiles = [
    # Row 0: Dirt, Grass, Stone, Wood, Copper, Iron, Gold
    (0, 0, (89, 56, 32), (120, 75, 40), 30, None),      # Dirt
    (1, 0, (48, 89, 32), (32, 140, 24), 0, 'grass'),    # Grass (with green top)
    (2, 0, (115, 115, 115), (150, 150, 150), 25, None), # Stone
    (3, 0, (166, 115, 64), (140, 95, 50), 20, 'wood'),  # Wood (vertical lines)
    (4, 0, (115, 115, 115), (204, 102, 51), 15, 'ore'), # Copper Ore
    (5, 0, (115, 115, 115), (153, 140, 128), 15, 'ore'), # Iron Ore
    (6, 0, (115, 115, 115), (255, 216, 51), 12, 'ore'), # Gold Ore
    # Row 1: Amethyst, Topaz, Sand, Clay, Mud, Ash, Obsidian
    (0, 1, (115, 115, 115), (179, 77, 230), 20, 'gem'), # Amethyst
    (1, 1, (115, 115, 115), (255, 153, 26), 20, 'gem'), # Topaz
    (2, 1, (217, 191, 128), (240, 220, 160), 30, None), # Sand
    (3, 1, (128, 77, 89), (160, 95, 110), 20, None),    # Clay
    (4, 1, (89, 64, 51), (110, 80, 65), 25, None),      # Mud
    (5, 1, (51, 51, 51), (80, 80, 80), 25, None),       # Ash
    (6, 1, (26, 13, 38), (50, 30, 70), 15, 'obsidian'), # Obsidian
    # Row 2: Hellstone (col 5), rest empty
    (5, 2, (38, 13, 13), (255, 77, 26), 25, 'hellstone'), # Hellstone
]

def draw_dirt(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)

def draw_grass(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    # Green top pixels
    for px in range(x, x+16):
        for py in range(y, y+4):
            if random.random() < 0.7:
                g = random.randint(80, 180)
                draw.point((px, py), fill=(20, g, 15, 255))

def draw_stone(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Crack lines
    for _ in range(2):
        x1 = random.randint(x, x+15)
        y1 = random.randint(y, y+15)
        x2 = x1 + random.randint(-4, 4)
        y2 = y1 + random.randint(-4, 4)
        draw.line([x1, y1, x2, y2], fill=(90, 90, 90), width=1)

def draw_wood(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    # Vertical wood grain
    for i in range(3):
        gx = x + 4 + i * 4
        for gy in range(y, y+16):
            if random.random() < 0.3:
                draw.point((gx, gy), fill=noise)
    # Rings
    for _ in range(2):
        rx = x + random.randint(3, 12)
        ry = y + random.randint(3, 12)
        for r in range(1, 4):
            draw.ellipse([rx-r, ry-r, rx+r, ry+r], outline=noise)

def draw_ore(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Highlight
    draw.point((x+3, y+3), fill=tuple(min(255, c+50) for c in noise))

def draw_gem(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Sparkle
    draw.point((x+5, y+5), fill=(255, 255, 255, 200))
    draw.point((x+10, y+10), fill=(255, 255, 255, 150))

def draw_sand(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)

def draw_clay(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)

def draw_mud(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Bubbles
    for _ in range(3):
        bx = random.randint(x+2, x+13)
        by = random.randint(y+2, y+13)
        draw.ellipse([bx-1, by-1, bx+1, by+1], fill=(100, 70, 55))

def draw_ash(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)

def draw_obsidian(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Glassy highlight
    draw.line([x+2, y+2, x+6, y+6], fill=(80, 50, 100), width=1)
    draw.line([x+10, y+10, x+14, y+14], fill=(80, 50, 100), width=1)

def draw_hellstone(draw, x, y, base, noise, count):
    draw.rectangle([x, y, x+15, y+15], fill=base)
    for _ in range(count):
        px = random.randint(x, x+15)
        py = random.randint(y, y+15)
        draw.point((px, py), fill=noise)
    # Glowing veins
    for _ in range(3):
        vx = random.randint(x, x+15)
        vy = random.randint(y, y+15)
        draw.line([vx, vy, vx+random.randint(-3,3), vy+random.randint(-3,3)], fill=(255, 100, 30), width=1)

drawers = {
    None: draw_dirt,
    'grass': draw_grass,
    'stone': draw_stone,
    'wood': draw_wood,
    'ore': draw_ore,
    'gem': draw_gem,
    'obsidian': draw_obsidian,
    'hellstone': draw_hellstone,
}

for col, row, base, noise, count, special in tiles:
    x = col * TILE_SIZE
    y = row * TILE_SIZE
    drawer = drawers.get(special, draw_dirt)
    drawer(draw, x, y, base, noise, count)

img.save('assets/tile_atlas.png')
print(f"Generated {ATLAS_W}x{ATLAS_H} tile atlas at assets/tile_atlas.png")
print("Tiles:")
for col, row, _, _, _, special in tiles:
    name = special or ['Dirt','Stone','Sand','Clay','Mud','Ash'][row*COLS+col] if special is None else special
    print(f"  ({col},{row}) = {name}")