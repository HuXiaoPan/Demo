#include <iostream>
#include <cmath>
#include "glad.h"
#include <GLFW/glfw3.h>
#include "WindowHelper.h"
#include "vertexData.h"
#include "shape_line.h"

glm::mat4 trans = glm::mat4(1.0f);
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
    WindowHelper.Init();

    // uncomment this call to draw in wireframe polygons.
    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // render loop
    glEnable(GL_DEPTH_TEST);

    shape_line coord(coordinateLine, sizeof(coordinateLine));

    // // ourShader.use();
    // painter painter;

    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    // ourShader.setInt("texture1", 0);
    // ourShader.setInt("texture2", 1);
    WindowHelper.shp_map["coord"] = &coord;
    WindowHelper.draw();
    // while (!glfwWindowShouldClose(window))
    // {
    //     // ourShader.use();
    //     glBindVertexArray(painter.VAO[0]);



    //     // float timeValue = glfwGetTime();
    //     // float baseValue = (sin(timeValue) / 2.0f) + 0.5f;
    //     // int vertexColorLocation = glGetUniformLocation(ourShader.ID, "global_color");
    //     // glUniform4f(vertexColorLocation, 1.0f - baseValue, baseValue, abs(baseValue * 2 - 1.0f), 1.0f);
    //     // unsigned int transformLoc = glGetUniformLocation(ourShader.ID, "transform");
    //     // glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
    //     // // unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
    //     // // glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
    //     // unsigned int viewLoc = glGetUniformLocation(ourShader.ID, "view");
    //     // glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
    //     // unsigned int projectionLoc = glGetUniformLocation(ourShader.ID, "projection");
    //     // glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));

    //     // bind textures on corresponding texture units
    //     glActiveTexture(GL_TEXTURE0);
    //     glBindTexture(GL_TEXTURE_2D, painter.texture[0]);
    //     glActiveTexture(GL_TEXTURE1);
    //     glBindTexture(GL_TEXTURE_2D, painter.texture[1]);
    //     // render the triangle
    //     // glBindVertexArray(VAO[0]);
    //     // glDrawArrays(GL_TRIANGLES, 0, 36);

    //     // for (unsigned int i = 0; i < 10; i++)
    //     // {
    //     //     glm::mat4 model = glm::mat4(1.0f);
    //     //     model = glm::translate(model, cubePositions[i]);
    //     //     float angle = 20.0f * i;
    //     //     model = glm::rotate(model, (float)sin((float)glfwGetTime()) * glm::radians(angle + 35), glm::vec3(1.0f, 0.3f, 0.5f));
    //     //     unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
    //     //     glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));

    //     //     glDrawArrays(GL_TRIANGLES, 0, 36);
    //     // }



    // }
    return 0;
}
