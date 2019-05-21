#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D colormap;
uniform float ystep;

void main()
{
	// current fragment
	vec4 p0  = texture2D( colormap, texcoord );

	float ys = 1.5*ystep;

	// vertical pass
	vec4 p1U = texture2D( colormap, vec2( texcoord.x, texcoord.y + ys) );
	vec4 p2U = texture2D( colormap, vec2( texcoord.x, texcoord.y + 2*ys) );

	vec4 p1D = texture2D( colormap, vec2( texcoord.x, texcoord.y - ys) );
	vec4 p2D = texture2D( colormap, vec2( texcoord.x, texcoord.y - 2*ys) );

	float w0 = 6.0/16.0;
	float w1 = 4.0/16.0;
	float w2 = 1.0/16.0;

	float Rval = w0*p0.r + w1*(p1U.r + p1D.r) + w2*(p2U.r + p2D.r);
	float Gval = w0*p0.g + w1*(p1U.g + p1D.g) + w2*(p2U.g + p2D.g);
	float Bval = w0*p0.b + w1*(p1U.b + p1D.b) + w2*(p2U.b + p2D.b);

	FragColor = vec4( Rval , Gval , Bval , 1.0 );
}