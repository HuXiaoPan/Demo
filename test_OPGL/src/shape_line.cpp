#include "shape_line.h"
#include "glad.h"

shape_line::shape_line(float *data, int size) : shape_base(0)
{
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
    glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
    glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
    glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);

    float pitch = 0.0f, yaw = 0.0f;
    float fov = 45.0f;
    float lastX = 400, lastY = 300;
    bool firstMouse = true;
    shaders[shader_idx]->use();
    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    glEnable(GL_DEPTH_TEST);
    glm::mat4 model = glm::mat4(1.0f);
    glm::mat4 view = glm::mat4(1.0f);
    view = glm::lookAt(cameraPos,
                       cameraPos + cameraFront,
                       cameraUp);
    glm::mat4 projection = glm::mat4(1.0f);
    // model = glm::rotate(model, sin((float)glfwGetTime()) * glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
    view = glm::translate(view, glm::vec3(-3.0f, -3.0f, -10.0f));
    projection = glm::perspective(glm::radians(fov), 1.0f * 4 / 3, 0.1f, 100.0f);
    model = glm::rotate(model, glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
    unsigned int modelLoc = glGetUniformLocation(shaders[shader_idx]->ID, "model");
    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
    unsigned int viewLoc = glGetUniformLocation(shaders[shader_idx]->ID, "view");
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
    unsigned int projectionLoc = glGetUniformLocation(shaders[shader_idx]->ID, "projection");
    glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));
    glBindVertexArray(VAO);
    glDrawArrays(GL_LINES, 0, 6);
    glPointSize(5.0f);
    glDrawArrays(GL_POINTS, 0, 6);
    // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
    // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}