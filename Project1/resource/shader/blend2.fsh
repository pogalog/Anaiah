#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D map0, map1;

void main()
{
	vec4 c0 = texture2D( map0, texcoord );
	vec4 c1 = texture2D( map1, texcoord );
	FragColor = (c0 + 0.5*c1);
}