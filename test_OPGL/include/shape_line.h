#ifndef SHAPE_LINE_H
#define SHAPE_LINE_H

#include "shape_base.h"

class shape_line : public shape_base
{
public:
    shape_line(float *data, int size);
    virtual void draw() override;
};

#endif // !SHAPE_LINE_H