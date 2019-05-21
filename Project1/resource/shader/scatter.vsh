#version 330 core

layout(location = 0) in vec3 position;
layout(location = 2) in vec2 texcoord;

out vec4 light;
out vec2 uv;

uniform mat4 MVP, cameraMVP;
uniform vec3 lightPos;

void main()
{
	vec4 p4 = vec4( position, 1.0 );
	
	gl_Position = MVP * p4;
    light = cameraMVP * vec4( lightPos, 1.0 );
    uv = texcoord;
}