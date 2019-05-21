#include "Overlay.h"
#include "OverlayItem.h"
#include "text\TextItem.h"
#include "geom/ProceduralGeom.h"

#include <iostream>

using namespace std;
using namespace glm;

Overlay::Overlay()
	:model( geom::createQuad( 1.0f, Color( 1, 1, 1, 0.4f ) ) ), font( NULL ), overlayItems( vector<OverlayItem*>() ), position( vec2() ),
	dimension( vec2() ), visible( false ), toodee( true )
{
}


Overlay::~Overlay()
{

}


void Overlay::draw( const Camera &camera )
{
	if( !visible ) return;

	Mesh &mesh = model.getPrimaryMesh();

	if( !mesh.visible ) return;
	if( !shader || !shader->valid ) return;

	// render menu background
	glUseProgram( shader->programID );

	// compute matrices
	mat4 projectionMatrix = toodee ? camera.orthoLens.projectionMatrix : camera.lens.projectionMatrix;
	mat4 viewMatrix = toodee ? mat4() : camera.transform.matrix;
	mat4 modelMatrix = model.transform.matrix * scaleMatrix;
	mat4 modelviewMatrix = viewMatrix * modelMatrix;
	mat4 modelviewProjectionMatrix = projectionMatrix * modelviewMatrix;

	// assign uniform values
	glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
	// temporarily do this (need to just replace the shader to support vertex color)
	glUniform4f( glGetUniformLocation( shader->programID, "color" ), 1, 1, 1, 0.4f );

	glBindVertexArray( mesh.name );
	glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
	glBindVertexArray( 0 );


	// render menu items
	int i = 0;
	for( vector<OverlayItem*>::iterator it = overlayItems.begin(); it != overlayItems.end(); ++it )
	{
		OverlayItem *oi = *it;
		if( !oi->isVisible() )
		{
			++i;
			continue;
		}

		Model &gmiModel = oi->getText()->getModel();
		Mesh &gmiMesh = gmiModel.getPrimaryMesh();
		Material *material = gmiMesh.material;
		Shader *gmiShader = itemShader;
		glUseProgram( gmiShader->programID );
		if( itemShader == NULL || !itemShader->valid ) continue;

		// bind texture
		int activeTexture = 0;
		if( material->colorMap.name > 0 )
		{
			int loc = glGetUniformLocation( gmiShader->programID, "colormap" );
			if( loc > -1 )
			{
				glActiveTexture( GL_TEXTURE0 + activeTexture );
				glBindTexture( GL_TEXTURE_2D, material->colorMap.name );
				glUniform1i( loc, activeTexture );
				++activeTexture;
			}
		}

		// compute matrices
		mat4 menuMatrix = mat4( model.transform.matrix );
		modelMatrix = menuMatrix * gmiMesh.transform.matrix * gmiModel.transform.matrix;
		modelviewMatrix = viewMatrix * modelMatrix;
		modelviewProjectionMatrix = projectionMatrix * modelviewMatrix;


		// assign uniform values
		Color &color = oi->getText()->getColor();
		glUniformMatrix4fv( glGetUniformLocation( gmiShader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
		glUniform4f( glGetUniformLocation( gmiShader->programID, "highlight" ), color.r(), color.g(), color.b(), color.a() );

		glBindVertexArray( gmiMesh.name );
		glDrawArrays( GL_TRIANGLES, 0, gmiMesh.numElements );
		glBindVertexArray( 0 );
		++i;
	}

}


OverlayItem* Overlay::addOverlayItem( string message )
{
	OverlayItem *gmi = new OverlayItem( this, message );
	vec3 nextPos = getNextPosition();
	overlayItems.push_back( gmi );
	OverlayItem *ref = overlayItems.back();
	ref->getText()->getModel().transform.setPosition( nextPos );
	resize();
	return ref;
}


void Overlay::setLayout( vector<OverlayItem*> items )
{
	overlayItems.clear();
	for( vector<OverlayItem*>::iterator it = items.begin(); it != items.end(); ++it )
	{
		OverlayItem *gmi = *it;
		overlayItems.push_back( gmi );
	}
	resize();
}


void Overlay::resize()
{
	float ysize = 0.0f;
	float xmax = 0.0f;

	// resize
	for( vector<OverlayItem*>::iterator it = overlayItems.begin(); it != overlayItems.end(); ++it )
	{
		OverlayItem *gmi = *it;
		if( !gmi->isVisible() ) continue;
		TextItem *ti = gmi->getText();
		Transform &transform = ti->getTransform();
		float x = transform.position.x + transform.scale.x * ti->getWidth();
		if( x > xmax ) xmax = x;
		ysize += ti->getSize() * transform.scale.y;
	}

	// shift everything up one
	for( vector<OverlayItem*>::iterator it = overlayItems.begin(); it != overlayItems.end(); ++it )
	{
		OverlayItem *gmi = *it;
		if( !gmi->isVisible() ) continue;
		TextItem *ti = gmi->getText();
		Transform &transform = ti->getTransform();
		vec3 pos = transform.position;
		vec3 newPos = vec3( pos.x, pos.y + 0.5, pos.z );
		transform.setPosition( newPos );
	}

	dimension.x = xmax;
	dimension.y = ysize;
	scaleMatrix = Transform::getScale( vec3( dimension.x, dimension.y, 1.0f ) );
}


// private
vec3 Overlay::getNextPosition()
{
	if( overlayItems.size() == 0 ) return vec3( 0, -1, 0 );
	vec3 lastPos = vec3( overlayItems.back()->getText()->getModel().transform.position );
	lastPos.y -= 1.0f;
	return lastPos;
}
