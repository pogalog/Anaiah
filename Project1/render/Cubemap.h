#pragma once

#include <string>
#include <GL/glew.h>

#include "model/Model.h"
#include "game/Camera.h"

class Shader;
class Cubemap
{
public:
	Cubemap();
	Cubemap( std::string path, std::string baseName );
	~Cubemap();

	void setPosXImage( std::string filename );
	void setPosYImage( std::string filename );
	void setPosZImage( std::string filename );
	void setNegXImage( std::string filename );
	void setNegYImage( std::string filename );
	void setNegZImage( std::string filename );

	void draw( const Camera &camera );

	GLuint textureName;
	Model model;
	Shader *shader;

private:
	void loadImage( std::string filename, GLuint assignment );
	void initMap();

	bool initialized;
};