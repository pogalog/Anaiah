#version 330 core

layout(location = 0) out vec4 FragColor;

in vec4 light;
in vec2 uv;

// distance to light
uniform float d;
uniform float aspect;
//uniform float fogDensity;


void main()
{
    // distance to light will determine intensity
    // of light (bloom amount)
    float A = 0.05;
    float B = 0.01;
    float attenuation = A*d*d + B*d;
    float intensity = 1.0 / attenuation;
    
    // density of fog will affect intensity of light
    // and scatter radius
    vec2 ar = vec2( aspect, 1.0 );
    vec3 light_ndc = light.xyz / light.w;
    vec2 light_nwc = 0.5*(light_ndc.xy + vec2(1.0));
    float fogDensity = 12.0;
    float bloomRadius = 0.5 * fogDensity * intensity;
    vec2 uv_ar = uv * ar;
    float lightToFrag = length( uv_ar - light_nwc*ar )/aspect;
    float R = lightToFrag/bloomRadius;
    float lum = exp(-R);
    
    
    vec4 lightColor = vec4( 1.0, 1.0, 0.9, 1.0 );
    vec4 fogColor = vec4( 0.1, 0.1, 0.1, 1.0 );
	FragColor = 0.25 * fogDensity * fogColor + 0.75 * lightColor * lum;
}