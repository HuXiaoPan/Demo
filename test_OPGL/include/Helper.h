#ifndef HELPER_H
#define HELPER_H

#include "Vertex.h"

class Helper
{
public:
    static void CreateTestPointDatas(float *data, unsigned int size);
    static void CreateTestLineDatas(float *input, unsigned int input_size, float *output);
};


#endif // !HELPER_H