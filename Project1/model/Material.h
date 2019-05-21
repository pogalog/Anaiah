#pragma once
#include <string>
#include <GL/glew.h>

#include "render/Color.h"
#include "render/Texture.h"

enum MapType
{
    MAP_TYPE_AMBIENT,
    MAP_TYPE_DIFFUSE,
    MAP_TYPE_SPECULAR,
    MAP_TYPE_NORMAL
};


class Material
{
public:
	Material();
	Material( const Material & );
	~Material();
	
	
	void loadMap( enum MapType type );
	    
	Texture colorMap, normalMap, specularMap;
	Color ambientColor, diffuseColor, specularColor;
	float specularCoeff, alpha;
	std::string ambientTexture, diffuseTexture, specularTexture, alphaTexture, normalTexture;
	std::string name;
};
