#ifndef MOVINGAVERAGE_H
#define MOVINGAVERAGE_H

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"
#include <vector>

void MASmooth(std::vector<glm::vec3> &data)
{
    double sum = 0;
    int N = 5
    for (size_t i = 0; i < data.size(); i++)
    {
        if(i < N / 2)
        {

        }
        else if (i < data.size() - N / 2)
        {
            
        }
        else
        {
            
        }
    }
    
}

#endif // !MOVINGAVERAGE_H