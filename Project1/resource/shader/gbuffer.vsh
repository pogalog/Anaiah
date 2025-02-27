#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texcoord0;

out vec3 FragPos;
out vec2 TexCoords;
out vec3 Normal;

uniform mat4 model;
uniform mat4 pv;

void main()
{
    vec4 worldPos = model * vec4( position, 1.0 );
    FragPos = worldPos.xyz; 
    TexCoords = texcoord0;
    
    mat3 normalMatrix = transpose( inverse( mat3( model ) ) );
    Normal = normalMatrix * normal;

    gl_Position = pv * worldPos;
}