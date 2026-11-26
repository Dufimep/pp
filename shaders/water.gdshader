shader_type canvas_item;

uniform float time : hint_range(0.0, 1000.0) = 0.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.2;
uniform float wave_height : hint_range(0.0, 10.0) = 3.0;
uniform vec4 deep_color : source_color = vec4(0.1, 0.3, 0.6, 0.8);
uniform vec4 shallow_color : source_color = vec4(0.2, 0.5, 0.8, 0.6);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);

void vertex() {
    // Subtle vertex wave for water surface
    VERTEX.y += sin(TIME * wave_speed + VERTEX.x * 0.1) * wave_height * 0.1;
}

void fragment() {
    vec2 uv = UV;
    
    // Animated UV distortion
    float wave1 = sin(uv.x * 8.0 + TIME * wave_speed) * 0.02;
    float wave2 = sin(uv.y * 6.0 + TIME * wave_speed * 1.3) * 0.015;
    float wave3 = sin((uv.x + uv.y) * 4.0 + TIME * wave_speed * 0.7) * 0.01;
    
    uv.x += wave1 + wave2;
    uv.y += wave2 + wave3;
    
    // Depth-based color
    float depth = uv.y;
    vec4 color = mix(shallow_color, deep_color, depth);
    
    // Foam at top
    float foam = smoothstep(0.0, 0.15, uv.y) * (1.0 - smoothstep(0.85, 1.0, uv.y));
    foam *= sin(uv.x * 20.0 + TIME * 3.0) * 0.5 + 0.5;
    color = mix(color, foam_color, foam * 0.3);
    
    // Caustics
    float caustic = sin(uv.x * 30.0 + TIME * 2.0) * sin(uv.y * 20.0 + TIME * 1.5);
    color.rgb += caustic * 0.05;
    
    COLOR = color;
}