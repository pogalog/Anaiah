#version 330 core
layout (location = 0) out vec4 gPosition;
layout (location = 1) out vec4 gNormal;
layout (location = 2) out vec4 gAlbedoSpec;

in vec2 TexCoords;
in vec3 FragPos;
in vec3 WorldNorm;

uniform sampler2D colorMap;
uniform sampler2D specmap;


void main()
{
    // store the fragment position vector in the first gbuffer texture
    gPosition = vec4( FragPos, 1.0 );
	
    // also store the per-fragment normals into the gbuffer
    gNormal = vec4( normalize( WorldNorm ), 1.0 );
	
    // and the diffuse per-fragment color
    gAlbedoSpec.rgb = texture2D( colorMap, TexCoords ).rgb;
	
    // store specular intensity in gAlbedoSpec's alpha component
    gAlbedoSpec.a = texture2D( specmap, TexCoords ).r;
	gAlbedoSpec.a = 1.0;
}