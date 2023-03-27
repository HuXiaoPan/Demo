#ifndef VERTEX_H
#define VERTEX_H

struct Vertex
{
    Vertex(float x = 0.0f, float y = 0.0f, float z = 0.0f) : x(x), y(y), z(z)
    {
    }
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
};

inline Vertex operator+(const Vertex &value1, const Vertex &value2)
{
    return Vertex(value1.x + value2.x, value1.y + value2.y, value1.z + value2.z);
}
inline Vertex operator-(const Vertex &value1, const Vertex &value2)
{
    return Vertex(value1.x - value2.x, value1.y - value2.y, value1.z - value2.z);
}
inline Vertex operator*(const Vertex &value, float t)
{
    return Vertex(t * value.x, t * value.y, t * value.z);
}
inline Vertex operator*(float t, const Vertex &value)
{
    return Vertex(t * value.x, t * value.y, t * value.z);
}

#endif // !VERTEX_H