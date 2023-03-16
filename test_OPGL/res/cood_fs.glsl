#version 330 core
in vec3 cood_color;
out vec4 FragColor;

void main()
{
    FragColor = vec4(cood_color, 0.5);
}