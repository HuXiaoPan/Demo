#include <GL/glut.h>


void init(void)
{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glMatrixMode(GL_PROJECTION);
    glOrtho(-5, 5, -5, 5, 5, 15);
    glMatrixMode(GL_MODELVIEW);
    gluLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0);

    return;
}

void display(void)
{
    glClear(GL_COLOR_BUFFER_BIT);
    glColor4f(1.0, 1.0, 0, 1.0);
    glutWireTeapot(3);
    // glFlush();
    glutSwapBuffers();

    return;
}

int main(int argc, char const *argv[])
{
    void *argv_temp = argv;
    glutInit(&argc, (char **)argv_temp);
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
    glutInitWindowPosition(100, 100);
    glutInitWindowSize(800, 600);
    glutCreateWindow("test view");
    init();
    glutDisplayFunc(display);
    glutMainLoop();
    return 0;
}
