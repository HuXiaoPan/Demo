#include "shape_line.h"
#include "glad.h"

shape_line::shape_line(float *data, int size) : shape_base(0)
{
    this->size = size/28;
    // set up vertex data (and buffer(s)) and configure vertex attributes
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_STATIC_DRAW);
    // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
    // glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);

    // color attribute
    // glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)(3 * sizeof(float)));
    // glEnableVertexAttribArray(1);

    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    // You can unbind the VAO afterwards so other VAO c#include "GLFW/glfw3.h"alls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0);
}

void shape_line::draw()
{
    shaders[shader_idx]->use();
    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    projection = glm::perspective(glm::radians(45.0f), 1.0f * 4 / 3, 0.1f, 1000000.0f);
    // model = glm::rotate(model, glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
    shaders[shader_idx]->setMat4("model", model);
    shaders[shader_idx]->setMat4("view", view);
    shaders[shader_idx]->setMat4("projection", projection);
    glBindVertexArray(VAO);
    glLineWidth(2.0f);
    glDrawArrays(GL_LINES, 0, size);
    // glPointSize(5.0f);
    // glDrawArrays(GL_POINTS, 0, 6);

    // for (unsigned int i = 0; i < 100; i++)
    // {
    //     glm::mat4 model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(i * 1.0f + 1.0f, 0.0f, 0.0f));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 0, 1);
    //     model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(-(i * 1.0f + 1.0f), 0.0f, 0.0f));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 1, 1);
    //     model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(0.0f, i * 1.0f + 1.0f, 0.0f));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 2, 1);
    //     model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(0.0f, -(i * 1.0f + 1.0f), 0.0f));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 3, 1);
    //     model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(0.0f, 0.0f, i * 1.0f + 1.0f));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 4, 1);
    //     model = glm::mat4(1.0f);
    //     model = glm::translate(model, glm::vec3(0.0f, 0.0f, -(i * 1.0f + 1.0f)));
    //     shaders[shader_idx]->setMat4("model", model);
    //     glDrawArrays(GL_POINTS, 5, 1);
    // }

    // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
    // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}