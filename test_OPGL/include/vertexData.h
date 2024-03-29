#ifndef VERTEXDATA_H
#define VERTEXDATA_H

float test[] = {
    //     ---- 位置 ----   ---- 颜色 ----      - 纹理坐标 -
    0.5f,   0.5f,   0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
    0.5f,   -0.5f,  0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,  // 右下
    -0.5f,  -0.5f,  0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f, // 左下
    -0.5f,  0.5f,   0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f   // 左上
};

float coordinateLine[] = {
    -100.0f, 0.0f     ,      0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
     100.0f, 0.0f     ,      0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
    0.0f     , -100.0f,      0.0f, 0.0f, 1.0f, 0.0f, 1.0f,
    0.0f     ,  100.0f,      0.0f, 0.0f, 1.0f, 0.0f, 1.0f,
    0.0f     , 0.0f     , -100.0f, 0.0f, 0.0f, 1.0f, 1.0f,
    0.0f     , 0.0f     ,  100.0f, 0.0f, 0.0f, 1.0f, 1.0f};

float coordinatePlat[] = {
    -100.0f,   0.0f, -100.0f, 0.1f, 0.0f, 0.0f, 0.7f,
     100.0f,   0.0f, -100.0f, 0.1f, 0.0f, 0.0f, 0.7f,
     100.0f,   0.0f,  100.0f, 0.1f, 0.0f, 0.0f, 0.7f,
    -100.0f,   0.0f,  100.0f, 0.1f, 0.0f, 0.0f, 0.7f,

    -100.0f, -100.0f,   0.0f, 0.0f, 0.1f, 0.0f, 0.7f,
     100.0f, -100.0f,   0.0f, 0.0f, 0.1f, 0.0f, 0.7f,
     100.0f,  100.0f,   0.0f, 0.0f, 0.1f, 0.0f, 0.7f,
    -100.0f,  100.0f,   0.0f, 0.0f, 0.1f, 0.0f, 0.7f,
     
      0.0f, -100.0f, -100.0f, 0.0f, 0.0f, 0.1f, 0.7f,
      0.0f,  100.0f, -100.0f, 0.0f, 0.0f, 0.1f, 0.7f,
      0.0f,  100.0f,  100.0f, 0.0f, 0.0f, 0.1f, 0.7f,
      0.0f, -100.0f,  100.0f, 0.0f, 0.0f, 0.1f, 0.7f};

unsigned int elem_Plat[] = {
        0,1,2,
        2,3,0,
        4,5,6,
        6,7,4,
        8,9,10,
        10,11,8};

float vertices[] = {
    -0.5f, -0.5f, -0.5f, 0.0f, 0.0f,
    0.5f, -0.5f, -0.5f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f, 1.0f, 1.0f,
    0.5f, 0.5f, -0.5f, 1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f, 0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, 0.0f, 0.0f,

    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 1.0f, 1.0f,
    0.5f, 0.5f, 0.5f, 1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,

    -0.5f, 0.5f, 0.5f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f, 1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f, 1.0f, 0.0f,

    0.5f, 0.5f, 0.5f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f, 1.0f, 1.0f,
    0.5f, -0.5f, -0.5f, 0.0f, 1.0f,
    0.5f, -0.5f, -0.5f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 1.0f, 0.0f,

    -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,
    0.5f, -0.5f, -0.5f, 1.0f, 1.0f,
    0.5f, -0.5f, 0.5f, 1.0f, 0.0f,
    0.5f, -0.5f, 0.5f, 1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,

    -0.5f, 0.5f, -0.5f, 0.0f, 1.0f,
    0.5f, 0.5f, -0.5f, 1.0f, 1.0f,
    0.5f, 0.5f, 0.5f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f, 0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f, 0.0f, 1.0f};

unsigned int indices[] = {
    0, 1, 2,
    2, 3, 0};

#endif // !VERTEXDATA_H