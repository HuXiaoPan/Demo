#version 330 core
layout (location = 0) in vec3 cood_pos;
// layout (location = 1) in vec3 aColor;
layout (location = 1) in vec3 in_cood_color;

uniform mat4 c_transform;
uniform mat4 c_model;
uniform mat4 c_view;
uniform mat4 c_projection;

out vec3 cood_color;
void main()
{
    gl_Position = c_projection * c_view * c_model * vec4(cood_pos, 1.0);
    cood_color = in_cood_color;
}