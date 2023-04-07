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

/**
*@function: - 5点2次线性平滑
*@data:输入数据，输出数据
*@size；data数据的个数
*返回滤波后的值 */
int8_t  LinearSmooth5p2(float* data, uint16_t size)
{
  float output[5]; //5点缓存
  uint16_t j=0;
  int8_t  Para[5][5]={ //每一行的数字之和为35
    {31, 9,-3,-5, 3},  
    { 9,13,12, 6,-5},
    {-3,12,17,12,-3},
    {-5, 6,12,13, 9},
    { 3,-5,-3, 9,31},        
  };
  
  if(size<5) return -1; //数据太少。不处理。
  else 
  {
    output[0]=(Para[0][0]*data[0]+ Para[0][1]*data[1]+Para[0][2]*data[2]+Para[0][3]*data[3]+ Para[0][4]*data[4])/35;
    output[1]=(Para[1][0]*data[0]+ Para[1][1]*data[1]+Para[1][2]*data[2]+Para[1][3]*data[3]+ Para[1][4]*data[4])/35;

    output[3]=(Para[3][0]*data[size-5]+ Para[3][1]*data[size-4]+Para[3][2]*data[size-3]+Para[3][3]*data[size-2]+ Para[3][4]*data[size-1])/35;
    output[4]=(Para[4][0]*data[size-5]+ Para[4][1]*data[size-4]+Para[4][2]*data[size-3]+Para[4][3]*data[size-2]+ Para[4][4]*data[size-1])/35;
    
    for(j=2;j<=size-3;j++)
      {
        output[2]=(Para[2][0]*data[j-2]+ Para[2][1]*data[j-1]+Para[2][2]*data[j]+Para[2][3]*data[j+1]+ Para[2][4]*data[j+2])/35;
        data[j]=output[2];
      }
      data[0]=output[0];
      data[1]=output[1];
      data[size-2]=output[3];
      data[size-1]=output[4];
      return 1; //成功转换。
  }
}   

#endif // !MOVINGAVERAGE_H