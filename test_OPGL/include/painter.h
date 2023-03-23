#ifndef PAINTER_H
#define PAINTER_H

class painter
{
private:
    /* data */
public:
    painter(/* args */);
    ~painter();

    unsigned int VBO[2], VAO[2], EBO[2];
    unsigned int texture[2];
};

#endif // PAINTER_H