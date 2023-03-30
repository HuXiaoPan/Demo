#include "Helper.h"
#include <cstdlib>
#include <ctime>

void Helper::CreateTestPointDatas(std::vector<glm::vec3> &data, unsigned int size)
{
    srand(time(0));
    for (int i = 0; i < size; ++i)
    {
        data.push_back(glm::vec3((rand() % 10001) / 100.0f, (rand() % 10001) / 100.0f, (rand() % 10001) / 100.0f));
    }
}

void Helper::CreateTestPointDatas(float *data, unsigned int size)
{
    srand(time(0));

    for (int i = 0; i < size; ++i)
    {
        data[i * 7] = (rand() % 10001) / 100.0f;
        data[i * 7 + 1] = (rand() % 10001) / 100.0f;
        data[i * 7 + 2] = 1.0f; //(rand() % 10001) / 100.0f;
        data[i * 7 + 3] = 1.0f;
        data[i * 7 + 4] = i == 0 ? 0.0f : 1.0f;
        data[i * 7 + 5] = 0.0f;
        data[i * 7 + 6] = 1.0f;
    }

    // for (int i = 0; i < size; ++i)
    // {
    //     data[i * 7] = i == 0 ? (rand() % 101) / 10.0f : data[(i - 1) * 7] + (rand() % 101) / 10.0f;
    //     data[i * 7 + 1] = i == 0 ? (rand() % 101) / 10.0f : data[(i - 1) * 7 + 1] +(rand() % 101) / 10.0f;
    //     data[i * 7 + 2] = 1.0f;//(rand() % 10001) / 100.0f;
    //     data[i * 7 + 3] = 1.0f;
    //     data[i * 7 + 4] = i == 0 ? 0.0f : 1.0f;
    //     data[i * 7 + 5] = 0.0f;
    //     data[i * 7 + 6] = 1.0f;
    // }
}

void Helper::CreateTestLineDatas(const std::vector<glm::vec3> &input, std::vector<glm::vec3> &output)
{
    for (int i = 0; i < input.size(); ++i)
    {
        output.push_back(input[i]);
        if (i < input.size() - 1 && i > 0) output.push_back(input[i]);
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

void Helper::ConvertData(const std::vector<glm::vec3> &data, float *output, glm::vec4 color)
{
    for(int i = 0; i < data.size(); ++i)
    {
        output[i * 7 + 0] = data[i].x;
        output[i * 7 + 1] = data[i].y;
        output[i * 7 + 2] = data[i].z;
        output[i * 7 + 3] = color.r;
        output[i * 7 + 4] = color.g;
        output[i * 7 + 5] = color.b;
        output[i * 7 + 6] = color.a;
    }
}
