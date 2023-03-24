#ifndef SHAPE_POINT_H
#define SHAPE_POINT_H
#include "shape_base.h"

class shape_point: public shape_base
{
private:
    /* data */
public:
    shape_point(float *data, int size);
    virtual void draw() override;
};


#endif // !SHAPE_POINT_H