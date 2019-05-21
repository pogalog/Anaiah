#include "Cubemap.h"
#include "geom/ProceduralGeom.h"
#include "render/Shader.h"

#include <vector>
#include <lodepng.h>
#include <iostream>
#include <glm/glm.hpp>

using namespace std;
using namespace glm;

Cubemap::Cubemap()
{
	initialized = false;
	model = geom::createCube();
	model.buildAllVAOs();
}

Cubemap::Cubemap( string path, string baseName )
{
	initMap();
	setPosXImage( path + "/" + baseName + "_pos_x.png" );
	setPosYImage( path + "/" + baseName + "_pos_y.png" );
	setPosZImage( path + "/" + baseName + "_pos_z.png" );
	setNegXImage( path + "/" + baseName + "_neg_x.png" );
	setNegYImage( path + "/" + baseName + "_neg_y.png" );
	setNegZImage( path + "/" + baseName + "_neg_z.png" );
	model = geom::createCube();
	model.buildAllVAOs();
	initialized = true;
}

Cubemap::~Cubemap()
{

}


void Cubemap::draw( const Camera &camera )
{
	if( shader == NULL ) return;
	if( !shader->valid ) return;

	GLint OldCullFaceMode;
	glGetIntegerv( GL_CULL_FACE_MODE, &OldCullFaceMode );
	GLint OldDepthFuncMode;
	glGetIntegerv( GL_DEPTH_FUNC, &OldDepthFuncMode );

	glCullFace( GL_FRONT );
	glDepthFunc( GL_LEQUAL );

	for( vector<Mesh>::iterator it = model.meshes.begin(); it != model.meshes.end(); ++it )
	{
		Mesh &mesh = *it;
		if( !mesh.visible ) continue;

		glUseProgram( shader->programID );
		glActiveTexture( GL_TEXTURE0 );
		glBindTexture( GL_TEXTURE_2D, textureName );
		int loc = glGetUniformLocation( shader->programID, "cubemap" );
		glUniform1i( loc, 0 );

		mat4 scaleMatrix = Transform::getScale( vec3( 5000, 5000, 5000 ) );
		mat4 transMatrix = Transform::getTranslate( camera.transform.position );
		mat4 modelMatrix = transMatrix * scaleMatrix;
		mat4 modelviewMatrix = camera.transform.matrix * modelMatrix;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );

		glBindVertexArray( mesh.name );
		glDrawArrays( mesh.drawMode, 0, mesh.numElements );
		glBindVertexArray( 0 );
	}

	glCullFace( OldCullFaceMode );
	glDepthFunc( OldDepthFuncMode );
}


void Cubemap::initMap()
{
	glActiveTexture( GL_TEXTURE0 );
	glEnable( GL_TEXTURE_CUBE_MAP );
	glGenTextures( 1, &textureName );
	glBindTexture( GL_TEXTURE_CUBE_MAP, textureName );
	glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE );

	initialized = true;
}

void Cubemap::setPosXImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_POSITIVE_X );
}

void Cubemap::setPosYImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_POSITIVE_Y );
}

void Cubemap::setPosZImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_POSITIVE_Z );
}

void Cubemap::setNegXImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_NEGATIVE_X );
}

void Cubemap::setNegYImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y );
}

void Cubemap::setNegZImage( string filename )
{
	if( !initialized ) initMap();
	loadImage( filename, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z );
}

void Cubemap::loadImage( string filename, GLuint cubemapAssignment )
{
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

	glTexImage2D( cubemapAssignment, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, &image[0] );

	// free image from RAM
	image.clear();
}
