#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
in vec4 letterColor;
uniform sampler2D colormap;
uniform vec4 highlight;

void main()
{
	vec4 mapColor = vec4( texture2D( colormap, texcoord ) );
	vec4 color = vec4( mapColor.rgb + letterColor.rgb, mapColor.a * letterColor.a );
	FragColor = color * highlight;
}