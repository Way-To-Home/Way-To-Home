shader_type canvas_item;

uniform float speed = 0.02;
uniform float density = 0.6;
uniform float scale = 2.0;

// Base fog color (acts as a multiplier)
uniform vec4 fog_color : source_color = vec4(0.4, 0.2, 0.5, 0.6);

// Random
float random(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

// Fractal noise
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;

    for (int i = 0; i < 4; i++) {
        value += noise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

void fragment() {
    vec2 uv = UV * scale;

    // Smooth drifting motion
    vec2 motion = vec2(TIME * speed, TIME * speed * 0.5);
    float n = fbm(uv + motion);

    // Fog shaping
    float fog = smoothstep(0.3, 0.8, n) * density;

    // Deep animated nebula colors
    vec3 animated_color = vec3(
        0.3 + 0.2 * sin(TIME * 0.4),   // deep red-magenta
        0.1 + 0.3 * sin(TIME * 0.5),   // muted greenish tint
        0.4 + 0.4 * sin(TIME * 0.6)    // strong deep blue
    );

    // Blend with base fog color for richness
    vec3 final_color = mix(fog_color.rgb, animated_color, 0.7);

    COLOR = vec4(final_color, fog * fog_color.a);
}
