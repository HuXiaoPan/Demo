// b样条递推公式
double test(double u, int k, int i, double *nodeList)
{
    double value = 0;
    if(!k) if(u - nodeList[i] >= 0 && u - nodeList[i + 1] <= 0) value = 1;
    else if(k > 0)
    {
        if(u  < nodeList[i] || u > nodeList[i + k +1]) return value;
        double coefficient1 = (u - nodeList[i])/(nodeList[i + 1] - nodeList[i]);
        double coefficient2 = (nodeList[i + k + 1] - u)/(nodeList[i + k + 1] - nodeList[i + 1]);
        value = coefficient1 * test(u, k - 1, i, nodeList) + coefficient2 * test(u, k - 1, i + 1, nodeList);
    }
    return value;
}