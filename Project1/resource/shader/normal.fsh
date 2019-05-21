#version 330 core

layout(location = 0) out vec4 outNorm;

in vec3 norm;

void main()
{
	outNorm = vec4( normalize( norm ), 1.0 );
}