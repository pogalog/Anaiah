#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
uniform mat3 normalMatrix;
uniform mat4 PVM;

out vec3 norm;

void main()
{
	gl_Position = PVM * vec4( position, 1.0 );
	norm = normalMatrix * normal;
}