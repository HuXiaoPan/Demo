#include "WindowHelper.h"
#include "glad.h"
#include <GLFW/glfw3.h>
#include <GLFW/glfw3native.h>
#include "shader.h"

#include "shape_base.h"
#include "camera.h"

void framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
    if (WindowHelper::curr_winHelper)
        WindowHelper::curr_winHelper->framebuffer_size_callback(window, width, height);
}

void key_callback(GLFWwindow *window, int key, int scancode, int action, int mode)
{
    if (WindowHelper::curr_winHelper)
        WindowHelper::curr_winHelper->key_callback(window, key, scancode, action, mode);
}

void mouse_callback(GLFWwindow *window, double xpos, double ypos)
{
    if (WindowHelper::curr_winHelper)
        WindowHelper::curr_winHelper->mouse_callback(window, xpos, ypos);
}

void scroll_callback(GLFWwindow *window, double xoffset, double yoffset)
{
    if (WindowHelper::curr_winHelper)
        WindowHelper::curr_winHelper->scroll_callback(window, xoffset, yoffset);
}

WindowHelper *WindowHelper::curr_winHelper = nullptr;
WindowHelper::WindowHelper(char *title, unsigned int width, unsigned int height) : title(title), width(width), height(height), window(nullptr)
{
    curr_winHelper = this;
}

WindowHelper::~WindowHelper()
{
    glfwTerminate();
}
GLFWwindow *WindowHelper::GetWindow()
{
    // glfw: initialize and configure
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    if (window)
        return window;
    // glfw window creation
    // --------------------
    window = glfwCreateWindow(width, height, title, NULL, NULL);
    if (window == NULL)
        return nullptr;
    glfwMakeContextCurrent(window);
    // glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwSetFramebufferSizeCallback(window, ::framebuffer_size_callback);
    glfwSetKeyCallback(window, ::key_callback);
    glfwSetCursorPosCallback(window, ::mouse_callback);
    glfwSetScrollCallback(window, ::scroll_callback);
    return window;
}

bool WindowHelper::InitGlad()
{
    return gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
}

void WindowHelper::Init()
{
    glEnable(GL_BLEND); // 打开混合
    glEnable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE); // 基于源象素alpha通道值的半透明混合函数
    // build and compile our shader program
    shape_base::shaders[0] = new Shader("res/vs_vc7f.glsl", "res/fs_vc7f.glsl"); // you can name your shader files however you like
    // shape_base::shaders[1] = new Shader("res/vs.glsl", "res/fs.glsl");
    camera = new Camera(glm::vec3(1.0f, 1.0f, 3.0f));
}

void WindowHelper::processInput()
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    float cameraSpeed = 2.5f * deltaTime;
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::RIGHT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::UP, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
        camera->ProcessKeyboard(Camera_Movement::DOWN, deltaTime);
    if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS)
        mouse_button_right = true;
    if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_RELEASE)
        mouse_button_right = false;
}

void WindowHelper::framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    this->width = width;
    this->height = height;
    glViewport(0, 0, width, height);
}

void WindowHelper::draw()
{
    while (!glfwWindowShouldClose(window))
    {
        updateDeltaTime();
        // input
        processInput();
        // render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        for (auto var : shp_map)
        {
            var.second->view = camera->GetViewMatrix();
            var.second->draw();
        }
        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}

void WindowHelper::key_callback(GLFWwindow *window, int key, int scancode, int action, int mode)
{
    //     // 当用户按下ESC键,我们设置window窗口的WindowShouldClose属性为true
    //     // 关闭应用程序
    //     if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
    //         glfwSetWindowShouldClose(window, GL_TRUE);
    //     if (key == GLFW_KEY_A && action == GLFW_RELEASE)
    //         std::cout << "test A" << std::endl;
    //     const GLubyte *name = glGetString(GL_VENDOR);           // 返回负责当前OpenGL实现厂商的名字
    //     const GLubyte *biaoshifu = glGetString(GL_RENDERER);    // 返回一个渲染器标识符，通常是个硬件平台
    //     const GLubyte *OpenGLVersion = glGetString(GL_VERSION); // 返回当前OpenGL实现的版本号
    //     printf("OpenGL实现厂商的名字：%s\n", name);
    //     printf("渲染器标识符：%s\n", biaoshifu);
    //     printf("OpenGL实现的版本号：%s\n", OpenGLVersion);

    //     // if (key == GLFW_KEY_UP && action == GLFW_PRESS)
    //     // {
    //     //     float value = 0.0f;
    //     //     int a_base = glGetUniformLocation(ourShader.ID, "a");
    //     //     glGetUniformfv(ourShader.ID, a_base, &value);
    //     //     printf("value：%f\n", value);
    //     //     if (value < 1.0f)
    //     //         value += 0.1f;
    //     //     if (value > 1.0f)
    //     //         value = 1.0f;
    //     //     glUniform1f(a_base, value);

    //     //     trans = glm::translate(trans, glm::vec3(0.0f, 0.05f, 0.0f));
    //     //     // trans = glm::scale(trans, glm::vec3(10, 10, 0.5));
    //     // }
    //     // else if (key == GLFW_KEY_DOWN && action == GLFW_PRESS)
    //     // {
    //     //     float value = 0.0f;
    //     //     int a_base = glGetUniformLocation(ourShader.ID, "a");
    //     //     glGetUniformfv(ourShader.ID, a_base, &value);
    //     //     printf("value：%f\n", value);
    //     //     if (value > 0.0f)
    //     //         value -= 0.1f;
    //     //     if (value < 0.0f)
    //     //         value = 0.0f;
    //     //     glUniform1f(a_base, value);

    //     //     trans = glm::translate(trans, glm::vec3(0.0f, -0.05f, 0.0f));
    //     // }
    //     /*else */if (key == GLFW_KEY_LEFT && action == GLFW_PRESS)
    //     {
    //         trans = glm::translate(trans, glm::vec3(-0.05f, 0.0f, 0.0f));
    //     }
    //     else if (key == GLFW_KEY_RIGHT && action == GLFW_PRESS)
    //     {
    //         trans = glm::translate(trans, glm::vec3(0.05f, 0.0f, 0.0f));
    //     }
    //     else if (key == GLFW_KEY_Z && action == GLFW_PRESS)
    //     {
    //         trans = glm::rotate(trans, 0.1f, glm::vec3(0.0, 1.0, 0.0));
    //     }
    //     else if (key == GLFW_KEY_C && action == GLFW_PRESS)
    //     {
    //         trans = glm::rotate(trans, -0.1f, glm::vec3(0.0, 1.0, 0.0));
    //     }
    //     // else if (key == GLFW_KEY_A && action == GLFW_PRESS)
    //     // {
    //     //     trans = glm::rotate(trans, 0.1f, glm::vec3(1.0, 0.0, 0.0));
    //     // }
    //     // else if (key == GLFW_KEY_D && action == GLFW_PRESS)
    //     // {
    //     //     trans = glm::rotate(trans, -0.1f, glm::vec3(1.0, 0.0, 0.0));
    //     // }
    //     else if (key == GLFW_KEY_Q && action == GLFW_PRESS)
    //     {
    //         trans = glm::rotate(trans, 0.1f, glm::vec3(0.0, 0.0, 1.0));
    //     }
    //     else if (key == GLFW_KEY_E && action == GLFW_PRESS)
    //     {
    //         trans = glm::rotate(trans, -0.1f, glm::vec3(0.0, 0.0, 1.0));
    //     }
}

void WindowHelper::mouse_callback(GLFWwindow *window, double xpos, double ypos)
{
    float deltaX = xpos - lastX;
    float deltaY = ypos - lastY;
    lastX = xpos;
    lastY = ypos;
    if (mouse_button_right)
        camera->ProcessMouseMovement(-deltaX, deltaY);
}

void WindowHelper::scroll_callback(GLFWwindow *window, double xoffset, double yoffset)
{
    // if (fov >= 1.0f && fov <= 45.0f)
    //     fov -= yoffset;
    // if (fov <= 1.0f)
    //     fov = 1.0f;
    // if (fov >= 45.0f)
    //     fov = 45.0f;
}

float WindowHelper::updateDeltaTime()
{
    float currentFrame = glfwGetTime();
    deltaTime = currentFrame - lastFrame;
    lastFrame = currentFrame;
    return 0.0f;
}
