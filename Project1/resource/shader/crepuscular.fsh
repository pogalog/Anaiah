#version 330 core

layout(location = 0) out vec4 FragColor;

in vec4 light;
in vec2 uv;

uniform float aspect;
uniform sampler2D map;

float NUM_SAMPLES;
float density, exposure, decayFactor, weight;

void main()
{
    // parameters
    NUM_SAMPLES = 200.0;
    exposure = 0.1;
    weight = 20.0/NUM_SAMPLES;
    decayFactor = 0.99;
    
    vec3 light_ndc = light.xyz / light.w;
    vec2 light_nwc = 0.5*(light_ndc.xy + vec2(1.0));
    vec2 dr = (uv - light_nwc) / NUM_SAMPLES;
    vec4 color = texture2D( map, uv );
    float decay = 1.0;
    
    vec2 tc = vec2( light_nwc );
    float lum;
    for( int i = 0; i < NUM_SAMPLES; i++ )
    {
        // step from the light source toward the current fragment
        tc += dr;
        
        vec4 sample = texture2D( map, tc );
        lum = 0.299*sample.r + 0.587*sample.g + 0.114*sample.b;
        sample.r = lum; sample.g = lum; sample.b = lum;
        sample *= decay * weight;
        color += sample;
        decay *= decayFactor;
    }
    
    FragColor = vec4( color.rgb * exposure, 1.0 );
}