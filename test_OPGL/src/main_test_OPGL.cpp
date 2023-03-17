#include <iostream>
#include "glad.h"
#include <GLFW/glfw3.h>
#include <cmath>
#include "shader.h"
#include "vertexData.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

Shader *ourShader = nullptr;
Shader *ourShader2 = nullptr;
glm::mat4 trans = glm::mat4(1.0f);

glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0f);

float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间

float pitch = 0.0f, yaw = 0.0f;
float fov = 45.0f;

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

float lastX = SCR_WIDTH / 2, lastY = SCR_HEIGHT / 2;

bool firstMouse = true;

void Init();
GLFWwindow *InitWindow();
bool InitGlad();
void ComplierShadow();
void DrawShapes(unsigned int VBO[], unsigned int VAO[], unsigned int EBO[]);

void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

void key_callback(GLFWwindow *window, int key, int scancode, int action, int mode);
void mouse_callback(GLFWwindow *window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);

int main_test_OPGL(int argc, char const *argv[])
{

    Init();
    GLFWwindow *window = InitWindow();
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    if (!InitGlad())
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        glfwTerminate();
        return -1;
    }
    ComplierShadow();
    unsigned int VBO[2], VAO[2], EBO[2];
    DrawShapes(VBO, VAO, EBO);
    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    // glBindVertexArray(0);
    glUseProgram(ourShader->ID);
    glBindVertexArray(VAO[0]);
    unsigned int texture[2];
    glGenTextures(2, texture);
    stbi_set_flip_vertically_on_load(true); // tell stb_image.h to flip loaded texture's on the y-axis.
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    int width, height, nrChannels;
    unsigned char *data = stbi_load("res/container.jpg", &width, &height, &nrChannels, 0);
    if (data)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        std::cout << "Failed to load texture" << std::endl;
    }
    stbi_image_free(data);

    glBindTexture(GL_TEXTURE_2D, texture[1]);
    // float f[] = {1.0f, 0.0f, 0.0f, 0.0f};
    // glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, f);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    data = stbi_load("res/awesomeface.png", &width, &height, &nrChannels, 0);
    if (data)
    {
        // note that the awesomeface.png has transparency and thus an alpha channel, so make sure to tell OpenGL the data type is of GL_RGBA
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        std::cout << "Failed to load texture" << std::endl;
    }
    stbi_image_free(data);

    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    // -------------------------------------------------------------------------------------------
    glUseProgram(ourShader->ID);
    // either set it manually like so:
    glUniform1i(glGetUniformLocation(ourShader->ID, "texture1"), 0);
    // or set it via the texture class
    // ourShader.setInt("texture2", 1);
    glUniform1i(glGetUniformLocation(ourShader->ID, "texture2"), 1);
    // uncomment this call to draw in wireframe polygons.
    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // render loop
    // -----------glm::rotate(model, (float)glfwGetTime() * glm::radians(50.0f), glm::vec3(0.5f, 1.0f, 0.0f));
    glEnable(GL_DEPTH_TEST);

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
    float a1 = 0.0f;
    while (!glfwWindowShouldClose(window))
    {

        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        glUseProgram(ourShader->ID);
        glBindVertexArray(VAO[0]);

        glm::mat4 view = glm::mat4(1.0f);
        view = glm::lookAt(cameraPos,
                           cameraPos + cameraFront,
                           cameraUp);
        glm::mat4 projection = glm::mat4(1.0f);
        // model = glm::rotate(model, sin((float)glfwGetTime()) * glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
        // view = glm::translate(view, glm::vec3(-5.0f, -5.0f, -10.0f));
        projection = glm::perspective(glm::radians(fov), 1.0f * SCR_WIDTH / SCR_HEIGHT, 0.1f, 100.0f);

        // input
        // -----
        processInput(window);

        // render
        // ------
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        float timeValue = glfwGetTime();
        float baseValue = (sin(timeValue) / 2.0f) + 0.5f;
        int vertexColorLocation = glGetUniformLocation(ourShader->ID, "global_color");
        glUniform4f(vertexColorLocation, 1.0f - baseValue, baseValue, abs(baseValue * 2 - 1.0f), 1.0f);
        unsigned int transformLoc = glGetUniformLocation(ourShader->ID, "transform");
        glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
        // unsigned int modelLoc = glGetUniformLocation(ourShader->ID, "model");
        // glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
        unsigned int viewLoc = glGetUniformLocation(ourShader->ID, "view");
        glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
        unsigned int projectionLoc = glGetUniformLocation(ourShader->ID, "projection");
        glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));

        // bind textures on corresponding texture units
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture[1]);
        // render the triangle
        // glBindVertexArray(VAO[0]);
        // glDrawArrays(GL_TRIANGLES, 0, 36);

        for (unsigned int i = 0; i < 10; i++)
        {
            glm::mat4 model = glm::mat4(1.0f);
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * i;
            model = glm::rotate(model, sin((float)glfwGetTime()) * glm::radians(angle + 35), glm::vec3(1.0f, 0.3f, 0.5f));
            unsigned int modelLoc = glGetUniformLocation(ourShader->ID, "model");
            glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }

        // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
        // -------------------------------------------------------------------------------------------
        glUseProgram(ourShader2->ID);
        // glEnable(GL_DEPTH_TEST);
        glm::mat4 c_model = glm::mat4(1.0f);
        // c_model = glm::rotate(c_model, glm::radians(-55.0f), glm::vec3(0.5f, 1.0f, 0.0f));
        unsigned int c_modelLoc = glGetUniformLocation(ourShader2->ID, "c_model");
        glUniformMatrix4fv(c_modelLoc, 1, GL_FALSE, glm::value_ptr(c_model));
        unsigned int c_viewLoc = glGetUniformLocation(ourShader2->ID, "c_view");
        glUniformMatrix4fv(c_viewLoc, 1, GL_FALSE, glm::value_ptr(view));
        unsigned int c_projectionLoc = glGetUniformLocation(ourShader2->ID, "c_projection");
        glUniformMatrix4fv(c_projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));
        glBindVertexArray(VAO[1]);
        glDrawArrays(GL_LINES, 0, 6);
        // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
        // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // optional: de-allocate all resources once they've outlived their purpose:
    // ------------------------------------------------------------------------
    glDeleteVertexArrays(1, VAO);
    glDeleteBuffers(1, VBO);
    glDeleteBuffers(1, EBO);
    glDeleteProgram(ourShader->ID);

    // glfw: terminate, clearing all previously allocated GLFW resources.
    // ------------------------------------------------------------------
    glfwTerminate();
    return 0;
}

void Init()
{
    // glfw: initialize and configure
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
}

GLFWwindow *InitWindow()
{
    // glfw window creation
    // --------------------
    GLFWwindow *window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "MapView", NULL, NULL);
    if (window == NULL)
        return nullptr;
    glfwMakeContextCurrent(window);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    glfwSetKeyCallback(window, key_callback);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    return window;
}

bool InitGlad()
{
    // glad: load all OpenGL function pointers
    // ---------------------------------------
    return gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
}

void ComplierShadow()
{
    // build and compile our shader program
    // ------------------------------------
    ourShader = new Shader("res/vs.glsl", "res/fs.glsl"); // you can name your shader files however you like
    ourShader2 = new Shader("res/cood_vs.glsl", "res/cood_fs.glsl");
}

void DrawShapes(unsigned int VBO[], unsigned int VAO[], unsigned int EBO[])
{
    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------

    glGenVertexArrays(2, VAO);
    glGenBuffers(2, VBO);
    glGenBuffers(2, EBO);
    glUseProgram(ourShader->ID);
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO[0]);
    glBindBuffer(GL_ARRAY_BUFFER, VBO[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0]);
    // glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);

    // // color attribute
    // glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(3 * sizeof(float)));
    // glEnableVertexAttribArray(1);

    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);

    glUseProgram(ourShader2->ID);
    glBindVertexArray(VAO[1]);
    glBindBuffer(GL_ARRAY_BUFFER, VBO[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(coordinateLine), coordinateLine, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    float cameraSpeed = 2.5f * deltaTime;
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        cameraPos += cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        cameraPos -= cameraSpeed * cameraFront;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
void framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}

void key_callback(GLFWwindow *window, int key, int scancode, int action, int mode)
{
    // 当用户按下ESC键,我们设置window窗口的WindowShouldClose属性为true
    // 关闭应用程序
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
    if (key == GLFW_KEY_A && action == GLFW_RELEASE)
        std::cout << "test A" << std::endl;
    const GLubyte *name = glGetString(GL_VENDOR);           // 返回负责当前OpenGL实现厂商的名字
    const GLubyte *biaoshifu = glGetString(GL_RENDERER);    // 返回一个渲染器标识符，通常是个硬件平台
    const GLubyte *OpenGLVersion = glGetString(GL_VERSION); // 返回当前OpenGL实现的版本号
    printf("OpenGL实现厂商的名字：%s\n", name);
    printf("渲染器标识符：%s\n", biaoshifu);
    printf("OpenGL实现的版本号：%s\n", OpenGLVersion);

    if (key == GLFW_KEY_UP && action == GLFW_PRESS)
    {
        float value = 0.0f;
        int a_base = glGetUniformLocation(ourShader->ID, "a");
        glGetUniformfv(ourShader->ID, a_base, &value);
        printf("value：%f\n", value);
        if (value < 1.0f)
            value += 0.1f;
        if (value > 1.0f)
            value = 1.0f;
        glUniform1f(a_base, value);

        trans = glm::translate(trans, glm::vec3(0.0f, 0.05f, 0.0f));
        // trans = glm::scale(trans, glm::vec3(10, 10, 0.5));
    }
    else if (key == GLFW_KEY_DOWN && action == GLFW_PRESS)
    {
        float value = 0.0f;
        int a_base = glGetUniformLocation(ourShader->ID, "a");
        glGetUniformfv(ourShader->ID, a_base, &value);
        printf("value：%f\n", value);
        if (value > 0.0f)
            value -= 0.1f;
        if (value < 0.0f)
            value = 0.0f;
        glUniform1f(a_base, value);

        trans = glm::translate(trans, glm::vec3(0.0f, -0.05f, 0.0f));
    }
    else if (key == GLFW_KEY_LEFT && action == GLFW_PRESS)
    {
        trans = glm::translate(trans, glm::vec3(-0.05f, 0.0f, 0.0f));
    }
    else if (key == GLFW_KEY_RIGHT && action == GLFW_PRESS)
    {
        trans = glm::translate(trans, glm::vec3(0.05f, 0.0f, 0.0f));
    }
    else if (key == GLFW_KEY_Z && action == GLFW_PRESS)
    {
        trans = glm::rotate(trans, 0.1f, glm::vec3(0.0, 1.0, 0.0));
    }
    else if (key == GLFW_KEY_C && action == GLFW_PRESS)
    {
        trans = glm::rotate(trans, -0.1f, glm::vec3(0.0, 1.0, 0.0));
    }
    // else if (key == GLFW_KEY_A && action == GLFW_PRESS)
    // {
    //     trans = glm::rotate(trans, 0.1f, glm::vec3(1.0, 0.0, 0.0));
    // }
    // else if (key == GLFW_KEY_D && action == GLFW_PRESS)
    // {
    //     trans = glm::rotate(trans, -0.1f, glm::vec3(1.0, 0.0, 0.0));
    // }
    else if (key == GLFW_KEY_Q && action == GLFW_PRESS)
    {
        trans = glm::rotate(trans, 0.1f, glm::vec3(0.0, 0.0, 1.0));
    }
    else if (key == GLFW_KEY_E && action == GLFW_PRESS)
    {
        trans = glm::rotate(trans, -0.1f, glm::vec3(0.0, 0.0, 1.0));
    }
}

void mouse_callback(GLFWwindow *window, double xpos, double ypos)
{

    if (firstMouse) // 这个bool变量初始时是设定为true的
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // 注意这里是相反的，因为y坐标是从底部往顶部依次增大的
    lastX = xpos;
    lastY = ypos;

    float sensitivity = 0.05f;
    xoffset *= sensitivity;
    yoffset *= sensitivity;

    yaw += xoffset;
    pitch += yoffset;

    if (pitch > 89.0f)
        pitch = 89.0f;
    if (pitch < -89.0f)
        pitch = -89.0f;

    glm::vec3 front;
    front.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw));
    front.y = sin(glm::radians(pitch));
    front.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
    cameraFront = glm::normalize(front);
}

void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
  if(fov >= 1.0f && fov <= 45.0f)
    fov -= yoffset;
  if(fov <= 1.0f)
    fov = 1.0f;
  if(fov >= 45.0f)
    fov = 45.0f;
}