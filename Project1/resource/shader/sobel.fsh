#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform vec3 view;
uniform sampler2D depthMap;
//uniform sampler2D normalMap;
uniform float xstep, ystep;

float computeLum( vec4 color )
{
	float f = 1.0;
	float n = 0.4;
	return 0.299*color.r + 0.587*color.g + 0.114*color.b;
	//return (2.0*n) / (f + n + color.x * (f-n));
}

float processNorm( vec3 n, vec3 v )
{
	return dot( n, v );
}

void main()
{
	// samples
	
	vec4 u = texture2D( depthMap, vec2( texcoord.x, texcoord.y + ystep ) );
	vec4 d = texture2D( depthMap, vec2( texcoord.x, texcoord.y - ystep ) );
	vec4 l = texture2D( depthMap, vec2( texcoord.x - xstep, texcoord.y ) );
	vec4 r = texture2D( depthMap, vec2( texcoord.x + xstep, texcoord.y ) );
	vec4 ul= texture2D( depthMap, vec2( texcoord.x - xstep, texcoord.y + ystep ) );
	vec4 ur= texture2D( depthMap, vec2( texcoord.x + xstep, texcoord.y + ystep ) );
	vec4 dl= texture2D( depthMap, vec2( texcoord.x - xstep, texcoord.y - ystep ) );
	vec4 dr= texture2D( depthMap, vec2( texcoord.x + xstep, texcoord.y - ystep ) );
	
	/*
	vec4 nu = texture2D( normalMap, vec2( texcoord.x, texcoord.y + ystep ) );
	vec4 nd = texture2D( normalMap, vec2( texcoord.x, texcoord.y - ystep ) );
	vec4 nl = texture2D( normalMap, vec2( texcoord.x - xstep, texcoord.y ) );
	vec4 nr = texture2D( normalMap, vec2( texcoord.x + xstep, texcoord.y ) );
	vec4 nul= texture2D( normalMap, vec2( texcoord.x - xstep, texcoord.y + ystep ) );
	vec4 nur= texture2D( normalMap, vec2( texcoord.x + xstep, texcoord.y + ystep ) );
	vec4 ndl= texture2D( normalMap, vec2( texcoord.x - xstep, texcoord.y - ystep ) );
	vec4 ndr= texture2D( normalMap, vec2( texcoord.x + xstep, texcoord.y - ystep ) );
	*/
	
	// compute luminance for each sample
	
	float lum_ul = computeLum( ul );
	float lum_ur = computeLum( ur );
	float lum_l = computeLum( l );
	float lum_r = computeLum( r );
	float lum_dl = computeLum( dl );
	float lum_dr = computeLum( dr );
	float lum_u = computeLum( u );
	float lum_d = computeLum( d );
	
	
	/*
	// compute dot product for each normal
	vec3 v = normalize( view );
	float n_ul = processNorm( normalize( nul.xyz ), v );
	float n_ur = processNorm( normalize( nur.xyz ), v );
	float n_l = processNorm( normalize( nl.xyz ), v );
	float n_r = processNorm( normalize( nr.xyz ), v );
	float n_dl = processNorm( normalize( ndl.xyz ), v );
	float n_dr = processNorm( normalize( ndr.xyz ), v );
	float n_u = processNorm( normalize( nu.xyz ), v );
	float n_d = processNorm( normalize( nd.xyz ), v );
	*/
	
	
	// horizontal pass
	float xsum = -lum_ul + lum_ur - 2.0*lum_l + 2.0*lum_r - lum_dl + lum_dr;
	//float n_xsum = -n_ul + n_ur - 2.0*n_l + 2.0*n_r - n_dl + n_dr;
	
	// vertical pass
	float ysum = -lum_ul - 2.0*lum_u - lum_ur + lum_dl + 2.0*lum_d + lum_dr;
	//float n_ysum = -n_ul - 2.0*n_u - n_ur + n_dl + 2.0*n_d + n_dr;
	
	// combined luminance
	
	float sum = 1.0 - pow(xsum*xsum + ysum*ysum, 0.5);
	if( sum < 0.7 )
	{
		sum = 0;
	}
	else
	{
		sum = 1.0;
	}
	
	
	//float nsum = 1.0 - pow( n_xsum*n_xsum + n_ysum*n_ysum, 0.5 );
	//nsum *= sum;
	//nsum = (nsum + 1.0)*0.5;
	//if( nsum < 0.5 ) nsum = 0;
	//else nsum = 1.0;
	
	FragColor = vec4( sum, sum, sum, sum );
	//FragColor = vec4( nsum, nsum, nsum, nsum );
}