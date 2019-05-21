#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texcoord0;
layout(location = 4) in ivec4 boneIDs;
layout(location = 5) in vec4 weights;

const int MAX_BONES = 30;

out vec2 TexCoords;
out vec3 WorldNorm, lightDir, FragPos;
out vec4 eye, light;


uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 lightPos;
uniform mat4 nodeTransform[MAX_BONES];



void main()
{
	mat4 boneTransform = nodeTransform[boneIDs[0]] * weights[0];
	boneTransform += nodeTransform[boneIDs[1]] * weights[1];
	boneTransform += nodeTransform[boneIDs[2]] * weights[2];
	boneTransform += nodeTransform[boneIDs[3]] * weights[3];
	
	vec4 worldPos = modelMatrix * vec4( position, 1.0 );
	FragPos = worldPos.xyz;
	TexCoords = texcoord0;
	
	vec4 pos4 = vec4( position, 1.0 );
	
	// transform matrices
	mat4 vm = viewMatrix * modelMatrix;
	mat4 pvm = projectionMatrix * vm;
	mat4 pv = projectionMatrix * viewMatrix;
	mat3 normalMatrix = transpose( inverse( mat3( modelMatrix ) ) );
	
	vec4 posL = boneTransform * pos4;
	vec3 normalL = mat3( boneTransform ) * normal;
//	mat4 worldTrans = transpose( inverse( vm ) );
	WorldNorm = normalMatrix * normalL;
	
	
	eye = vm * pos4;
	light = vm * vec4( lightPos, 1.0 );
	lightDir = (light - eye).xyz;
	
	gl_Position = pvm * posL;
}
