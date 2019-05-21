#version 330 core

layout(location = 0) out vec4 FragColor;

in vec2 texcoord;
uniform sampler2D map0, map1, map2, map3;

void main()
{
	vec4 c0 = texture2D( map0, texcoord );
	vec4 c1 = texture2D( map1, texcoord );
	vec4 c2 = texture2D( map2, texcoord );
	vec4 c3 = texture2D( map3, texcoord );
	vec3 rgb = 1.0 * c0.rgb * c0.a +   1.0 * c1.rgb * c1.a +   1.0 * c2.rgb * c2.a +  1.0 * c3.rgb * c3.a;
	FragColor = vec4( rgb, 1.0 );
}