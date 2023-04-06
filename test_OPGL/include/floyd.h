#ifndef FLOYD_H
#define FLOYD_H
//----------------------------------------弗洛伊德路径平滑--------------------------------------//
// 其实是很经典的画直线算法，找两个点作为端点画一条线，这条先经过的网格如果都是可同行的，那么我们就认为在路径中这两个点中间的那些点是多余的。

// 其实第二步就可以完成优化，但是计算量比较大。所以先通过第一步来减少一部分计算量~
List<Vector3> Floyd(List<Vector3> path)
{
    if (path == null)
    {
        return path;
    }

    int len = path.Count;
    // 去掉同一条线上的点。
    if (len > 2)
    {
        Vector3 vector = path[len - 1] - path[len - 2];
        Vector3 tempvector;
        for (int i = len - 3; i >= 0; i--)
        {
            tempvector = path[i + 1] - path[i];
            if (Vector3.Cross(vector, tempvector).y == 0f)
            {
                path.RemoveAt(i + 1);
            }
            else
            {
                vector = tempvector;
            }
        }
    }
    // 去掉无用拐点
    len = path.Count;
    for (int i = len - 1; i >= 0; i--)
    {
        for (int j = 0; j <= i - 1; j++)
        {
            if (CheckCrossNoteWalkable(path[i], path[j]))
            {
                for (int k = i - 1; k >= j; k--)
                {
                    path.RemoveAt(k);
                }
                i = j;
                // len = path.Count;
                break;
            }
        }
    }
    return path;
}

float currentY; // 用于检测攀爬与下落高度
// 判断路径上是否有障碍物
bool CheckCrossNoteWalkable(Vector3 p1, Vector3 p2)
{
    currentY = p1.y; // 记录初始高度，用于检测是否可通过
    bool changexz = Mathf.Abs(p2.z - p1.z) > Mathf.Abs(p2.x - p1.x);
    if (changexz)
    {
        float temp = p1.x;
        p1.x = p1.z;
        p1.z = temp;
        temp = p2.x;
        p2.x = p2.z;
        p2.z = temp;
    }
    if (!Checkwalkable(changexz, p1.x, p1.z))
    {
        return false;
    }
    float stepX = p2.x > p1.x ? Tilesize : (p2.x < p1.x ? -Tilesize : 0);
    float stepY = p2.y > p1.y ? Tilesize : (p2.y < p1.y ? -Tilesize : 0);
    float deltay = Tilesize * ((p2.z - p1.z) / Mathf.Abs(p2.x - p1.x));
    float nowX = p1.x + stepX / 2;
    float nowY = p1.z - stepY / 2;
    float CheckY = nowY;

    while (nowX != p2.x)
    {
        if (!Checkwalkable(changexz, nowX, CheckY))
        {
            return false;
        }
        nowY += deltay;
        if (nowY >= CheckY + stepY)
        {
            CheckY += stepY;
            if (!Checkwalkable(changexz, nowX, CheckY))
            {
                return false;
            }
        }
        nowX += stepX;
    }
    return true;
}
private
bool Checkwalkable(bool changeXZ, float x, float z)
{
    int mapx = (MapStartPosition.x < 0F) ? Mathf.FloorToInt(((x + Mathf.Abs(MapStartPosition.x)) / Tilesize)) : Mathf.FloorToInt((x - MapStartPosition.x) / Tilesize);
    int mapz = (MapStartPosition.y < 0F) ? Mathf.FloorToInt(((z + Mathf.Abs(MapStartPosition.y)) / Tilesize)) : Mathf.FloorToInt((z - MapStartPosition.y) / Tilesize);
    if (mapx < 0 || mapz < 0 || mapx >= Map.GetLength(0) || mapz >= Map.GetLength(1))
    {
        return false;
    }

    Node note;
    if (changeXZ)
    {
        note = Map[mapz, mapx];
    }
    else
    {
        note = Map[mapx, mapz];
    }
    bool ret = note.walkable && ((note.yCoord - currentY <= ClimbLimit && note.yCoord >= currentY) || (currentY - note.yCoord <= MaxFalldownHeight && currentY >= note.yCoord));
    if (ret)
    {
        currentY = note.yCoord;
    }
    return ret;
}

#endif // !FLOYD_H