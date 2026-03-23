#pragma language glsl3

vec4 getAAPixel(Image tex, vec2 uv) {
    vec2 texSize = textureSize(tex, 0);
    vec2 pixelSpaceTexCoord = uv * texSize;
    vec2 centerCoord = floor(pixelSpaceTexCoord - 0.5f) + 0.5f;
    vec2 halfFWidth = fwidth(pixelSpaceTexCoord) * 0.5f;
    vec2 offset = smoothstep(
        0.5f - halfFWidth,
        0.5f + halfFWidth,
        pixelSpaceTexCoord - centerCoord
    );
    vec2 aauv = (centerCoord + offset) / texSize;
    return Texel(tex, aauv);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    return color * getAAPixel(tex, texture_coords);
}
