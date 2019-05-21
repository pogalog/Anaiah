#include "RenderUnit.h"
#include "game/Unit.h"
#include "render/Cubemap.h"
#include "ui/GameMenu.h"
#include "ui/Overlay.h"

#include <glm/glm.hpp>
#include <iostream>

using namespace std;
using namespace glm;

RenderUnit::RenderUnit( string name )
{
	this->name = name;
	cullBackFaces = false;
	depthTest = true;
	depthMaskWrite = true;
	blend = true;
	useDefaultFBO = true;

	depthFunc = GL_LEQUAL;
	blendSource = GL_SRC_ALPHA;
	blendDest = GL_ONE_MINUS_SRC_ALPHA;
}

RenderUnit::~RenderUnit()
{

}



void RenderUnit::init( GLint width, GLint height )
{
	windowWidth = width;
	windowHeight = height;
}

void RenderUnit::reshape( GLint width, GLint height )
{
	windowWidth = width;
	windowHeight = height;
}

void RenderUnit::display( const Camera &camera )
{
	if( useDefaultFBO )
	{
		glBindFramebuffer( GL_FRAMEBUFFER, 0 );
		glViewport( 0, 0, windowWidth, windowHeight );
	}
	else
	{
		output->bind();
	}

	glClearColor( clearColor.r, clearColor.g, clearColor.b, clearColor.a );

	if( clearBufferBits )
	{
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	}

	// draw cubemap
	if( cubemap )
	{
		glDepthMask( GL_FALSE );
		cubemap->draw( camera );
		glDepthMask( GL_TRUE );
	}

	if( staticShader )
	{
		staticShader->useProgram();
		staticShader->assignUniformValues();
	}

	for( list<Model*>::iterator mit = staticModels.begin(); mit != staticModels.end(); ++mit )
	{
		Model *model = *mit;
		model->draw( camera, staticShader != NULL );
	}

	if( animatedShader )
	{
		animatedShader->useProgram();
		animatedShader->assignUniformValues();
	}

	mat4 offsetMatrix = Transform::getRotationY( math_util::PI );
	for( list<Node*>::iterator nit = animatedModels.begin(); nit != animatedModels.end(); ++nit )
	{
		Node *node = *nit;
		vector<GLfloat> &boneMatrices = node->getGLMatrix();
		node->draw( camera, boneMatrices, animatedShader != NULL );
	}

	for( list<Unit*>::iterator uit = units.begin(); uit != units.end(); ++uit )
	{
		Unit *unit = *uit;
		unit->draw( camera, animatedShader != NULL );
	}

	// draw text
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	for( list<TextItem*>::iterator it = textItems.begin(); it != textItems.end(); ++it )
	{
		TextItem *ti = *it;
		ti->draw( camera );
	}

	glDepthFunc( GL_LEQUAL );

	// draw overlay
	for( list<Overlay*>::iterator oit = overlays.begin(); oit != overlays.end(); ++oit )
	{
		Overlay *overlay = *oit;
		overlay->draw( camera );
	}

	// draw menu
	for( list<GameMenu*>::iterator gmit = menus.begin(); gmit != menus.end(); ++gmit )
	{
		GameMenu *menu = *gmit;
		menu->draw( camera );
	}
}