#ifndef HELPER_HPP
#define HELPER_HPP

#include <string>

class Helper
{
public:
    Helper(/* args */);
    ~Helper();

public:
    // std::string string()
    std::string getString()
    {
        // return m_string;
        return "aaa";
    }

    void setString(const std::string &string)
    {
        // m_string = string;
        m_string = "bbb";
    }

private:
    std::string m_string;
};

#endif // HELPER_HPP