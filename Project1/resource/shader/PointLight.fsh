#version 330 core
layout(location = 0) out vec4 FragColor;

uniform sampler2D colorMap;

in vec2 varUV;

void main()
{
	vec4 cm = texture2D( colorMap, varUV );
	
	FragColor = vec4( cm );
}