#include "TextItem.h"
#include "geom/ProceduralGeom.h"
#include "model/ModelUtil.h"
#include "game/Camera.h"

#include <iostream>

using namespace std;
using namespace glm;

TextItem::TextItem( FontMap *map, string text )
	:fontMap( map ), text( text ), size( 1.0f ), visible( true ), toodee( true )
{
	buildModel();
}

TextItem::~TextItem()
{

}


// private
void TextItem::buildModel()
{
	if( fontMap == NULL ) return;

	vector<Model> letters;
	float H = size;
	float positionX = 0;
	float positionY = 0;
	for( unsigned int i = 0; i < text.length(); ++i )
	{
		char c = text.at( i );
		if( c == '\n' )
		{
			positionX = 0;
			positionY -= size;
			continue;
		}
		FontMapTexcoord ft = fontMap->getChar( c );
		float aspectRatio = (float)(abs( ft.t1.x - ft.t0.x ) / abs( ft.t1.y - ft.t0.y ));
		Model m = geom::createQuad( aspectRatio, Color( 1, 1, 1, 1 ), ft );
		Mesh &mesh = m.getPrimaryMesh();
		float W = aspectRatio * H;
		Transform &transform = mesh.transform;
		transform.setPosition( vec3( positionX + ft.offset * W, positionY, 0.0f ) );
		positionX += ft.advance * W;
		width = positionX + ft.advance * W;
		letters.push_back( m );
	}

	Mesh &primary = model.getPrimaryMesh();
	primary.material = new Material();
	shader = fontMap->getShader();
	primary.material->colorMap = fontMap->copyTexture();
	model_util::groupMeshes( letters, primary );
	primary.buildVAO();
}


// main
void TextItem::draw( const Camera &camera )
{
	if( !visible ) return;

	Mesh &mesh = model.getPrimaryMesh();
	Material *material = mesh.material;

	if( !mesh.visible ) return;
	if( !shader || !shader->valid ) return;

	glUseProgram( shader->programID );

	// bind texture
	int activeTexture = 0;
	if( material->colorMap.name > 0 )
	{
		int loc = glGetUniformLocation( shader->programID, "colormap" );
		if( loc > -1 )
		{
			glActiveTexture( GL_TEXTURE0 + activeTexture );
			glBindTexture( GL_TEXTURE_2D, material->colorMap.name );
			glUniform1i( loc, activeTexture );
			++activeTexture;
		}
	}

	// compute matrices
	mat4 modelviewProjectionMatrix;
	if( toodee )
	{
		mat4 projectionMatrix = camera.orthoLens.projectionMatrix;
		mat4 viewMatrix = mat4();
		mat4 modelMatrix = model.transform.matrix;
		mat4 modelviewMatrix = viewMatrix * modelMatrix;
		modelviewProjectionMatrix = projectionMatrix * modelviewMatrix;
	}
	else
	{
		mat4 projectionMatrix = camera.lens.projectionMatrix;
		mat4 viewMatrix = camera.transform.matrix;
		vec3 look = glm::normalize( camera.transform.position - model.transform.position );
		mat4 modelMatrix;
		vec3 p = model.transform.position;
		vec3 up = camera.transform.localY;
		vec3 right = glm::cross( look, up );
		mat3 invView = glm::transpose( mat3( viewMatrix ) );
		right = invView * vec3( 1, 0, 0 );
		up = invView * vec3( 0, 1, 0 );
		
		modelMatrix[0] = vec4( right, 0 );
		modelMatrix[1] = vec4( up, 0 );
		modelMatrix[2] = vec4( look, 0 );
		modelMatrix[3] = vec4( p, 1 );
		mat4 scale = Transform::getScale( model.transform.scale );
		modelMatrix *= scale;
		mat4 modelviewMatrix = viewMatrix * modelMatrix;
		modelviewProjectionMatrix = projectionMatrix * modelviewMatrix;
		
		// TODO do this in the shader, you dummy!!
		//vec4 glPosition = modelviewProjectionMatrix * vec4( p, 1 );
		//p /= glPosition.w;
		//modelMatrix[3] = vec4( p, 1 );
		//modelviewMatrix = viewMatrix * modelMatrix;
		//modelviewProjectionMatrix = projectionMatrix * modelviewMatrix;
	}

	// assign uniform values
	glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
	glUniform4f( glGetUniformLocation( shader->programID, "highlight" ), color.r(), color.g(), color.b(), color.a() );

	glBindVertexArray( mesh.name );
	glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
	glBindVertexArray( 0 );
}



void TextItem::setText( string text )
{
	this->text = text;

	glDeleteBuffers( 1, &model.getPrimaryMesh().positionBufferName );
	glDeleteBuffers( 1, &model.getPrimaryMesh().uvBufferName );
	glDeleteBuffers( 1, &model.getPrimaryMesh().colorBufferName );
	glDeleteVertexArrays( 1, &model.getPrimaryMesh().name );
	buildModel();
}

