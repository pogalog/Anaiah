#include "Texture.h"
#include "model/Material.h"
#include <iostream>
#include <vector>
#include <lodepng.h>

using namespace std;

Texture::Texture()
	: name(0), target(0), width(0), height(0), mapType( MAP_TYPE_DIFFUSE )
{

}

Texture::Texture( const string filename )
{
	load( filename );
}

Texture::Texture( const Texture &t )
{
	name = t.name;
	target = t.target;
	width = t.width;
	height = t.height;
	mapType = t.mapType;
	uniformName = t.uniformName;
}


Texture::~Texture()
{

}


void Texture::load( const string filename )
{
	// read texture from disk using lodepng
	// from the example code (http://lodev.org/lodepng/example_decode.cpp)

	if( filename.length() == 0 )
	{
		cout << "Attempting to load texture that don't be existing!!" << endl;
		return;
	}

	// the raw pixels
	std::vector<unsigned char> image;
	unsigned width, height;

	// decode
	unsigned error = lodepng::decode( image, width, height, filename.c_str() );

	// if there's an error, display it
	if( error ) cout << "decoder error " << error << ": " << lodepng_error_text( error ) << endl;

	// pass the data into OpenGL, create the texture
	GLuint name;
	glGenTextures( 1, &name );
	glBindTexture( GL_TEXTURE_2D, name );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, &image[0] );
	glBindTexture( GL_TEXTURE_2D, 0 );

	// free image from RAM
	image.clear();

	// fill the TextureInfo
	this->name = name;
	this->target = GL_TEXTURE_2D;
	this->width = width;
	this->height = height;
}
