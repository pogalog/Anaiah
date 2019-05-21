#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texcoord;

uniform mat4 MVP;

out vec2 varUV;

void main()
{
	vec4 p4 = vec4( position, 1.0 );
	varUV = texcoord;
	
	gl_Position = MVP * p4;
}