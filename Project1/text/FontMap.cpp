#include "FontMap.h"
#include "fileio/FontMapIOUtil.h"
#include "render/Shader.h"

#include <lodepng.h>
#include <iostream>
#include <GL/glew.h>


namespace fmio
{
	std::ifstream infile;
	char *buffer;
	int marker = 0;
}


using namespace glm;
using namespace std;
using namespace fmio;
using namespace fmfio;

FontMap::FontMap( const FontMap &rhs )
	:texture( rhs.copyTexture() ), texcoords( rhs.texcoords )
{
	
}


FontMap::~FontMap()
{
	//glDeleteTextures( 1, &textureInfo.name );
}


FontMapTexcoord& FontMap::getChar( char c )
{
	if( c < 32 || c > 126 ) return texcoords.at( 0 );
	return texcoords.at( (int)c - 32 );
}


FontMap* FontMap::loadFontMapFromFile( string fn )
{
	FontMap *map = NULL;

	string *filename = NULL;

	char buf[100];
	sprintf_s( buf, "resource/font/%s.png", fn.c_str() );
	filename = new string( buf );
	printf( "loading DIFFUSE map: %s\n", filename->c_str() );

	std::cout << std::flush;
	if( filename->length() == 0 )
	{
		cout << "Attempting to load font texture that don't be existing!!" << endl;
		return map;
	}

	// the raw pixels
	std::vector<unsigned char> image;
	unsigned width, height;

	// decode
	unsigned error = lodepng::decode( image, width, height, filename->c_str() );

	// if there's an error, display it
	if( error ) cout << "decoder error " << error << ": " << lodepng_error_text( error ) << endl;

	// pass the data into OpenGL, create the texture
	GLuint texture;
	glGenTextures( 1, &texture );
	glBindTexture( GL_TEXTURE_2D, texture );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, &image[0] );
	glBindTexture( GL_TEXTURE_2D, 0 );

	// free image from RAM
	image.clear();

	// fill the TextureInfo
	map = new FontMap();
	map->texture.name = texture;
	map->texture.target = GL_TEXTURE_2D;
	map->texture.width = width;
	map->texture.height = height;

	// load the texcoord data from file
	string fontName = filename->substr( 0, filename->length() - 4 );
	loadTexcoordData( map, fontName );

	return map;
}

void FontMap::loadTexcoordData( FontMap *map, string name )
{
	char buf[100];
	sprintf_s( buf, "%s.map", name.c_str() );
	string filename( buf );

	cout << "Loading texture coordinate map: " << filename << endl;

	infile = ifstream();
	infile.open( filename.c_str(), ios::in | ios::binary );
	if( !infile.is_open() )
	{
		cout << "File not found: " << filename.c_str() << endl;
		return;
	}


	ifstream in( filename.c_str(), std::ifstream::binary | std::ifstream::ate );
	unsigned long fileSize = (unsigned long)in.tellg();
	buffer = new char[fileSize];
	infile.seekg( 0 );
	if( !infile.read( buffer, fileSize ) )
	{
		cout << "Unable to open file: " << filename << endl;
		return;
	}

	// init the fileio
	fmfio::init( buffer, &marker );

	// read the data
	// byte order identification
	int boid = readInt();
	if( boid != 13 )
	{
		fmfio::changeByteOrder();
	}

	for( int i = 0; i < 95; ++i )
	{
		vec2 t0 = readVec2();
		vec2 t1 = readVec2();
		float ascent = readFloat();
		float descent = readFloat();
		float advance = readFloat();
		float offset = readFloat();

		map->addTexcoord( FontMapTexcoord( t0, t1, ascent, descent, advance, offset ) );
	}

	infile.close();
	delete buffer;
	buffer = NULL;
	marker = 0;
}




// private
FontMap::FontMap()
{

}
