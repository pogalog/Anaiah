#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D colormap;

void main()
{
	vec4 color = texture2D( colormap, texcoord );
	// compute the brightness (squared)
	float lum = 0.299*color.r + 0.587*color.g + 0.114*color.b;
	float threshold = 0.7;
	if( lum > threshold )
	{
		FragColor = vec4( 1.0 );
	}
	else
	{
		//FragColor = vec4( 0.1*color.rgb, 0.2 );
		FragColor = vec4( 0 );
	}
}