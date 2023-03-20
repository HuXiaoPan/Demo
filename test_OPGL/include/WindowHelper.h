#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H
class WindowHelper
{
public:
    // settings
    const unsigned int SCR_WIDTH = 800;
    const unsigned int SCR_HEIGHT = 600;

    WindowHelper(/* args */);
    ~WindowHelper();

    void Init();
    GLFWwindow *InitWindow();
    bool InitGlad();
};

#endif // !WINDOWHELPER_H