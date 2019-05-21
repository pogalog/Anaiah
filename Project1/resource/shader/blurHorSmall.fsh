#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D colormap;
uniform float xstep;

void main()
{
	// current fragment
	vec4 p0  = texture2D( colormap, texcoord );

	float xs = 1.5*xstep;

	// horizontal pass
	vec4 p1R = texture2D( colormap, vec2( texcoord.x + xs, texcoord.y ) );
	vec4 p2R = texture2D( colormap, vec2( texcoord.x + 2*xs, texcoord.y ) );

	vec4 p1L = texture2D( colormap, vec2( texcoord.x - xs, texcoord.y ) );
	vec4 p2L = texture2D( colormap, vec2( texcoord.x - 2*xs, texcoord.y ) );

	float w0 = 6.0/16.0;
	float w1 = 4.0/16.0;
	float w2 = 1.0/16.0;

	float Rval = w0*p0.r + w1*(p1R.r + p1L.r) + w2*(p2R.r + p2L.r);
	float Gval = w0*p0.g + w1*(p1R.g + p1L.g) + w2*(p2R.g + p2L.g);
	float Bval = w0*p0.b + w1*(p1R.b + p1L.b) + w2*(p2R.b + p2L.b);

	FragColor = vec4( Rval , Gval , Bval , 1.0 );
}