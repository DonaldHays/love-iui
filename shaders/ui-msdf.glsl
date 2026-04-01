#pragma language glsl3

vec2 squared(vec2 v) {
    return v * v;
}

float screenPxRange(Image tex, vec2 uv) {
    vec2 unitRange = vec2(2) / textureSize(tex, 0);
    vec2 screenTexSize = inversesqrt(squared(dFdx(uv)) + squared(dFdy(uv)));
    
    return max(0.5 * dot(unitRange, screenTexSize), 1.0);
}

float median(float a, float b, float c) {
    return max(min(a, b), min(max(a, b), c));
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec3 msd = Texel(tex, texture_coords).rgb;
    float sd = median(msd.r, msd.g, msd.b);
    float screenPxDistance = screenPxRange(tex, texture_coords) * (sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);

    return vec4(color.rgb, color.a * opacity);
}
