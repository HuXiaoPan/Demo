#ifndef TL_HPP
#define TL_HPP

void test_tl();
bool fibon_elem(int pos, int &result);


class FuncObjType
{
public:
	void operator() ()
	{
		std::cout<<"Hello C++!"<<std::endl;
	}
};

#endif // TL_HPP