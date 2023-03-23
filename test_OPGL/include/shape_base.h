#ifndef SHAPE_BASE_H
#define SHAPE_BASE_H


#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

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

public:
    static Shader *shaders[shader_num];
    shape_base(char shader_idx);
    ~shape_base();
    virtual void draw() = 0;
};

#endif // SHAPE_BASE_H