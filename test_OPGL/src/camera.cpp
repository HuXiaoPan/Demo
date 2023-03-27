#include "camera.h"

Camera::Camera(glm::vec3 position, glm::vec3 up, float yaw, float pitch) : Front(glm::vec3(0.0f, 0.0f, -1.0f)), MovementSpeed(SPEED), MouseSensitivity(SENSITIVITY)//, Zoom(ZOOM)
{
    Position = position;
    WorldUp = up;
    Yaw = yaw;
    Pitch = pitch;
    updateCameraVectors();
}

Camera::Camera(float posX, float posY, float posZ, float upX, float upY, float upZ, float yaw, float pitch) : Front(glm::vec3(0.0f, 0.0f, -1.0f)), MovementSpeed(SPEED), MouseSensitivity(SENSITIVITY)//, Zoom(ZOOM)
{
    Position = glm::vec3(posX, posY, posZ);
    WorldUp = glm::vec3(upX, upY, upZ);
    Yaw = yaw;
    Pitch = pitch;
    updateCameraVectors();
}
glm::mat4 Camera::GetViewMatrix()
{
    // std::cout << " fx: " << Front.x << " fy: " << Front.y << " fz: " << Front.z << std::endl;
    // std::cout << " ux: " << Up.x << " ux: " << Up.y << " ux: " << Up.z << std::endl;
    // std::cout << " rx: " << Right.x << " ry: " << Right.y << " rz: " << Right.z << std::endl;

    return glm::lookAt(Position, Position + Front, Up);
}
void Camera::ProcessKeyboard(Camera_Movement direction, float deltaTime)
{
    float velocity = MovementSpeed * deltaTime;
    if (direction == FORWARD)
        Position -= glm::normalize(glm::cross(Right, WorldUp)) * velocity;
    if (direction == BACKWARD)
        Position += glm::normalize(glm::cross(Right, WorldUp)) * velocity;
    if (direction == LEFT)
        Position -= Right * velocity;
    if (direction == RIGHT)
        Position += Right * velocity;
    if (direction == UP)
        Position += WorldUp * velocity;
    if (direction == DOWN)
        Position -= WorldUp * velocity;
}
void Camera::ProcessMouseMovement(float xoffset, float yoffset, GLboolean constrainPitch)
{
    xoffset *= MouseSensitivity;
    yoffset *= MouseSensitivity;

    Yaw += xoffset;
    Pitch += yoffset;

    // make sure that when pitch is out of bounds, screen doesn't get flipped
    if (constrainPitch)
    {
        if (Pitch > 89.0f)
            Pitch = 89.0f;
        if (Pitch < -89.0f)
            Pitch = -89.0f;
    }
    // update Front, Right and Up Vectors using the updated Euler angles
    updateCameraVectors();
}
#include <iostream>
void Camera::ProcessMouseScroll(float yoffset)
{
    // Zoom -= (float)yoffset;
    // if (Zoom < 1.0f)
    //     Zoom = 1.0f;
    // if (Zoom > 45.0f)
    //     Zoom = 45.0f;
    Position = Position * ( 1.0f - yoffset * 0.1f);
}

void Camera::ProcessViewMove(float xoffset, float yoffset)
{

    xoffset *= MouseSensitivity;
    yoffset *= MouseSensitivity;

    glm::mat4 rotate = glm::rotate(glm::mat4(1.0f), glm::radians(xoffset), WorldUp);
    Position = glm::vec3(rotate[0][0] * Position.x + rotate[0][1] * Position.y + +rotate[0][2] * Position.z,
                            rotate[1][0] * Position.x + rotate[1][1] * Position.y + +rotate[1][2] * Position.z,
                            rotate[2][0] * Position.x + rotate[2][1] * Position.y + +rotate[2][2] * Position.z);
    Yaw += xoffset;
    rotate = glm::rotate(glm::mat4(1.0f), glm::radians(yoffset), Right);
    Position = glm::vec3(rotate[0][0] * Position.x + rotate[0][1] * Position.y + +rotate[0][2] * Position.z,
                  rotate[1][0] * Position.x + rotate[1][1] * Position.y + +rotate[1][2] * Position.z,
                  rotate[2][0] * Position.x + rotate[2][1] * Position.y + +rotate[2][2] * Position.z);
    Pitch -= yoffset;
    if (Pitch > 89.0f)
        Pitch = 89.0f;
    if (Pitch < -89.0f)
        Pitch = -89.0f;
    updateCameraVectors();
}

void Camera::updateCameraVectors()
{
    // calculate the new Front vector
    glm::vec3 front;
    front.x = cos(glm::radians(Yaw)) * cos(glm::radians(Pitch));
    front.y = sin(glm::radians(Pitch));
    front.z = sin(glm::radians(Yaw)) * cos(glm::radians(Pitch));
    Front = glm::normalize(front);
    // also re-calculate the Right and Up vector
    Right = glm::normalize(glm::cross(Front, WorldUp)); // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    Up = glm::normalize(glm::cross(Right, Front));
}