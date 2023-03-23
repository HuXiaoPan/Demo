#include <iostream>
#include <cmath>
#include "glad.h"
#include <GLFW/glfw3.h>
#include "WindowHelper.h"
#include "shader.h"
#include "painter.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

glm::mat4 trans = glm::mat4(1.0f);

glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);

float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间

float pitch = 0.0f, yaw = 0.0f;
float fov = 45.0f;
float lastX = 400, lastY = 300;
bool firstMouse = true;

glm::vec3 cubePositions[] = {
    glm::vec3(0.0f, 0.0f, 0.0f),
    glm::vec3(2.0f, 5.0f, -15.0f),
    glm::vec3(-1.5f, -2.2f, -2.5f),
    glm::vec3(-3.8f, -2.0f, -12.3f),
    glm::vec3(2.4f, -0.4f, -3.5f),
    glm::vec3(-1.7f, 3.0f, -7.5f),
    glm::vec3(1.3f, -2.0f, -2.5f),
    glm::vec3(1.5f, 2.0f, -2.5f),
    glm::vec3(1.5f, 0.2f, -1.5f),
    glm::vec3(-1.3f, 1.0f, -1.5f)};

int main_test_OPGL(int argc, char const *argv[])
{
    WindowHelper WindowHelper;
    WindowHelper.Init();
    GLFWwindow *window = WindowHelper.GetWindow();
    if (window == nullptr)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    if (!WindowHelper.InitGlad())
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        glfwTerminate();
        return -1;
    }

    // uncomment this call to draw in wireframe polygons.
    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // render loop
    glEnable(GL_DEPTH_TEST);

    // build and compile our shader program
    Shader ourShader("res/vs.glsl", "res/fs.glsl"); // you can name your shader files however you like
    Shader ourShader2 = Shader("res/cood_vs.glsl", "res/cood_fs.glsl");

    ourShader.use();
    painter painter;

    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    ourShader.setInt("texture1", 0);
    ourShader.setInt("texture2", 1);

    while (!glfwWindowShouldClose(window))
    {

        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        ourShader.use();
        glBindVertexArray(painter.VAO[0]);

        glm::mat4 view = glm::mat4(1.0f);
        view = glm::lookAt(cameraPos,
                           cameraPos + cameraFront,
                           cameraUp);
        glm::mat4 projection = glm::mat4(1.0f);
        // model = glm::rotate(model, sin((float)glfwGetTime()) * glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
        view = glm::translate(view, glm::vec3(-5.0f, -5.0f, -10.0f));
        projection = glm::perspective(glm::radians(fov), 1.0f * 4 / 3, 0.1f, 100.0f);

        // input
        WindowHelper.processInput();
        // render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        float timeValue = glfwGetTime();
        float baseValue = (sin(timeValue) / 2.0f) + 0.5f;
        int vertexColorLocation = glGetUniformLocation(ourShader.ID, "global_color");
        glUniform4f(vertexColorLocation, 1.0f - baseValue, baseValue, abs(baseValue * 2 - 1.0f), 1.0f);
        unsigned int transformLoc = glGetUniformLocation(ourShader.ID, "transform");
        glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
        // unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
        // glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
        unsigned int viewLoc = glGetUniformLocation(ourShader.ID, "view");
        glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
        unsigned int projectionLoc = glGetUniformLocation(ourShader.ID, "projection");
        glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));

        // bind textures on corresponding texture units
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, painter.texture[0]);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, painter.texture[1]);
        // render the triangle
        // glBindVertexArray(VAO[0]);
        // glDrawArrays(GL_TRIANGLES, 0, 36);

        for (unsigned int i = 0; i < 10; i++)
        {
            glm::mat4 model = glm::mat4(1.0f);
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * i;
            model = glm::rotate(model, (float)sin((float)glfwGetTime()) * glm::radians(angle + 35), glm::vec3(1.0f, 0.3f, 0.5f));
            unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
            glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }

        // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
        // -------------------------------------------------------------------------------------------
        ourShader2.use();
        // glEnable(GL_DEPTH_TEST);
        glm::mat4 c_model = glm::mat4(1.0f);
        // c_model = glm::rotate(c_model, glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
        unsigned int c_modelLoc = glGetUniformLocation(ourShader2.ID, "c_model");
        glUniformMatrix4fv(c_modelLoc, 1, GL_FALSE, glm::value_ptr(c_model));
        unsigned int c_viewLoc = glGetUniformLocation(ourShader2.ID, "c_view");
        glUniformMatrix4fv(c_viewLoc, 1, GL_FALSE, glm::value_ptr(view));
        unsigned int c_projectionLoc = glGetUniformLocation(ourShader2.ID, "c_projection");
        glUniformMatrix4fv(c_projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));
        glBindVertexArray(painter.VAO[1]);
        glDrawArrays(GL_LINES, 0, 6);
        // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
        // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // optional: de-allocate all resources once they've outlived their purpose:
    glDeleteVertexArrays(1, painter.VAO);
    glDeleteBuffers(1, painter.VBO);
    glDeleteBuffers(1, painter.EBO);
    glDeleteProgram(ourShader.ID);

    glfwTerminate();
    return 0;
}
