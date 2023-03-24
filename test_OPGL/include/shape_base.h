#ifndef SHAPE_BASE_H
#define SHAPE_BASE_H

#include "shader.h"

class Shader;
class shape_base
{
protected:
    static const char shader_num = 8;
    unsigned int VAO;
    unsigned int VBO;
    unsigned int EBO;
    unsigned int *texture;
    char shader_idx;
    unsigned int size;
    unsigned int size_ebo;

public:
    glm::mat4 model = glm::mat4(1.0f);
    glm::mat4 view = glm::mat4(1.0f);
    glm::mat4 projection = glm::mat4(1.0f);

    static Shader *shaders[shader_num];
    shape_base(char shader_idx = 0);
    ~shape_base();
    virtual void draw() = 0;
};

#endif // SHAPE_BASE_H