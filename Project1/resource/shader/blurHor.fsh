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
	vec4 p3R = texture2D( colormap, vec2( texcoord.x + 3*xs, texcoord.y ) );
	vec4 p4R = texture2D( colormap, vec2( texcoord.x + 4*xs, texcoord.y ) );

	vec4 p1L = texture2D( colormap, vec2( texcoord.x - xs, texcoord.y ) );
	vec4 p2L = texture2D( colormap, vec2( texcoord.x - 2*xs, texcoord.y ) );
	vec4 p3L = texture2D( colormap, vec2( texcoord.x - 3*xs, texcoord.y ) );
	vec4 p4L = texture2D( colormap, vec2( texcoord.x - 4*xs, texcoord.y ) );

	float w0 = 1.2 * 70.0/256.0;
	float w1 = 1.2 * 56.0/256.0;
	float w2 = 1.2 * 28.0/256.0;
	float w3 = 1.2 * 8.0/256.0;
	float w4 = 1.2 * 1.0/256.0;

	float Rval = w0*p0.r + w1*(p1R.r + p1L.r) + w2*(p2R.r + p2L.r);
		Rval = Rval + w3*(p3R.r + p3L.r) + w4*(p4R.r + p4L.r);
	float Gval = w0*p0.g + w1*(p1R.g + p1L.g) + w2*(p2R.g + p2L.g);
		Gval = Gval + w3*(p3R.g + p3L.g) + w4*(p4R.g + p4L.g);
	float Bval = w0*p0.b + w1*(p1R.b + p1L.b) + w2*(p2R.b + p2L.b);
		Bval = Bval + w3*(p3R.b + p3L.b) + w4*(p4R.b + p4L.b);	

	FragColor = vec4( Rval , Gval , Bval , 1.0 );
}
