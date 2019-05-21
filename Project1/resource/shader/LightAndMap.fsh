varying vec3 eyeDir, toLight;
varying vec2 texcoordVar;
uniform sampler2D colorMap, normalMap;

void main()
{
    vec4 base = texture2D( colorMap, texcoordVar );
    
    vec4 diff = vec4( 1, 1, 1, 1 );
    vec4 spec = vec4( 1, 1, 1, 1 );
    
    vec4 vDiffuse = vec4( 0, 0, 0, 0 );
    vec4 vSpecular = vec4( 0, 0, 0, 0 );
    
    vec3 lVec = normalize( toLight );
    vec3 vVec = normalize( eyeDir );
    vec3 nmap = texture2D( normalMap, texcoordVar );
    vec3 bump = normalize( nmap * 2.0 - 1.0 );
    
    float diffuse = max( dot( -lVec, bump ), 0.0 );
    vDiffuse += diff * diffuse;
    
    float specular = pow( clamp( dot( reflect( -lVec, bump ), vVec ), 0.0, 1.0 ), 20.0 );
    vSpecular += spec * specular;
    
    gl_FragColor = ( vDiffuse * base + vSpecular ) * 1.0;
}
