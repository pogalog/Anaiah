#version 420 core

layout (location = 0) out vec4 FragColor;


struct	Destructo
{
	float soopa;
	float doopa;
};



uniform Blocky
{
	vec4 chicken;
	float egg;
	Destructo d;
	float f[2];
};


void main()
{
	FragColor = chicken;
	FragColor.rgb -= egg;
	FragColor.g -= d.soopa;
	FragColor.b -= d.doopa;
	FragColor.r -= f[0] + f[1];
//	FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}