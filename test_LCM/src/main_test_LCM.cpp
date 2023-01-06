#include <iostream>
#include <lcm/lcm-cpp.hpp>
#include "example_t.hpp"

void main_test_LCM()
{
    lcm::LCM lcm;
    if(!lcm.good()) 
    {
        std::cout << "lcm start faild!" << std::endl;
        return;
    }

    exlcm::example_t my_data;
    my_data.timestamp = 0;
    my_data.position[0] = 1;
    my_data.position[1] = 2;
    my_data.position[2] = 3;
    my_data.orientation[0] = 1;
    my_data.orientation[1] = 0;
    my_data.orientation[2] = 0;
    my_data.orientation[3] = 0;
    my_data.num_ranges = 15;
    my_data.ranges.resize(my_data.num_ranges);
    for(int i = 0; i < my_data.num_ranges; i++)
        my_data.ranges[i] = i;
    my_data.name = "example string";
    my_data.enabled = true;
    lcm.publish("EXAMPLE", &my_data);


}