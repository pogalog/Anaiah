attribute vec3 normal;
attribute vec4 position;
attribute vec2 texcoord;

varying vec3 eyeDir, toLight;
varying vec2 texcoordVar;

uniform vec3 light;

void main()
{
    texcoordVar = texcoord;
    vec3 tangent;

    vec3 c1 = cross( normal, vec3( 0.0, 0.0, 1.0 ) ); 
    vec3 c2 = cross( normal, vec3( 0.0, 1.0, 0.0 ) );

    if( length(c1) > length(c2) )
    {
        tangent = c1;
    }
    else
    {
        tangent = c2;
    }

    eyeDir = vec3( gl_ModelViewMatrix * position );

    vec3 n = normalize( gl_NormalMatrix * normal );
    vec3 t = normalize( gl_NormalMatrix * tangent );
    vec3 b = cross( n, t );

    vec3 vp;
    vec3 lightPos = light - eyeDir;
    vp.x = dot( lightPos, t );
    vp.y = dot( lightPos, b );
    vp.z = dot( lightPos, n );
    toLight = vp;

    vec3 v;
    v.x = dot( eyeDir, t );
    v.y = dot( eyeDir, b );
    v.z = dot( eyeDir, n );
    eyeDir = normalize( v );

    gl_Position = gl_ModelViewProjectionMatrix * position;
    gl_FrontColor = gl_Color;
}
