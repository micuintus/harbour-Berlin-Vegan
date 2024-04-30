#version 440

// Input variables
layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;


// Output variables
layout(location = 0) out vec2 vTC;
layout(location = 1) out float vLevel;

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
    gl_Position = qt_Matrix * qt_Vertex;
    vTC = qt_MultiTexCoord0;

    // Right-to-left
    if (direction == 1)
        vLevel = 1.0 + slope * (qt_MultiTexCoord0.x - 1.0 + offset);

    // Top-to-bottom
    else if (direction == 2)
        vLevel = 1.0 - slope * (qt_MultiTexCoord0.y - offset);

    // Bottom-to-top
    else if (direction == 3)
        vLevel = 1.0 + slope * (qt_MultiTexCoord0.y - 1.0 + offset);

    // Left-to-right (and any bogus value)
    else
        vLevel = 1.0 - slope * (qt_MultiTexCoord0.x - offset);
}
