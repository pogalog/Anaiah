#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform float time;

float nrand( vec2 co )
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


float n8rand( vec2 n )
{
	float t = fract( time );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
    
    float nrnd4 = nrand( n + 0.19*t );
    float nrnd5 = nrand( n + 0.23*t );
    float nrnd6 = nrand( n + 0.29*t );
    float nrnd7 = nrand( n + 0.31*t );
    
	return (nrnd0+nrnd1+nrnd2+nrnd3 +nrnd4+nrnd5+nrnd6+nrnd7) / 8.0;
}

void main()
{
	float noiseTCfactor = 10.0;
	vec4 noiseColor = vec4( 0.3, 0.3, 0.45, 1.0 );
	float noise = 0.25*( 1.0 - n8rand( noiseTCfactor * texcoord ) );
	FragColor = vec4( vec3( noise * noiseColor - 0.1 ), 1.0 );
}