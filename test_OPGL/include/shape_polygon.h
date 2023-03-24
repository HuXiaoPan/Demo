#ifndef SHAPE_POLYGON_H
#define SHAPE_POLYGON_H

#include "shape_base.h"

class shape_polygon : public shape_base
{
public:
    shape_polygon(float *data, int size, unsigned int *elem_data, int elem_size);
    virtual void draw() override;
};


#endif // !SHAPE_POLYGON_H