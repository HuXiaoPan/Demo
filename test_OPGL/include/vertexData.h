#ifndef VERTEXDATA_H
#define VERTEXDATA_H
float vertices[] = {
    //     ---- 位置 ----   ---- 颜色 ----      - 纹理坐标 -
    0.5f,   0.5f,   0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
    0.5f,   -0.5f,  0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,  // 右下
    -0.5f,  -0.5f,  0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f, // 左下
    -0.5f,  0.5f,   0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f   // 左上
};

unsigned int indices[] = {
    0, 1, 2,
    2, 3, 0};
#endif // !VERTEXDATA_H