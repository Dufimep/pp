shader_type canvas_item;

uniform sampler2D light_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float ambient : hint_range(0.0, 1.0) = 0.3;
uniform vec4 light_color : source_color = vec4(1.0, 0.95, 0.85, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 light = texture(light_texture, SCREEN_UV);
    
    // Combine texture with lighting
    float luminance = dot(light.rgb, vec3(0.299, 0.587, 0.114));
    float final_light = max(ambient, luminance);
    
    COLOR = tex * vec4(light_color.rgb * final_light, tex.a);
}