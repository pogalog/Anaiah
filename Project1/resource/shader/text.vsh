#version 330 core

layout(location = 0) in vec3 position;
layout(location = 2) in vec2 uvCoords;
layout(location = 6) in vec4 color;

out vec2 texcoord;
out vec4 letterColor;

uniform mat4 MVP;

void main()
{
	gl_Position = MVP * vec4( position, 1.0 );

	texcoord = uvCoords;
	letterColor = color;
}