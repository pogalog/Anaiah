#version 330 core

layout(location = 0) in vec3 position;
layout(location = 2) in vec2 uv;

uniform mat4 MVP;
out vec2 fragCoord;

void main()
{
	vec4 p4 = vec4( position, 1.0 );
	fragCoord = uv;
	
	gl_Position = MVP * p4;
}
