// // #version 330 core
// // layout (location = 0) in vec3 aPos;
// // layout (location = 1) in vec3 aColor;
// // out vec3 ourColor;
// // uniform vec4 global_color;
// // void main()
// // {
// //    gl_Position = vec4(aPos, 1.0);
// //    ourColor = global_color.rgb;
// // }

// #version 330 core
// layout (location = 0) in vec3 aPos;
// // layout (location = 1) in vec3 aColor;
// layout (location = 1) in vec2 aTexCoord;

// out vec3 ourColor;
// out vec2 TexCoord;

// // uniform mat4 transform;
// uniform mat4 model;
// uniform mat4 view;
// uniform mat4 projection;

// uniform vec4 global_color;
// void main()
// {
//     gl_Position = /*transform * */projection * view * model * vec4(aPos, 1.0);
//     // ourColor = aColor;
//     ourColor = global_color.rgb;
//     TexCoord = aTexCoord;
// }