#version 330 core
layout(location = 0) out vec4 FragColor;

uniform float time;

in vec2 fragCoord;

void main()
{
    float t2 = time / 3.1415927;
    
    // center of rotation
    vec2 zc = vec2( -0.8354, -0.2330 );
    
    float A = 4.0e-5;
    float s = 3.0 - 3.0*exp( -A*time );
    vec2 size = vec2( s, s );
    vec2 low_bound = zc - 0.5*size;
    vec2 high_bound = zc + 0.5*size;
    
    // only divide by width to avoid skewing image
	vec2 uv = fragCoord.xy * vec2( 1.6, .9 );
    
    vec2 dr = high_bound - low_bound;
    vec2 zij = uv * dr + low_bound;
    
    // rotation matrix
    float angle = sin( 0.15*time );
    mat2 m = mat2( cos(angle), -sin(angle), sin(angle), cos(angle) );
    
    const float num_iterations = 1000.0;
    float val = 0.0;
    vec2 z = vec2( 0.0, 0.0 );
    vec2 c = m*(zij - zc) + zc;
    
    // compute
    for( float i = 0.0; i < num_iterations; i++ )
    {
        z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;
        
        // bring out additional detail
        float a1 = pow( z.x, 3.0 );
        float a2 = log( abs(z.y * z.y * sin(t2)) );
//        float a3 = pow( exp(sin(z1.x)), 3.0 );
        float b1 = pow( z.y, 3.0 );
        float b2 = log( abs(z.x * z.x * sin(t2)) );
//        float b3 = pow( exp(sin(z1.y)), 3.0 );
        
        float a = a1 * a2;
        float b = b1 * b2;
        
        if( a + b < 10.0*exp(-(1.5 + 1.25*sin(t2))) )
        {
            val++;
        }
    }
    
    // map colors
    float sv = exp( -1.5*(5.5 + 2.0*sin(0.1*time))*val / num_iterations );
    vec3 color = vec3( 0.0 );
    
    float Rf = 0.5;
    float R0 = (0.25 + 0.4*cos(Rf*time))*uv.y;
    float Rw = 0.05 + 0.5*sin(Rf*time);
    float R = R0 + exp( -pow( (sv - 0.5)/Rw, 2.0 ) );
    color.r = clamp( R, 0.0, 1.0 );
    
    float Gf = 0.25;
    float G0 = (0.75 - 0.2*sin(Gf*time))*sin( 0.002*uv.y )*uv.x;
    float Gw = 0.25 + 0.4*cos(Gf*time);
    float G = G0 + exp( -pow( (sv - 0.5)/Gw, 2.0 ) );
    color.g = clamp( G, 0.0, 1.0 );
    
    float Bf = 0.1;
    float B0 = (0.1 + 0.3*cos(Bf*time))*cos( 0.001*uv.x )*uv.y;
    float Bw = 0.54;
    float B = B0 + exp( -pow( (sv - 0.5)/Bw, 2.0 ) );
    color.b = clamp( B, 0.0, 1.0 );
    
    float pulse = 0.0;
    
    color *= (0.65 + pulse) * length( color );
	FragColor = vec4( color, 1.0 );
}



