#include "GameRenderer.h"
#include "fileio/ModelIO.h"
#include "game/GameInstance.h"
#include "model/Model.h"
#include "render/Shader.h"
#include "render/Cubemap.h"
#include "render/RenderUnit.h"
#include "text/FontMap.h"
#include "text/TextItem.h"
#include "ui/Overlay.h"

#include <GL/freeglut.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <iostream>
#include <cstdlib>

// testou
#include "geom/ProceduralGeom.h"

using namespace std;
using namespace glm;

// constants
const vec3 ORIGIN;
const vec3 UP = vec3( 0, 1, 0 );

Color clearColor;

GameRenderer::GameRenderer( GameInstance *game )
	:game(game)
{
}

GameRenderer::~GameRenderer()
{

}

void GameRenderer::init()
{
	glShadeModel( GL_SMOOTH );
	glClearDepth( 1.0f );
	glEnable( GL_DEPTH_TEST );
	glDepthFunc( GL_LESS );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	clearColor = Color( 0.2f, 0.2f, 0.24f, 1.0f );

	Camera &camera = game->camera;
	Lens &lens = camera.lens;
	lens.perspective( 0.785f, (float)win.width / (float)win.height, 0.01f, 7000.0f );
	camera.lookAt( ORIGIN );


	//testShader = Shader( "resource/shader/block.vsh", "resource/shader/block.fsh" );

	//// get information about the block
	//const GLchar *names[] = {"cp[0].color0", "cp[0].color1", "cp[0].specky", "cp[1].color0", "cp[1].color1", "cp[1].specky", "chicken", "egg"};
	//GLuint indices[8];
	//glGetUniformIndices( testShader.programID, 8, names, indices );
	//GLint offset[8];
	//glGetActiveUniformsiv( testShader.programID, 8, indices, GL_UNIFORM_OFFSET, offset );
	//cout << "Offset: " << offset[0] << ", " << offset[1] << ", " << offset[2] << ", " << offset[3] << ", " << offset[4] << ", " << offset[5] << ", " << offset[6] << ", " << offset[7] << endl;

	// fill the buffer
	//const int size = 16;
	//float data[size] = {1.0, 0.0, 0.0, 1.0,   0.0, 1.0, 0.0, 1.0,   0.0, 0.0, 1.0, 1.0,	  -0.5, -0.5, -0.5, 1.0};
	//glGenBuffers( 1, &bufferName );
	//glBindBuffer( GL_UNIFORM_BUFFER, bufferName );
	//glBufferData( GL_UNIFORM_BUFFER, size * sizeof( float ), data, GL_DYNAMIC_DRAW );

	//GLuint blockIndex = glGetUniformBlockIndex( testShader.programID, "Blocky" );
	//GLuint bindingPoint = 1;
	//glUniformBlockBinding( testShader.programID, blockIndex, bindingPoint );
	//glBindBufferBase( GL_UNIFORM_BUFFER, bindingPoint, bufferName );


	// query all uniforms?
	//int numUniforms = -1;
	//glGetProgramiv( testShader.programID, GL_ACTIVE_UNIFORMS, &numUniforms );
	//for( int i = 0; i < numUniforms; ++i )
	//{
	//	int nameLen = -1;
	//	int num = -1;
	//	GLenum type = GL_ZERO;
	//	char name[100];
	//	glGetActiveUniform( testShader.programID, GLuint( i ), sizeof( name ) - 1, &nameLen, &num, &type, name );
	//	GLint loc = glGetUniformLocation( testShader.programID, name );
	//	cout << name << " " << type << " " << loc << endl;
	//}

	//quad = geom::createCube();
	//quad.getPrimaryMesh().buildVAO();
}

void GameRenderer::reshape( GLint width, GLint height )
{
	windowWidth = width;
	windowHeight = height;

	for( list<RenderUnit*>::iterator ruit = units.begin(); ruit != units.end(); ++ruit )
	{
		RenderUnit *ru = *ruit;
		ru->reshape( width, height );
	}
}


void GameRenderer::display()
{
	if( game->levelMap == NULL ) return;

	Camera &camera = game->camera;
	LevelMap *map = game->levelMap;
	MapGrid &grid = map->grid;

	glViewport( 0, 0, win.width, win.height );
	glClearColor( 0, 0, 0, 1 );
	//glClearColor( clearColor( 0 ), clearColor( 1 ), clearColor( 2 ), clearColor( 3 ) );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

	camera.update();
	camera.lens.perspective();

	// update unit movement
	grid.updateUnitPaths();
	
	for( list<RenderUnit*>::iterator ruit = units.begin(); ruit != units.end(); ++ruit )
	{
		RenderUnit *ru = *ruit;

		// set up rendering parameters
		cullBackFaces( ru->cullBackFaces );
		useDepthTest( ru->depthTest );
		if( ru->depthTest ) useDepthFunc( ru->depthFunc );
		useBlending( ru->blend );
		if( ru->blend ) useBlendFunc( ru->blendSource, ru->blendDest );

		ru->display( camera );
	}
	
	for( list<Model*>::iterator mit = map->debugModels.begin(); mit != map->debugModels.end(); ++mit )
	{
		Model *model = *mit;
		model->draw( camera );
	}

	// testou
	//time += 0.01f;
	//const int size = 4;
	//float data[size] = {-time, -time, -time, 1.0};
	//if( time > 1.0 ) time = 0.0f;
	////glBindBuffer( GL_UNIFORM_BUFFER, bufferName );
	////glBufferSubData( GL_UNIFORM_BUFFER, 12 * sizeof( float ), 4 * sizeof( float ), data );
	////glBufferSubData( GL_UNIFORM_BUFFER, 4*4, 4 * sizeof( float ), &data[4] );

	//Mesh &mesh = quad.getPrimaryMesh();
	//glUseProgram( testShader.programID );
	//mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * camera.transform.matrix;
	//GLint loc = glGetUniformLocation( testShader.programID, "pvm" );
	//glUniformMatrix4fv( loc, 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
	//glBindVertexArray( mesh.name );
	//glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
	//glBindVertexArray( 0 );

	glutSwapBuffers();
}


/**
* Steps through all animated assets for props.
*/
void GameRenderer::animateProps( float time )
{

}


/**
 * Steps through all animated assets for units.
*/
void GameRenderer::animateUnits( float time )
{
	for( list<Unit*>::iterator uit = game->levelMap->units.begin(); uit != game->levelMap->units.end(); ++uit )
	{
		Unit *unit = *uit;
		Animation *anim = unit->currentAnimation;
		Node *model = unit->nodes.front();
		if( model == NULL ) continue;

		float t = anim != NULL ? anim->getElapsedTime() : 0.0f;
		t = anim != NULL ? mod( time, anim->getEndTime() ) : 0.0f;
		model->traverseHierarchy( anim, t, mat4() );
		model->constrcutGLMatixArray( unit->nodes );
	}
	
}

void GameRenderer::animateUnit( Unit *unit, float time )
{
	Animation *anim = unit->currentAnimation;
	Node *model = unit->nodes.front();
	if( model == NULL ) return;

	model->traverseHierarchy( anim, time, mat4() );
	model->constrcutGLMatixArray( unit->nodes );
}


void GameRenderer::cullBackFaces( bool cull )
{
	if( this->cull != cull )
	{
		if( cull )
		{
			glEnable( GL_CULL_FACE );
			glCullFace( GL_BACK );
		}
		else
		{
			glDisable( GL_CULL_FACE );
		}
	}
	
	this->cull = cull;
}

void GameRenderer::useDepthTest( bool test )
{
	if( depthTest != test )
	{
		if( test )
		{
			glEnable( GL_DEPTH_TEST );
		}
		else
		{
			glDisable( GL_DEPTH_TEST );
		}
	}
	depthTest = test;
}


void GameRenderer::writeDepthMask( bool write )
{
	if( depthMaskWrite != write )
	{
		if( write )
		{
			glDepthMask( GL_TRUE );
		}
		else
		{
			glDepthMask( GL_FALSE );
		}
	}
	depthMaskWrite = write;
}

void GameRenderer::useBlending( bool blend )
{
	if( this->blend != blend )
	{
		if( blend )
		{
			glEnable( GL_BLEND );
		}
		else
		{
			glDisable( GL_BLEND );
		}
	}
	this->blend = blend;
}

void GameRenderer::useDepthFunc( GLenum func )
{
	if( depthFunc != func )
	{
		glDepthFunc( func );
	}
	depthFunc = func;
}

void GameRenderer::useBlendFunc( GLenum source, GLenum dest )
{
	if( blendSource != source || blendDest != dest )
	{
		glBlendFunc( source, dest );
	}
	blendSource = source;
	blendDest = dest;
}

void GameRenderer::addRenderUnit( RenderUnit *ru )
{
	units.push_back( ru );
	ru->init( windowWidth, windowHeight );
}
