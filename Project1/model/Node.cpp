#include "Node.h"
#include "game/Camera.h"
#include "render/Error.h"

#include <vector>
#include <list>
#include <iostream>

using namespace std;
using namespace glm;

Node::Node()
{
	visible = true;
	globalInverseTransform = mat4( 1.0 );
	offset = mat4( 1.0 );
}

Node::~Node()
{

}


glm::mat4 Node::getFinalTransform() const
{
	return glm::mat4( 1.0 );
}



void Node::traverseHierarchy( Animation *anim, float time, mat4 parentTransform )
{
	mat4 nodeTransform( transform.matrix );
	if( anim != NULL )
	{
		AnimationChannel *channel = anim->getChannel( this );
		if( channel != NULL )
		{
			nodeTransform = channel->computeTransform( time );
		}
	}

	mat4 globalTransform = parentTransform * nodeTransform;
	finalTransform = globalTransform * offset;

	// spread the love to the kids
	for( vector<Node*>::iterator it = children.begin(); it != children.end(); ++it )
	{
		Node *child = *it;
		child->traverseHierarchy( anim, time, globalTransform );
	}
}

void Node::constrcutGLMatixArray( const vector<Node*> &nodes )
{
	glMatrices.clear();
	for( unsigned int i = 0; i < nodes.size(); ++i )
	{
		Node *n = nodes.at( i );
		mat4 &m = n->getFinalTransform();
		for( int j = 0; j < 4; ++j )
		{
			for( int k = 0; k < 4; ++k )
			{
				glMatrices.push_back( m[j][k] );
			}
		}
	}
}


void Node::draw( const Camera &camera, const vector<GLfloat> &boneMatrices, bool shaderOverride, mat4 sceneMatrix )
{
	if( !visible ) return;

	// render all Mesh objects
	for( vector<Mesh>::iterator it = meshes.begin(); it != meshes.end(); ++it )
	{
		Mesh &mesh = *it;
		Shader *shader = mesh.getShader();
		Material *material = mesh.material;

		if( !mesh.visible ) continue;
		if( !shaderOverride && (!shader || !shader->valid) ) continue;
		if( !shaderOverride ) glUseProgram( shader->programID );

		// bind texture
		int activeTexture = 0;
		if( material->normalMap.name > 0 )
		{
			int loc = glGetUniformLocation( shader->programID, "normalMap" );
			if( loc > -1 )
			{
				glActiveTexture( GL_TEXTURE0 + activeTexture );
				glBindTexture( GL_TEXTURE_2D, material->normalMap.name );
				glUniform1i( loc, activeTexture );
				++activeTexture;
			}
		}

		if( material->colorMap.name > 0 )
		{
			int loc = glGetUniformLocation( shader->programID, "colorMap" );
			if( loc > -1 )
			{
				glActiveTexture( GL_TEXTURE0 + activeTexture );
				glBindTexture( GL_TEXTURE_2D, material->colorMap.name );
				glUniform1i( loc, activeTexture );
				++activeTexture;
			}
		}

		for( GLuint i = 0; i < shader->uniforms.size(); ++i )
		{
			IUniform *uv = shader->uniforms.at( i );
			uv->set( shader );
		}

		// compute matrices
		mat4 viewMatrix = camera.transform.matrix;
		mat4 meshMatrix = mesh.transform.matrix;
		mat4 modelMatrix = sceneMatrix * transform.matrix * meshMatrix;
		mat4 modelviewMatrix = viewMatrix * modelMatrix;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

		// light?
		vec4 light4 = vec4( 0, -1000, -2000, 0 );
		vec4 L4 = camera.transform.matrix * light4;
		vec3 L3 = vec3( L4 );

		GLint lsLoc = glGetUniformLocation( shader->programID, "lighty.position[0]" );
		if( lsLoc > -1 )
		{
			gl::glError( "begin" );
			vec3 *stuff = new vec3[2];
			stuff[0] = vec3( 1, 1, 1 );
			stuff[1] = vec3( 1.3, 0, 1.1 );
			glUniform3fv( lsLoc, 2, &stuff[0][0] );
			gl::glError( "end" );
		}

		// assign uniform values
		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "modelMatrix" ), 1, GL_FALSE, &modelMatrix[0][0] );
		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "viewMatrix" ), 1, GL_FALSE, &viewMatrix[0][0] );
		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "projectionMatrix" ), 1, GL_FALSE, &camera.lens.projectionMatrix[0][0] );
		glUniform3fv( glGetUniformLocation( shader->programID, "lightPos" ), 1, &L3[0] );
		glUniformMatrix4fv( glGetUniformLocation( shader->programID, "nodeTransform" ), boneMatrices.size() / 16, GL_FALSE, &boneMatrices[0] );

		glBindVertexArray( mesh.name );
		glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
		glBindVertexArray( 0 );
	}
}


void Node::setParent( Node *parent )
{
	this->parent = parent;
	if( parent != NULL )
	{
		parent->addChild( this );
	}
}
