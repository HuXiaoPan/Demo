#include <iostream>
#include <cmath>
#include "glad.h"
#include <GLFW/glfw3.h>
#include "WindowHelper.h"
#include "vertexData.h"
#include "Helper.h"
#include "shape_line.h"
#include "shape_point.h"
#include "shape_polygon.h"
#include <string>
#include <vector>

#include "Bessel.h"
#include "B-Spline.h"

int main_test_OPGL(int argc, char const *argv[])
{
    WindowHelper WindowHelper;
    GLFWwindow *window = WindowHelper.GetWindow();
    if (window == nullptr)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    if (!WindowHelper.InitGlad())
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        glfwTerminate();
        return -1;
    }
    WindowHelper.Init();

    // uncomment this call to draw in wireframe polygons.
    // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    // render loop
    glEnable(GL_DEPTH_TEST);

    shape_line coord_l(coordinateLine, sizeof(coordinateLine));
    float p[4207] = {0.0f};
    p[0] = 0.0f;
    p[1] = 0.0f;
    p[2] = 0.0f;
    p[3] = 1.0f;
    p[4] = 1.0f;
    p[5] = 1.0f;
    p[6] = 1.0f;
    for (int i = 0; i < 100; ++i)
    {
        p[(100 + i + 1) * 7] = i + 1;
        p[(100 + i + 1) * 7 + 3] = 1.0f;
        p[(100 + i + 1) * 7 + 6] = 1.0f;
        p[(100 - i) * 7] = -(i + 1);
        p[(100 - i) * 7 + 3] = 1.0f;
        p[(100 - i) * 7 + 6] = 1.0f;

        p[(300 + i + 1) * 7 + 1] = i + 1;
        p[(300 + i + 1) * 7 + 4] = 1.0f;
        p[(300 + i + 1) * 7 + 6] = 1.0f;
        p[(300 - i) * 7 + 1] = -(i + 1);
        p[(300 - i) * 7 + 4] = 1.0f;
        p[(300 - i) * 7 + 6] = 1.0f;

        p[(500 + i + 1) * 7 + 2] = i + 1;
        p[(500 + i + 1) * 7 + 5] = 1.0f;
        p[(500 + i + 1) * 7 + 6] = 1.0f;
        p[(500 - i) * 7 + 2] = -(i + 1);
        p[(500 - i) * 7 + 5] = 1.0f;
        p[(500 - i) * 7 + 6] = 1.0f;
    }
    shape_point coord_p(p, sizeof(p));
    shape_polygon plat(coordinatePlat, sizeof(coordinatePlat), elem_Plat, sizeof(elem_Plat));

    int point_count = 6;
    int k = 5;
    int samPointCount = 1000;
    glm::vec3 input[point_count];
    float nodeList[point_count + 1 + k] = {0.0f};
    std::vector<glm::vec3> pt_list;
    std::vector<glm::vec3> line_list;
    std::vector<glm::vec3> result_list;
    Helper::CreateTestPointDatas(pt_list, point_count);
    Helper::CreateTestLineDatas(pt_list, line_list);
    float test_point[pt_list.size() * 7] = {0.0f};
    float test_line[line_list.size() * 7] = {0.0f};
    Helper::ConvertData(pt_list, test_point, glm::vec4(1.0f,1.0f,0.0f,1.0f));
    Helper::ConvertData(line_list, test_line, glm::vec4(0.0f,1.0f,1.0f,1.0f));
    shape_point test_p(test_point, sizeof(test_point));
    shape_line test_l(test_line, sizeof(test_line));

    CreateKnodList(nodeList, point_count, k);

    for (size_t i = 0; i < point_count; i++)
    {
        input[i] = glm::vec3(test_point[i * 7 + 0], test_point[i * 7 + 1], test_point[i * 7 + 2]);
    }
    for (int i = 0; i < 1000; ++i)
    {
        // glm::vec3 rlt = GetBesselPoint(input, k, i * (1.0f / samPointCount));
        result_list.push_back(GetBSplinePoint(input, point_count, i * (1.0f / 1000), k, nodeList));
    }
    float output[7 * result_list.size()] = {0.0f};
    Helper::ConvertData(result_list, output, glm::vec4(0.3f,0.2f,0.9f,0.5f));
    shape_point test_r(output, sizeof(output));

    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    // ourShader.setInt("texture1", 0);
    // ourShader.setInt("texture2", 1);
    WindowHelper.shp_map["coord_l"] = &coord_l;
    WindowHelper.shp_map["coord_p"] = &coord_p;
    WindowHelper.shp_map["plat"] = &plat;
    WindowHelper.shp_map["test_p"] = &test_p;
    WindowHelper.shp_map["test_l"] = &test_l;
    WindowHelper.shp_map["test_r"] = &test_r;
    WindowHelper.draw();
    // while (!glfwWindowShouldClose(window))
    // {
    //     // ourShader.use();
    //     glBindVertexArray(painter.VAO[0]);

    //     // float timeValue = glfwGetTime();
    //     // float baseValue = (sin(timeValue) / 2.0f) + 0.5f;
    //     // int vertexColorLocation = glGetUniformLocation(ourShader.ID, "global_color");
    //     // glUniform4f(vertexColorLocation, 1.0f - baseValue, baseValue, abs(baseValue * 2 - 1.0f), 1.0f);
    //     // unsigned int transformLoc = glGetUniformLocation(ourShader.ID, "transform");
    //     // glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
    //     // // unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
    //     // // glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
    //     // unsigned int viewLoc = glGetUniformLocation(ourShader.ID, "view");
    //     // glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
    //     // unsigned int projectionLoc = glGetUniformLocation(ourShader.ID, "projection");
    //     // glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));

    //     // bind textures on corresponding texture units
    //     glActiveTexture(GL_TEXTURE0);
    //     glBindTexture(GL_TEXTURE_2D, painter.texture[0]);
    //     glActiveTexture(GL_TEXTURE1);
    //     glBindTexture(GL_TEXTURE_2D, painter.texture[1]);
    //     // render the triangle
    //     // glBindVertexArray(VAO[0]);
    //     // glDrawArrays(GL_TRIANGLES, 0, 36);

    //     // for (unsigned int i = 0; i < 10; i++)
    //     // {
    //     //     glm::mat4 model = glm::mat4(1.0f);
    //     //     model = glm::translate(model, cubePositions[i]);
    //     //     float angle = 20.0f * i;
    //     //     model = glm::rotate(model, (float)sin((float)glfwGetTime()) * glm::radians(angle + 35), glm::vec3(1.0f, 0.3f, 0.5f));
    //     //     unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
    //     //     glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));

    //     //     glDrawArrays(GL_TRIANGLES, 0, 36);
    //     // }

    // }
    return 0;
}
