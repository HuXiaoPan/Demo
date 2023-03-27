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

#include "Bessel.h"

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

    int point_count = 11;
    float test_point[point_count * 7] = {0};
    Helper::CreateTestPointDatas(test_point, point_count);
    shape_point test_p(test_point, sizeof(test_point));
    float test_line[(point_count * 2 - 2) * 7] = {0};
    Helper::CreateTestLineDatas(test_point, point_count, test_line);
    shape_line test_l(test_line, sizeof(test_line));

    int k = 2;
    int samPointCount = 50;
    glm::vec3 input[point_count];

    for (size_t i = 0; i < point_count; i++)
    {
        input[i] = glm::vec3(test_point[i * 7 + 0], test_point[i * 7 + 1], test_point[i * 7 + 2]);
    }

    float output[7 * samPointCount];
    if (point_count <= k)
    {
        for (int i = 0; i < samPointCount; ++i)
        {
            glm::vec3 rlt = GetBesselPoint(input, k, i * (1.0f / samPointCount));
            output[i * 7 + 0] = rlt.x;
            output[i * 7 + 1] = rlt.y;
            output[i * 7 + 2] = rlt.z;
            output[i * 7 + 3] = 0.3f;
            output[i * 7 + 4] = 0.2f;
            output[i * 7 + 5] = 0.9f;
            output[i * 7 + 6] = 1.0f;
        }
    }
    else
    {
        // int kcount = (point_count - 2) / (k - 1);
        // int kmodle = (point_count - 2) % (k - 1);
        // for (size_t i = 0; i < kcount; i++)
        // {
        //     float output1[7 * samPointCount];
        //     glm::vec3 input_sub[k + 1];
        //     input_sub[0] = i == 0 ? input[0] : (input[i * (k - 1)] - input[i * (k - 1) - 1]) * 0.5f + input[i * (k - 1) - 1];
        //     for (size_t s = 1; s < k; s++)
        //     {
        //         input_sub[s] = input[i * (k - 1) + s];
        //     }
        //     input_sub[k] = i == kcount - 1 ? input[(i + 1) * (k - 1) + 1] : (input[(i + 1) * (k - 1)  + 1] - input[(i + 1) * (k - 1)]) * 0.5f + input[(i + 1) * (k - 1)];
        //     for (int r = 0; r < samPointCount; ++r)
        //     {
        //         glm::vec3 rlt = GetBesselPoint(input_sub, k + 1, r * (1.0f / samPointCount));
        //         output1[r * 7 + 0] = rlt.x;
        //         output1[r * 7 + 1] = rlt.y;
        //         output1[r * 7 + 2] = rlt.z;
        //         output1[r * 7 + 3] = 0.3f;
        //         output1[r * 7 + 4] = 0.2f;
        //         output1[r * 7 + 5] = 0.9f;
        //         output1[r * 7 + 6] = 1.0f;
        //     }
        //     shape_point *test_rr = new shape_point(output1, sizeof(output1));
        //     WindowHelper.shp_map[std::to_string(i)] = test_rr;
        // }
    }
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
