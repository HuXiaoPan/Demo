#include <iostream>
#include "glad.h"
#include <GLFW/glfw3.h>
#include "WindowHelper.h"
#include "shader.h"
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

    // build and compile our shader program
    Shader ourShader("res/vs.glsl", "res/fs.glsl"); // you can name your shader files however you like
    Shader ourShader2 = Shader("res/cood_vs.glsl", "res/cood_fs.glsl");

    while (!glfwWindowShouldClose(window))
    {
        // input
        WindowHelper.processInput();
        // render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    glfwTerminate();
    return 0;
}
