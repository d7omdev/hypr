
#version 320 es
precision mediump float;

uniform sampler2D tex;
in vec2 v_texcoord;
out vec4 fragColor;

void main() {
    vec4 col = texture(tex, v_texcoord);

    // Warm filter: reduce blue, slightly reduce green
    col.r *= 1.0;
    col.g *= 0.9;
    col.b *= 0.7;

    fragColor = col;
}

