#include "shape_base.h"

Shader *shape_base::shaders[] = {0};

shape_base::shape_base(char shader_idx)
{
    this->shader_idx = shader_idx;
    VAO = -1;
    VBO = -1;
    EBO = -1;
    texture = 0;
}

shape_base::~shape_base()
{
    // optional: de-allocate all resources once they've outlived their purpose:
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    // glDeleteProgram(ourShader.ID);
}
