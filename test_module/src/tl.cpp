#include "tl.hpp"
#include <iostream>
void test_tl()
{
    std::cout << "tl is run!";
}

bool fibon_elem(int pos, int &result)
{
    if(pos < 0 || pos >1024)
    {result = 0; return false;}
    int n_1 = 1, n_2 = 1;
    result = 1;
    for(int x = 3; x <= pos; ++x)
    {result = n_1 + n_2;n_1 = n_2; n_2 = result;}
    return true;
}