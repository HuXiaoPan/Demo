#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H
class GLFWwindow;
class WindowHelper
{
public:
    static WindowHelper *curr_winHelper;
private:
    // settings
    unsigned int width;
    unsigned int height;
    char *title;
    GLFWwindow *window;

public:
    WindowHelper(char *title = "unname", unsigned int width = 800, unsigned int height = 600);
    ~WindowHelper();
    void Init();
    GLFWwindow *GetWindow();
    bool InitGlad();

    // process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
    void processInput();
    // glfw: whenever the window size changed (by OS or user resize) this callback function executes
    void framebuffer_size_callback(GLFWwindow *window, int width, int height);
    void key_callback(GLFWwindow *window, int key, int scancode, int action, int mode);
    void mouse_callback(GLFWwindow *window, double xpos, double ypos);
    void scroll_callback(GLFWwindow *window, double xoffset, double yoffset);
};

#endif // !WINDOWHELPER_H