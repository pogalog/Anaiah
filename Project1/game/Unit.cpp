/*
 * Unit.cpp
 *
 *  Created on: Mar 9, 2016
 *      Author: pogal
 */

#include "Unit.h"
#include "geom/ProceduralGeom.h"

#include <iostream>

using namespace std;
using namespace glm;

Unit::Unit()
{
	isMoving = false;
	visible = true;
	enabled = true;
	ringModel = geom::createWireCircle( 40 );
	ringModel.getPrimaryMesh().buildVAO();
	teamColor = vec4( 1, 1, 1, 1 );
	animations = vector<Animation*>();
	animations.reserve( 5 );
	for( int i = 0; i < 5; ++i ) animations.push_back( NULL );
}

Unit::Unit( const Unit &unit )
{

}

Unit::~Unit()
{
}

void Unit::drawTeamID( const Camera &camera, const Transform &transform )
{
	for( vector<Mesh>::iterator mit = ringModel.meshes.begin(); mit != ringModel.meshes.end(); ++mit )
	{
		Mesh &mesh = *mit;

		glUseProgram( mesh.getShader()->programID );

		mat4 scaleMatrix = Transform::getScale( vec3( 0.75 ) );
		mat4 transMatrix = Transform::getTranslate( vec3( 0, 0.01, 0 ) );
		mat4 modelviewMatrix = camera.transform.matrix * transform.matrix * transMatrix * scaleMatrix;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

		glLineWidth( 8.0f );
		glUniformMatrix4fv( glGetUniformLocation( mesh.getShader()->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
		vec4 color = enabled ? teamColor : vec4( 0.5, 0.5, 0.5, 1.0 );
		glUniform3f( glGetUniformLocation( mesh.getShader()->programID, "color" ), color.r, color.g, color.b );
		glBindVertexArray( mesh.name );
		glDrawArrays( GL_LINES, 0, mesh.numElements );
		glBindVertexArray( 0 );
		glLineWidth( 1.0f );
	}
}


void Unit::draw( const Camera &camera, bool shaderOverride )
{
	if( !visible ) return;
	updateCoexistTransform();

	vector<GLfloat> &boneMatrices = nodes.front()->getGLMatrix();
	mat4 offsetMatrix = Transform::getRotationY( math_util::PI );

	for( vector<Node*>::iterator nit = nodes.begin(); nit != nodes.end(); ++nit )
	{
		Node* node = *nit;
		node->draw( camera, boneMatrices, shaderOverride, transform.matrix * offsetMatrix );
	}

	if( coexist )
	{
		for( vector<Node*>::iterator nit = nodes.begin(); nit != nodes.end(); ++nit )
		{
			Node* node = *nit;
			node->draw( camera, boneMatrices, shaderOverride, coexistTransform.matrix * offsetMatrix );
		}
	}


	// draw team identifier
	if( !shaderOverride )
	{
		drawTeamID( camera, transform );
		if( coexist ) drawTeamID( camera, coexistTransform );
	}

	drawGhost( camera );
}

void Unit::drawGhost( const Camera &camera )
{
	if( !ghostVisible ) return;
	glBlendFunc( GL_SRC_ALPHA, GL_ONE );
	glEnable( GL_CULL_FACE );
	glCullFace( GL_FRONT );

	vector<GLfloat> &boneMatrices = nodes.front()->getGLMatrix();
	for( vector<Node*>::iterator nit = nodes.begin(); nit != nodes.end(); ++nit )
	{
		Node* node = *nit;
		
		for( vector<Mesh>::iterator it = node->getMeshes().begin(); it != node->getMeshes().end(); ++it )
		{
			Mesh &mesh = *it;
			Shader *shader = mesh.getShader();
			Material *material = mesh.material;

			if( !shader ) continue;
			if( !shader->valid ) continue;

			glUseProgram( shader->programID );

			// compute matrices
			mat4 viewMatrix = camera.transform.matrix;
			mat4 meshMatrix = mesh.transform.matrix;
			mat4 sceneMatrix = transform.matrix;
			mat4 ghostMatrix;
			ghostMatrix = glm::translate( ghostMatrix, ghostPosition );
			mat4 modelMatrix = ghostMatrix * meshMatrix;
			mat4 modelviewMatrix = viewMatrix * modelMatrix;
			mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

			// light?
			vec4 light4 = vec4( 5, 5, 5, 0.0 );
			vec4 L4 = camera.transform.matrix * light4;
			vec3 L3 = vec3( L4 );

			// assign uniform values
			glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
			glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVM" ), 1, GL_FALSE, &modelviewMatrix[0][0] );
			glUniform3fv( glGetUniformLocation( shader->programID, "lightPos" ), 1, &L3[0] );
			glUniformMatrix4fv( glGetUniformLocation( shader->programID, "nodeTransform" ), boneMatrices.size() / 16, GL_FALSE, &boneMatrices[0] );

			glBindVertexArray( mesh.name );
			glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
			glBindVertexArray( 0 );
		}
	}

	glDisable( GL_CULL_FACE );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
}


int Unit::getMovementRange() const
{
	return MV;
}

Range Unit::getAttackRange() const
{
	if( !equipped ) return Range();
	return equipped->getRange();
}

void Unit::setLocation( MapTile *tile )
{
	location->occupant = NULL;
	location = tile;
	
	// update tile set
	for( vector<MapTile*>::iterator it = tiles.begin(); it != tiles.end(); ++it )
	{
		MapTile *t = *it;
		t->occupant = NULL;
	}
	tiles.clear();
	tiles.push_back( tile );
	tile->occupant = this;
	if( size > 1 )
	{
		for( vector<MapTile*>::iterator it = tile->neighbors.begin(); it != tile->neighbors.end(); ++it )
		{
			MapTile *t = *it;
			if( t )
			{
				tiles.push_back( t );
				t->occupant = this;
			}
		}
	}
}


// operators
bool Unit::operator==( const Unit &unit )
{
	return this == &unit;
}


// mutator
void Unit::addAnimation( Animation *animation, AnimationState state )
{
	animations[(int)state] = animation;
	animation->setState( state );
	
	connectAnimation( animation );
}

void Unit::setAnimation( unsigned int index )
{
	if( index >= animations.size() )
	{
		currentAnimation = NULL;
		return;
	}
	currentAnimation = animations.at( index );
}


Node* Unit::getNode( string name )
{
	for( vector<Node*>::iterator it = nodes.begin(); it != nodes.end(); ++it )
	{
		Node *node = *it;
		if( node->getName().compare( name ) == 0 )
		{
			return node;
		}
	}
	return NULL;
}

void Unit::connectAnimation( Animation *animation )
{
	// attach the Animation to the Model (set of Nodes)
	for( vector<AnimationChannel>::iterator it = animation->getChannels().begin(); it != animation->getChannels().end(); ++it )
	{
		AnimationChannel &ac = *it;
		Node *node = getNode( ac.getNodeName() );
		ac.setNode( node );
	}
}
