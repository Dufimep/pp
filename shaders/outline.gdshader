shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    if (tex.a == 0.0) {
        // Check neighbors for outline
        vec2 texel = 1.0 / TEXTURE_PIXEL_SIZE;
        float max_alpha = 0.0;
        
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x != 0 || y != 0) {
                    vec2 offset = vec2(float(x), float(y)) * texel * outline_width;
                    float a = texture(TEXTURE, UV + offset).a;
                    max_alpha = max(max_alpha, a);
                }
            }
        }
        
        if (max_alpha > 0.0) {
            float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
            COLOR = outline_color * vec4(1.0, 1.0, 1.0, pulse * max_alpha);
        } else {
            COLOR = vec4(0.0);
        }
    } else {
        COLOR = tex;
    }
}