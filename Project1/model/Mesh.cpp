/*
 * Mesh.cpp
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#include <cstdio>
#include <iostream>
#include <glm/glm.hpp>

#include "Mesh.h"
#include "Material.h"
#include "lua/lua_util.h"


using namespace std;
using namespace glm;

Mesh::Mesh()
: visible(true), drawMode(0), name(0), positionBufferName(-1), normalBufferName(-1), uvBufferName(-1), colorBufferName(-1),
  numPositions(0), numTexcoords(0), numNormals(0), numColors(0), numElements(0), shader(NULL), hasBones(false), material(NULL)
{
}

Mesh::Mesh( int numVertices )
	: visible( true ), drawMode( 0 ), name( 0 ), positionBufferName( -1 ), normalBufferName( -1 ), uvBufferName( -1 ), colorBufferName( -1 ),
	numPositions( numVertices ), numTexcoords( numVertices ), numNormals( numVertices ), numColors( 0 ),
	numElements( numVertices ), shader( NULL ), hasBones( false ), material( NULL )
{
}

// copy ctor
Mesh::Mesh( const Mesh &mesh )
{
	hasBones = mesh.hasBones;
	visible = mesh.visible;
	numElements = mesh.numElements;
	numNormals = mesh.numNormals;
	numPositions = mesh.numPositions;
	numTexcoords = mesh.numTexcoords;
	numColors = mesh.numColors;
	positionBuffer = mesh.positionBuffer;
	normalBuffer = mesh.normalBuffer;
	uvBuffer = mesh.uvBuffer;
	colorBuffer = mesh.colorBuffer;
	elementBuffer = mesh.elementBuffer;
	transform = mesh.transform;
	material = mesh.material;
	name = mesh.name;
	positionBufferName = mesh.positionBufferName;
	normalBufferName = mesh.normalBufferName;
	uvBufferName = mesh.uvBufferName;
	boneIDBufferName = mesh.boneIDBufferName;
	boneWeightBufferName = mesh.boneWeightBufferName;
	colorBufferName = mesh.colorBufferName;
	shader = mesh.shader;
	transform = mesh.transform;
	drawMode = mesh.drawMode;
}

Mesh::~Mesh()
{
	// do not destroy these pointers, they are not owned by Mesh
	material = NULL;
	shader = NULL;
}


// operators
//Mesh& Mesh::operator=( const Mesh &mesh )
//{
//	cout << "(Mesh) Copy assignment operator" << endl;
//	if( this == &mesh )
//	{
//		cout << "Self assignment detected. You fool!" << endl;
//
//	}
//	return *this;
//}

//Mesh& Mesh::operator=( Mesh mesh )
//{
//	cout << "(Mesh) Copy assignment operator (RHS by value)" << endl;
//	return *this;
//}

//Mesh Mesh::operator=( Mesh mesh )
//{
//	cout << "(Mesh) Copy assignment (RHS by value, LHS by value)" << endl;
//	return *this;
//}

GLuint Mesh::buildVAO()
{
    // Create a vertex array object (VAO) to cache model parameters
    glGenVertexArrays( 1, &name );
    glBindVertexArray( name );
    
    // Create a vertex buffer object (VBO) to store positions
    glGenBuffers( 1, &positionBufferName );
    glBindBuffer( GL_ARRAY_BUFFER, positionBufferName );
    
    // Allocate and load position data into the VBO
    glBufferData( GL_ARRAY_BUFFER, 3 * sizeof( GLfloat ) * numPositions, &positionBuffer[0], GL_STATIC_DRAW );
    
    // Enable the position attribute for this VAO
    glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_POSITION );
    glVertexAttribPointer( (GLuint)VERTEX_ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 0, NULL );
    
    if( numNormals > 0 )
    {
        glGenBuffers( 1, &normalBufferName );
        glBindBuffer( GL_ARRAY_BUFFER, normalBufferName );
        glBufferData( GL_ARRAY_BUFFER, 3 * sizeof( GLfloat ) * numNormals, &normalBuffer[0], GL_STATIC_DRAW );
        glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_NORMAL );
        glVertexAttribPointer( (GLuint)VERTEX_ATTRIB_NORMAL, 3, GL_FLOAT, GL_TRUE, 0, NULL );
    }
    
    if( numTexcoords > 0 )
    {
        glGenBuffers( 1, &uvBufferName );
        glBindBuffer( GL_ARRAY_BUFFER, uvBufferName );
        glBufferData( GL_ARRAY_BUFFER, 2 * sizeof( GLfloat ) * numTexcoords, &uvBuffer[0], GL_STATIC_DRAW );
        glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_TEXCOORD0 );
        glVertexAttribPointer( (GLuint)VERTEX_ATTRIB_TEXCOORD0, 2, GL_FLOAT, GL_TRUE, 0, NULL );
    }

	if( numColors > 0 )
	{
		glGenBuffers( 1, &colorBufferName );
		glBindBuffer( GL_ARRAY_BUFFER, colorBufferName );
		glBufferData( GL_ARRAY_BUFFER, 4 * sizeof( GLfloat ) * numColors, &colorBuffer[0], GL_STATIC_DRAW );
		glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_COLOR );
		glVertexAttribPointer( (GLuint)VERTEX_ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, 0, NULL );
	}

	if( hasBones )
	{
		glGenBuffers( 1, &boneIDBufferName );
		glBindBuffer( GL_ARRAY_BUFFER, boneIDBufferName );
		glBufferData( GL_ARRAY_BUFFER, 4 * sizeof( GLshort ) * numPositions, &boneIDs[0], GL_STATIC_DRAW );
		glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_BONE_ID );
		glVertexAttribIPointer( (GLuint)VERTEX_ATTRIB_BONE_ID, 4, GL_SHORT, 0, NULL );

		glGenBuffers( 1, &boneWeightBufferName );
		glBindBuffer( GL_ARRAY_BUFFER, boneWeightBufferName );
		glBufferData( GL_ARRAY_BUFFER, 4 * sizeof( GLfloat ) * numPositions, &boneWeights[0], GL_STATIC_DRAW );
		glEnableVertexAttribArray( (GLuint)VERTEX_ATTRIB_BONE_WEIGHT );
		glVertexAttribPointer( (GLuint)VERTEX_ATTRIB_BONE_WEIGHT, 4, GL_FLOAT, GL_FALSE, 0, NULL );
	}

    GLuint elementBufferName;

    // Create a VBO to vertex array elements
    // This also attaches the element array buffer to the VAO
    glGenBuffers( 1, &elementBufferName );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, elementBufferName );
    
    // Allocate and load vertex array element data into VBO
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, numElements * sizeof( GLuint ), &elementBuffer[0], GL_STATIC_DRAW );
    
    return name;
}

void Mesh::updatePositionData( GLfloat *v )
{
	for( int i = 0; i < numPositions; i++ )
	{
		positionBuffer[i] = v[i];
	}
}
void Mesh::updateUVData( GLfloat *vt )
{
	for( int i = 0; i < numTexcoords; i++ )
	{
		uvBuffer[i] = vt[i];
	}
}
void Mesh::updateNormalData( GLfloat *vn )
{
	for( int i = 0; i < numNormals; i++ )
	{
		normalBuffer[i] = vn[i];
	}
}

bool Mesh::insertBoneWeight( int vertexID, int boneID, float weight )
{
	int i = 4 * vertexID;
	for( int j = 0; j < 4; ++j )
	{
		if( boneIDs[i + j] < 0 )
		{
			boneIDs[i + j] = boneID;
			boneWeights[i + j] = weight;
			return true;
		}
	}
	return false;
}

void Mesh::initializeBoneArrays()
{
	int num = 4 * numPositions;
	boneWeights.reserve( num );
	boneIDs.reserve( num );
	for( int i = 0; i < num; ++i )
	{
		boneWeights.push_back( 0 );
		boneIDs.push_back( -1 );
	}
	
}

void Mesh::copyUniformValues()
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform *iuv = *it;
		if( shader )
		{
			IUniform *isu = iuv->linked;
			copyUniform( iuv, isu );
		}
	}
}

void Mesh::copyUniform( IUniform *meshUniform, IUniform *shaderUniform )
{
	if( shaderUniform == NULL ) return;
	switch( meshUniform->getType() )
	{
		case SAMPLER2D_TYPE:
		{
			Uniform<GLuint> *uv = (Uniform<GLuint>*)meshUniform;
			Uniform<GLuint> *su = (Uniform<GLuint>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case INT_TYPE:
		{
			Uniform<int> *uv = (Uniform<int>*)meshUniform;
			Uniform<int> *su = (Uniform<int>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case FLOAT_TYPE:
		{
			Uniform<float> *uv = (Uniform<float>*)meshUniform;
			Uniform<float> *su = (Uniform<float>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case VEC2_TYPE:
		{
			Uniform<vec2> *uv = (Uniform<vec2>*)meshUniform;
			Uniform<vec2> *su = (Uniform<vec2>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case VEC3_TYPE:
		{
			Uniform<vec3> *uv = (Uniform<vec3>*)meshUniform;
			Uniform<vec3> *su = (Uniform<vec3>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case VEC4_TYPE:
		{
			Uniform<vec4> *uv = (Uniform<vec4>*)meshUniform;
			Uniform<vec4> *su = (Uniform<vec4>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case MAT3_TYPE:
		{
			Uniform<mat3> *uv = (Uniform<mat3>*)meshUniform;
			Uniform<mat3> *su = (Uniform<mat3>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
		case MAT4_TYPE:
		{
			Uniform<mat4> *uv = (Uniform<mat4>*)meshUniform;
			Uniform<mat4> *su = (Uniform<mat4>*)shaderUniform;
			su->setData( uv->data );
			break;
		}
	}
}

void Mesh::setShader( Shader *shader )
{
	this->shader = shader;
	if( shader == NULL ) return;

	// search for pointers to all stored uniform variables
	linkUniforms();
}

void Mesh::linkUniform( IUniform *meshUniform )
{
	meshUniform->linked = shader->getUniform( meshUniform->getName() );
}

void Mesh::linkUniforms()
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform *uniform = *it;
		linkUniform( uniform );
	}
}

IUniform* Mesh::getUniform( string name )
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform *uv = *it;
		if( name.compare( uv->getName() ) == 0 ) return uv;
	}
}

void Mesh::setIntUniform( string name, int data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<int>*)iu)->setData( data );
			return;
		}
	}
	Uniform<int> *u = new Uniform<int>( name, INT_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setFloatUniform( string name, float data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<float>*)iu)->setData( data );
			return;
		}
	}
	Uniform<float> *u = new Uniform<float>( name, FLOAT_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setVec2Uniform( string name, vec2 data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<vec2>*)iu)->setData( data );
			return;
		}
	}
	Uniform<vec2> *u = new Uniform<vec2>( name, VEC2_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setVec3Uniform( string name, vec3 data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<vec3>*)iu)->setData( data );
			return;
		}
	}
	Uniform<vec3> *u = new Uniform<vec3>( name, VEC3_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setVec4Uniform( string name, vec4 data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<vec4>*)iu)->setData( data );
			return;
		}
	}
	Uniform<vec4> *u = new Uniform<vec4>( name, VEC4_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setMat3Uniform( string name, mat3 data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<mat3>*)iu)->setData( data );
			return;
		}
	}
	Uniform<mat3> *u = new Uniform<mat3>( name, MAT3_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setMat4Uniform( string name, mat4 data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<mat4>*)iu)->setData( data );
			return;
		}
	}
	Uniform<mat4> *u = new Uniform<mat4>( name, MAT4_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}

void Mesh::setSampler2DUniform( string name, GLuint data )
{
	for( vector<IUniform*>::iterator uit = uniforms.begin(); uit != uniforms.end(); ++uit )
	{
		IUniform *iu = *uit;
		if( iu->getName().compare( name ) == 0 )
		{
			((Uniform<GLuint>*)iu)->setData( data );
			return;
		}
	}
	Uniform<GLuint> *u = new Uniform<GLuint>( name, SAMPLER2D_TYPE );
	u->setData( data );
	uniforms.push_back( u );

	if( shader == NULL ) return;
	linkUniform( u );
}
