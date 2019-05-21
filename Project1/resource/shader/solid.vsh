#version 330 core

layout(location = 0) in vec3 position;

uniform mat4 MVP;
out vec4 colorData;


void main()
{
	vec4 p4 = vec4( position, 1.0 );
	
	
	gl_Position = MVP * p4;
}
