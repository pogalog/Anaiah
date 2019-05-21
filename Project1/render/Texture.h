#pragma once
#include <GL/glew.h>
#include <string>

class Texture
{
public:
	Texture();
	Texture( const std::string filename );
	Texture( const Texture &t );
	~Texture();

	void load( const std::string filename );


	GLuint name;
	GLenum target;
	GLuint width, height;
	std::string uniformName;
	enum MapType mapType;
};

