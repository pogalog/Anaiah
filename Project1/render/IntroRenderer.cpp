#include "IntroRenderer.h"

#include <GL/glew.h>
#include <GL/freeglut.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <iostream>

using namespace std;
using namespace glm;

IntroRenderer::IntroRenderer( int width, int height )
{
	win.width = width;
	win.height = height;
	win.xpix = 1.0f / (float)width;
	win.ypix = 1.0f / (float)height;

	init();
}


IntroRenderer::~IntroRenderer()
{

}


void IntroRenderer::init()
{
	clearColor = vec4( 0.9, 0.9, 0.8, 1.0 );
	glShadeModel( GL_SMOOTH );
	glClearDepth( 1.0f );
	glEnable( GL_DEPTH_TEST );
	glDepthFunc( GL_LESS );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
}

void IntroRenderer::checkNetwork( lua_State *L )
{
	lua_getglobal( L, "Network" );
	lua_getfield( L, -1, "checkNetwork" );
	lua_call( L, 0, 0 );
}

void IntroRenderer::display()
{
	glViewport( 0, 0, win.width, win.height );
	glClearColor( clearColor.r, clearColor.g, clearColor.g, clearColor.a );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );


	// draw text
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	glDepthFunc( GL_ALWAYS );
	for( vector<TextItem*>::iterator it = textItems.begin(); it != textItems.end(); ++it )
	{
		TextItem *ti = *it;
		ti->draw( camera );
	}
	glDepthFunc( GL_LEQUAL );

	// draw menu
	for( vector<GameMenu*>::iterator gmit = menus.begin(); gmit != menus.end(); ++gmit )
	{
		GameMenu *menu = *gmit;
		menu->draw( camera );
	}

	// draw models
	for( vector<Model*>::iterator it = models.begin(); it != models.end(); ++it )
	{
		Model *model = *it;
		
		// render all Mesh objects
		for( vector<Mesh>::iterator it = model->meshes.begin(); it != model->meshes.end(); ++it )
		{
			Mesh &mesh = *it;
			Shader *shader = mesh.getShader();

			if( !shader || !shader->valid ) continue;

			glUseProgram( shader->programID );

			// compute matrices
			mat4 modelviewMatrix = camera.transform.matrix;
			mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

			// assign uniform values
			glUniform1f( glGetUniformLocation( shader->programID, "time" ), time );
			glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );

			glBindVertexArray( mesh.name );
			glDrawArrays( mesh.drawMode, 0, mesh.numElements );
			glBindVertexArray( 0 );
		}
	}

	glutSwapBuffers();
}


TextItem* IntroRenderer::createTextItem( FontMap *map, string text )
{
	if( map == NULL ) return NULL;

	TextItem *ti = new TextItem( map, text );
	textItems.push_back( ti );
	return ti;
}