#include "Helper.h"
#include <cstdlib>
#include <ctime>

void Helper::CreateTestPointDatas(float *data, unsigned int size)
{
    srand(time(0));

    for (int i = 0; i < size; ++i)
    {
        data[i * 7] = (rand() % 10001) / 100.0f;
        data[i * 7 + 1] = (rand() % 10001) / 100.0f;
        data[i * 7 + 2] = (rand() % 10001) / 100.0f;
        data[i * 7 + 3] = 1.0f;
        data[i * 7 + 4] = 1.0f;
        data[i * 7 + 5] = 0.0f;
        data[i * 7 + 6] = 1.0f;
    }
}

void Helper::CreateTestLineDatas(float *input, unsigned int input_size, float *output)
{
    for (int i = 0; i < input_size; ++i)
    {
        if (i < input_size - 1)
        {
            output[i * 14] = input[i * 7];
            output[i * 14 + 1] = input[i * 7 + 1];
            output[i * 14 + 2] = input[i * 7 + 2];
            output[i * 14 + 3] = 0.0f;
            output[i * 14 + 4] = 1.0f;
            output[i * 14 + 5] = 1.0f;
            output[i * 14 + 6] = 1.0f;
        }
        if (i > 0)
        {
            output[i * 14 - 7] = input[i * 7];
            output[i * 14 - 6] = input[i * 7 + 1];
            output[i * 14 - 5] = input[i * 7 + 2];
            output[i * 14 - 4] = 0.0f;
            output[i * 14 - 3] = 1.0f;
            output[i * 14 - 2] = 1.0f;
            output[i * 14 - 1] = 1.0f;
        }
    }
}
