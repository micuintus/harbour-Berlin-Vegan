#version 440

layout(location = 0) in vec2 vTC;
layout(location = 1) in float vLevel;

layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float clampFactor;
    float clampMin;
    float clampMax;
    float slope;
    float offset;
    int direction;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    fragColor = texture(source, vTC) * clamp(clampFactor + vLevel, clampMin, clampMax) * qt_Opacity;
}
