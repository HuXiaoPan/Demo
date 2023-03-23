// #version 330 core
// out vec4 FragColor;
// in vec3 ourColor;
// void main()
// {
//    FragColor = vec4(ourColor, 1.0f);
// }

#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

// texture samplers
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float a;

void main()
{
    // FragColor = texture(texture1, TexCoord) * vec4(ourColor, 1.0);
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, vec2(1.0 - TexCoord.x, TexCoord.y)), 0.5) * vec4(ourColor, 1.0);
}