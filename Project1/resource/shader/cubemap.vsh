#version 330 core

layout(location = 0) in vec3 position;

out vec3 texcoord;

uniform mat4 MVP;

void main()
{
	gl_Position = MVP * vec4( position, 1.0 );
	texcoord = position;
}