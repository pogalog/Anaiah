#version 330 core

layout (location = 0) out vec4 FragColor;

in vec2 TexCoords;
in vec3 WorldNorm, lightDir, FragPos;
in vec4 eye, light;

uniform sampler2D colorMap;

void main()
{
	vec4 base = texture2D( colorMap, TexCoords );
	
	vec4 vAmbient = vec4( 0.2, 0.2, 0.2, 1.0 );
	vec4 vDiffuse = vec4( 0, 0, 0, 0 );
	vec4 vSpecular = vec4( 0, 0, 0, 0 );
	
	float distSqrd = dot( lightDir, lightDir );
	vec3 lVec = lightDir * inversesqrt( distSqrd );
	vec3 vVec = normalize( eye.xyz );
	
	vec3 norm = -normalize( WorldNorm );
	float diffuse = max( -dot( lVec, norm ), 0.0 );
	float specular = pow( clamp( dot( reflect( lVec, norm ), vVec ), 0.0, 1.0 ), 10.0 );
	specular = 0.0;
	vDiffuse += diffuse;
	vSpecular += specular;
	
	FragColor = ( (vAmbient + vDiffuse) * base + vSpecular ) * 1.0;
	//FragColor = vec4( diffuse, diffuse, diffuse, 1.0 );
	//FragColor = vec4( n, 1.0 );
	//FragColor = vec4( tc.x, tc.y, 0.5, 1.0 );
}