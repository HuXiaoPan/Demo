#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <string>
#include <map>
class GLFWwindow;
class shape_base;

class WindowHelper
{
public:
    static WindowHelper *curr_winHelper;
    std::map<std::string, shape_base*> shp_map;


private:
    // settings
    unsigned int width;
    unsigned int height;
    char *title;
    GLFWwindow *window;
    float deltaTime = 0.0f; // 当前帧与上一帧的时间差
    float lastFrame = 0.0f; // 上一帧的时间


public:
    WindowHelper(char *title = "unname", unsigned int width = 800, unsigned int height = 600);
    ~WindowHelper();
    GLFWwindow *GetWindow();
    bool InitGlad();
    void Init();
    void draw();

    // process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
    void processInput();
    // glfw: whenever the window size changed (by OS or user resize) this callback function executes
    void framebuffer_size_callback(GLFWwindow *window, int width, int height);
    void key_callback(GLFWwindow *window, int key, int scancode, int action, int mode);
    void mouse_callback(GLFWwindow *window, double xpos, double ypos);
    void scroll_callback(GLFWwindow *window, double xoffset, double yoffset);

    float updateDeltaTime();
};

#endif // !WINDOWHELPER_H