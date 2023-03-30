#ifndef B_SPLINE_H
#define B_SPLINE_H

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

void CreateKnodList(float *KnodList, int point_count, int k, bool isClamped = true)
{

    if (isClamped)
    {
        for (size_t i = 0; i < point_count + 1 + k; i++)
        {
            if (i < k + 1)
                KnodList[i] = 0.0f;
            else if (point_count + 1 + k - i < k + 1)
                KnodList[i] = 1.0f;
            else
                KnodList[i] = (i - k) * 1.0f / (point_count - k);
        }
    }
    else
    {
        for (size_t i = 0; i < point_count + 1 + k; i++)
        {
            KnodList[i] = i * 1.0f / (point_count + k);
        }
    }
}

// float nodeList[15] = {0.0f, 1.0f/13, 2.0f/13, 3.0f/13, 4.0f/13, 5.0f/13, 6.0f/13, 7.0f/13, 8.0f/13, 9.0f/13, 10.0f/13, 11.0f/13, 12.0f/13, 1.0f};

float BSplineBasicMethod(int i, int k, float u, float *nodeList)
{
    float result = 0;
    if (k == 0)
    {
        result = nodeList[i] > u || u >= nodeList[i + 1] ? 0 : 1;
    }
    else if (k >= 0)
    {
        float node1 = nodeList[i];
        float node2 = nodeList[i + k];
        float node3 = nodeList[i + 1];
        float node4 = nodeList[i + k + 1];

        float c_v1 = (u - node1);
        float c_v2 = (node2 - node1);
        float c_v3 = (node4 - u);
        float c_v4 = (node4 - node3);

        float coefficient1 = c_v1 == 0 || c_v2 == 0 ? 0 : c_v1 / c_v2;
        float coefficient2 = c_v3 == 0 || c_v4 == 0 ? 0 : c_v3 / c_v4;
        if (coefficient1 != 0)
            result += coefficient1 * BSplineBasicMethod(i, k - 1, u, nodeList);
        if (coefficient2 != 0)
            result += coefficient2 * BSplineBasicMethod(i + 1, k - 1, u, nodeList);
    }
    return result;
}

glm::vec3 GetBSplinePoint(glm::vec3 *input, unsigned input_size, float t, int k, float *nodeList)
{
    if (input_size <= 1)
        return input[0];
    if (input_size <= 2)
        return (input[1] - input[0]) * t + input[0];
    glm::vec3 result = glm::vec3(0.0f);
    for (size_t i = 0; i < input_size - 1; i++)
    {
        float z = BSplineBasicMethod(i, k, t, nodeList);
        result += input[i] * z;
    }
    return result;
}

#endif // !B_SPLINE_H
