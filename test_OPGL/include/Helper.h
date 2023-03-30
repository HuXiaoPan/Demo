#ifndef HELPER_H
#define HELPER_H

#include <vector>
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

class Helper
{
public:
    static void CreateTestPointDatas(std::vector<glm::vec3> &data, unsigned int size);
    static void CreateTestPointDatas(float *data, unsigned int size);
    static void CreateTestLineDatas(const std::vector<glm::vec3> &input, std::vector<glm::vec3> &output);
    static void CreateTestLineDatas(float *input, unsigned int input_size, float *output);
    static void ConvertData(const std::vector<glm::vec3> &data, float *output, glm::vec4 color);
};

#endif // !HELPER_H