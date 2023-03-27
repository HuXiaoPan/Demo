#ifndef BESSEL_H
#define BESSEL_H

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

glm::vec3 GetBesselPoint(glm::vec3 *input, unsigned input_size, float t)
{
    if(input_size <= 1) return input[0];
    if(input_size <= 2) return (input[1] - input[0]) * t + input[0];
    glm::vec3 next_input[input_size - 1];
    for (size_t i = 0; i < input_size - 1; i++)
    {
        next_input[i] = (input[i + 1] - input[i]) * t + input[i];
    }
    return GetBesselPoint(next_input, input_size - 1, t);
    
}

#endif // !BESSEL_H