#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texcoord0;
layout(location = 4) in ivec4 boneIDs;
layout(location = 5) in vec4 weights;

const int MAX_BONES = 30;

out vec2 tc;
out vec3 worldNorm, lightDir;
out vec4 eye, light;
//out vec3 outWorldPos;

uniform mat4 MVP;
uniform mat4 MVM;
uniform vec3 lightPos;
uniform mat4 nodeTransform[MAX_BONES];

void main()
{
	mat4 boneTransform = nodeTransform[boneIDs[0]] * weights[0];
	boneTransform += nodeTransform[boneIDs[1]] * weights[1];
	boneTransform += nodeTransform[boneIDs[2]] * weights[2];
	boneTransform += nodeTransform[boneIDs[3]] * weights[3];
	
	tc = texcoord0;
	vec4 pos4 = vec4( position, 1.0 );
	
	vec4 posL = boneTransform * pos4;
	vec4 normalL = boneTransform * vec4( normal, 0.0 );
	mat4 worldTrans = transpose( inverse( MVM ) );
	worldNorm = (worldTrans * normalL).xyz;
	//outWorldPos = (worldTrans * posL).xyz;
	
	eye = MVM * pos4;
	light = MVM * vec4( lightPos, 1.0 );
	lightDir = (light - eye).xyz;
	
	gl_Position = MVP * posL;
}
