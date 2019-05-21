#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D colormap;

void main()
{
	vec4 color = texture2D( colormap, texcoord );
	FragColor = vec4( color.rgb, 1.0 );
}