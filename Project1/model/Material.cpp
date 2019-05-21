#include "model/Material.h"

#include <cstdio>
#include <vector>
#include <iostream>
#include <string>

using namespace std;


Material::Material()
: specularCoeff(1.0f), alpha(1.0f)
{
	colorMap.mapType = MAP_TYPE_DIFFUSE;
	normalMap.mapType = MAP_TYPE_NORMAL;
	specularMap.mapType = MAP_TYPE_SPECULAR;
}

Material::Material( const Material &m )
{
	colorMap = m.colorMap;
	normalMap = m.normalMap;
	specularMap = m.specularMap;
	ambientColor = m.ambientColor;
	diffuseColor = m.diffuseColor;
	specularColor = m.specularColor;
	specularCoeff = m.specularCoeff;
	alpha = m.alpha;
	name = m.name;
	ambientTexture = m.ambientTexture;
	diffuseTexture = m.diffuseTexture;
	specularTexture = m.specularTexture;
	alphaTexture = m.alphaTexture;
	normalTexture = m.normalTexture;
}

Material::~Material()
{
	// TODO Need to evaluate whether this is a good idea. Lua is going to be
	// responsible for maintaining assets, so it may make some sense to dispose of the
	// GL object when the C++ object is destroyed.
	//if( colorMap.name > 0 ) glDeleteTextures( 1, &colorMap.name );
	//if( normalMap.name > 0 ) glDeleteTextures( 1, &normalMap.name );
	//if( specularMap.name > 0 ) glDeleteTextures( 1, &specularMap.name );
}

void Material::loadMap( enum MapType type )
{
    // read texture from disk using lodepng
    // from the example code (http://lodev.org/lodepng/example_decode.cpp)
    string *filename = NULL;
	Texture *texture = NULL;

    switch( type )
    {
    	case MAP_TYPE_AMBIENT:
    	{
			texture = &colorMap;
			filename = &ambientTexture;
			printf( "loading AMBIENT map: %s\n", filename->c_str() );
    		break;
    	}
        case MAP_TYPE_DIFFUSE:
        {
			texture = &colorMap;
			char buf[100];
			sprintf_s( buf, "resource/model/%s", diffuseTexture.c_str() );
			filename = new string( buf );
            printf( "loading DIFFUSE map: %s\n", filename->c_str() );
            break;
        }
        case MAP_TYPE_SPECULAR:
        {
			texture = &specularMap;
            filename = &specularTexture;
            printf( "loading SPECULAR map: %s\n", filename->c_str() );
            break;
        }
        case MAP_TYPE_NORMAL:
        {
			texture = &normalMap;
            filename = &normalTexture;
            printf( "loading NORMAL map: %s\n", filename->c_str() );
            break;
        }
    }
    std::cout << std::flush;

	texture->load( *filename );
}
