shader_type spatial;

uniform vec3 potion_color : source_color = vec3(0.1, 0.5, 0.2);
uniform vec3 bubble_color : source_color = vec3(0.4, 0.8, 0.3);
uniform float swirl_speed : hint_range(0.0, 10.0) = 2.0;
uniform float bubble_intensity : hint_range(0.0, 5.0) = 1.5;

// Функция для создания процедурного шума
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    // Центрируем UV координаты для водоворота (-0.5 до 0.5)
    vec2 uv = UV - 0.5;
    float dist = length(uv);

    // Эффект водоворота (вращение зависит от расстояния к центру)
    float angle = TIME * swirl_speed + dist * 10.0;
    float s = sin(angle);
    float c = cos(angle);
    vec2 swirled_uv = vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);

    // Создаем "пузыри" через шум и синус
    float bubbles = sin(swirled_uv.x * 20.0 + TIME) * cos(swirled_uv.y * 20.0 - TIME);
    bubbles *= smoothstep(0.4, 0.5, hash(floor(swirled_uv * 10.0) + floor(TIME * 2.0)));

    // Смешиваем цвета
    vec3 final_color = mix(potion_color, bubble_color, clamp(bubbles * bubble_intensity, 0.0, 1.0));

    // Добавляем "глубину" (затемнение по краям котла)
    final_color *= smoothstep(0.5, 0.2, dist);

    ALBEDO = final_color;
    ROUGHNESS = 0.1; // Делаем поверхность глянцевой, как жидкость
    SPECULAR = 0.5;
}