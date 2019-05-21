#pragma once

#include <string>
#include <vector>
#include <GL/glew.h>
#include <glm/glm.hpp>

#include "model/Material.h"

class Shader;

struct FontMapTexcoord
{
	FontMapTexcoord( glm::vec2 t0, glm::vec2 t1, float ascent, float descent, float advance, float offset )
		:t0( t0 ), t1( t1 ), ascent( ascent ), descent( descent ), advance( advance ), offset( offset )
	{}

	glm::vec2 t0, t1;
	float ascent, descent, advance, offset;
};


class FontMap
{
public:
	FontMap( const FontMap& );
	~FontMap();

	// main
	FontMapTexcoord& getChar( char c );

	// accessor
	GLint getGLName() const { return texture.name; }
	Texture& getTexture() { return texture; }
	Texture copyTexture() const { return texture; }
	std::vector<FontMapTexcoord>& getTexcoords() { return texcoords; }
	Shader* getShader() { return shader; }


	// mutator
	void addTexcoord( FontMapTexcoord tc ) { texcoords.push_back( tc ); }
	void setShader( Shader *shader ) { this->shader = shader; }

	// named constructor
	static FontMap* loadFontMapFromFile( std::string fn );

private:
	FontMap();
	Texture texture;
	static void loadTexcoordData( FontMap*, std::string name );


	std::vector<FontMapTexcoord> texcoords;
	Shader *shader;

};