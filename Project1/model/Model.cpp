#include <cstdio>
#include <iostream>
#include <algorithm>

#include "Model.h"
#include "Mesh.h"
#include "render/Shader.h"
#include "render/Texture.h"
#include "math/Transform.h"
#include "game/Camera.h"


using namespace std;
using namespace glm;

Model::Model()
: visible(true)
{
	Mesh primaryMesh;
	meshes.push_back( primaryMesh );
	lineWidth = 1.0f;
	billboard = false;
}

Model::~Model()
{
}


void displayMat4( const glm::mat4 m )
{
	printf( "%.3f %.3f %.3f %.3f\n%.3f %.3f %.3f %.3f\n%.3f %.3f %.3f %.3f\n%.3f %.3f %.3f %.3f\n\n",
			m[0][0], m[0][1], m[0][2], m[0][3],
			m[1][0], m[1][1], m[1][2], m[1][3],
			m[2][0], m[2][1], m[2][2], m[2][3],
			m[3][0], m[3][1], m[3][2], m[3][3] );
}

void Model::buildAllVAOs()
{
	for( vector<Mesh>::iterator mit = meshes.begin(); mit != meshes.end(); ++mit )
	{
		Mesh &mesh = *mit;
		mesh.buildVAO();
	}
}


void Model::draw( const Camera &camera, bool shaderOverride )
{
	if( !visible ) return;

	// render all Mesh objects
	for( vector<Mesh>::iterator it = meshes.begin(); it != meshes.end(); ++it )
	{
		Mesh &mesh = *it;
		Shader *shader = mesh.getShader();

		if( !mesh.visible ) continue;
		if( !shaderOverride && (!shader || !shader->valid) ) continue;
		if( !shaderOverride ) glUseProgram( shader->programID );

		// Textures
		if( textures.size() > 0 )
		{
			glEnable( GL_TEXTURE_2D );
		}
		
		for( unsigned int i = 0; i < textures.size(); ++i )
		{
			Texture *tex = textures.at( i );
			glActiveTexture( GL_TEXTURE0 + i );
			glBindTexture( GL_TEXTURE_2D, tex->name );
			GLuint loc = glGetUniformLocation( shader->programID, tex->uniformName.c_str() );
			mesh.setSampler2DUniform( tex->uniformName, i );
		}
		// compute matrices
		mat4 viewMatrix = camera.transform.matrix;
		mat4 modelMatrix;
		if( billboard )
		{
			vec3 look = glm::normalize( camera.transform.position - transform.position );
			vec3 p = transform.position;
			vec3 up = camera.transform.localY;
			vec3 right = glm::cross( look, up );
			mat3 invView = glm::transpose( mat3( viewMatrix ) );
			right = invView * vec3( 1, 0, 0 );
			up = invView * vec3( 0, 1, 0 );

			modelMatrix[0] = vec4( right, 0 );
			modelMatrix[1] = vec4( up, 0 );
			modelMatrix[2] = vec4( look, 0 );
			modelMatrix[3] = vec4( p, 1 );
			mat4 scale = Transform::getScale( transform.scale );
			modelMatrix *= scale;
		}
		else
		{
			modelMatrix = transform.matrix;
		}
		mat4 modelviewMatrix = viewMatrix * modelMatrix;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;
		//		Vec4 light4 = Vec4( light, 0.0 );
		//		Vec4 L4 = camera.transform->matrix * light4;
		//		Vec3 L3 = Vec3( L4 );
		glUniform3f( glGetUniformLocation( shader->programID, "color" ), 1, 1, 1 );
		//		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVM" ), 1, GL_FALSE, (GLfloat*)&modelviewMatrix );
		//		glUniform3fv( glGetUniformLocation( shader->programID, "light" ), 1, &L3[0] );
		Uniform<mat4> *mvp = (Uniform<mat4>*)shader->getUniform( "MVP" );
		if( mvp ) mvp->setData( modelviewProjectionMatrix );
		mesh.copyUniformValues();
		shader->assignUniformValues();

		GLint camMVPloc = glGetUniformLocation( shader->programID, "cameraMVP" );
		if( camMVPloc >= 0 )
		{
			glUniformMatrix4fv( camMVPloc, 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
		}

		if( mesh.drawMode == GL_LINES ) glLineWidth( lineWidth );

		glEnableVertexAttribArray( 0 );
		glBindVertexArray( mesh.name );
		glDrawArrays( mesh.drawMode, 0, mesh.numElements );
		glBindVertexArray( 0 );
		glDisableVertexAttribArray( 0 );
		if( textures.size() > 0 )
		{
			glBindTexture( GL_TEXTURE_2D, 0 );
			glDisable( GL_TEXTURE_2D );
		}
	}
}






