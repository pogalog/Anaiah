#version 330 core

layout(location = 0) out vec4 FragColor;

in vec3 texcoord;

uniform samplerCube cubemap;

void main()
{
	FragColor = texture( cubemap, texcoord );
}