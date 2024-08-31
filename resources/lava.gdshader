shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Start color (bright orange)
uniform vec4 color2 : source_color = vec4(0.5, 0.0, 0.0, 1.0); // End color (dark red)
uniform float wave_speed : hint_range(0.0, 10.0) = 1.0; // Speed of the waving effect

void fragment() {
    vec2 uv = SCREEN_UV;

    // Calculate wave effect based on time and UV coordinates
    float wave = sin(uv.y * 10.0 + TIME * wave_speed) * 0.5 + 0.5;

    // Calculate gradient color
    float gradient = uv.y;
    COLOR = mix(color1, color2, gradient + wave * 0.2);
}
