shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0, 0.05) = 0.015;
uniform float speed : hint_range(0.0, 5.0) = 1.2;
uniform float scale : hint_range(1.0, 50.0) = 15.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    float t = TIME * speed;

    // две плавные волны
    float wave1 = sin(UV.y * scale + t) * 0.5;
    float wave2 = sin(UV.y * scale * 0.6 - t * 0.7) * 0.5;

    float distortion = (wave1 + wave2) * strength;

    uv.x += distortion;

    COLOR = texture(SCREEN_TEXTURE, uv);
}