#include "Uniform.h"
#include "render/Shader.h"

#include <glm/glm.hpp>
#include <iostream>
#include <array>

using namespace std;
using namespace glm;



//template <typename DataType>
//bool Uniform<DataType>::set( int program )
//{
//	return false;
//}


template <> bool Uniform<GLuint>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform1i( location, data );
	return true;
}

template <> bool Uniform<int>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform1i( location, data );

	return true;
}

template <> bool Uniform<float>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform1f( location, data );

	return true;
}

template <> bool Uniform<vec2>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform2fv( location, 1, &data[0] );

	return true;
}

template <> bool Uniform<vec3>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform3fv( location, 1, &data[0] );

	return true;
}

template <> bool Uniform<vec4>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniform4fv( location, 1, &data[0] );

	return true;
}

template <> bool Uniform<mat3>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniformMatrix3fv( location, 1, GL_FALSE, &data[0][0] );

	return true;
}

template <> bool Uniform<mat4>::set( Shader *shader )
{
	GLuint program = shader->programID;
	int location = getLocation( program );
	if( location == -1 ) return false;

	glUniformMatrix4fv( location, 1, GL_FALSE, &data[0][0] );

	return true;
}



// BlockUniform
template <> bool BlockUniform<int>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<float>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<vec2>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<vec3>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<vec4>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<mat3>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}

template <> bool BlockUniform<mat4>::set( Shader *shader )
{
	if( !block ) return false;

	UniformBuffer *buffer = block->buffer;
	if( !buffer ) return false;
	buffer->setData( bufferOffset, data );
	return true;
}


// UniformBuffer
UniformBuffer::UniformBuffer( GLuint size, GLuint bindingPoint )
{
	this->size = size;
	this->bindingPoint = bindingPoint;
	data = new float[size / 4];
	glGenBuffers( 1, &name );
	glBindBuffer( GL_UNIFORM_BUFFER, name );
	glBufferData( GL_UNIFORM_BUFFER, size, data, GL_DYNAMIC_DRAW );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
}

UniformBuffer::~UniformBuffer()
{
	delete[] data;
}

void UniformBuffer::bindBlock( UniformBlock *block )
{
	if( block == NULL ) return;

	block->buffer = this;
	glBindBuffer( GL_UNIFORM_BUFFER, name );
	glUniformBlockBinding( block->shader->programID, block->blockIndex, bindingPoint );
	glBindBufferBase( GL_UNIFORM_BUFFER, bindingPoint, name );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
}

void UniformBuffer::setData( GLuint offset, int value )
{
	if( offset + 4 > size ) return;

	int *idata = (int*)data;
	idata[offset / 4] = value;
	setDataBounds( offset, 4 );
}

void UniformBuffer::setData( GLuint offset, float value )
{
	if( offset + 4 > size ) return;

	data[offset / 4] = value;
	setDataBounds( offset, 4 );
}

void UniformBuffer::setData( GLuint offset, vec2 value )
{
	if( offset + 8 > size ) return;

	int off = offset / 4;
	data[off] = value.x;
	data[off + 1] = value.y;
	setDataBounds( offset, 8 );
}

void UniformBuffer::setData( GLuint offset, vec3 value )
{
	if( offset + 12 > size ) return;

	int off = offset / 4;
	data[off] = value.x;
	data[off + 1] = value.y;
	data[off + 2] = value.z;
	setDataBounds( offset, 12 );
}

void UniformBuffer::setData( GLuint offset, vec4 value )
{
	if( offset + 16 > size ) return;

	int off = offset / 4;
	data[off] = value.x;
	data[off + 1] = value.y;
	data[off + 2] = value.z;
	data[off + 3] = value.w;
	setDataBounds( offset, 16 );
}

void UniformBuffer::setData( GLuint offset, mat3 value )
{
	if( offset + 36 > size ) return;

	int off = offset / 4;
	for( int i = 0; i < 9; ++i )
	{
		data[off + i] = value[i / 3][i % 3];
	}
	setDataBounds( offset, 36 );
}

void UniformBuffer::setData( GLuint offset, mat4 value )
{
	if( offset + 64 > size ) return;

	int off = offset / 4;
	for( int i = 0; i < 16; ++i )
	{
		data[off + i] = value[i / 4][i % 4];
	}
	setDataBounds( offset, 64 );
}

void UniformBuffer::commitBuffer()
{
	if( !updated ) return;
	glBindBuffer( GL_UNIFORM_BUFFER, name );
	glBufferSubData( GL_UNIFORM_BUFFER, 4 * start, 4 * (end - start), &data[start] );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
	start = 10000000;
	end = 0;
	updated = false;
}

void UniformBuffer::setDataBounds( GLuint offset, GLuint size )
{
	updated = true;
	start = glm::min( offset/4, start );
	end = glm::max( (offset + size)/4, end );
}


// UniformBlock
UniformBlock::UniformBlock( string name, Shader *shader )
{
	this->name = name;
	this->shader = shader;
	this->program = shader->programID;

	blockIndex = glGetUniformBlockIndex( shader->programID, name.c_str() );
}

IUniform* UniformBlock::addUniform( string name, string type )
{
	IUniform *u = NULL;
	if( type.compare( "int" ) == 0 )
	{
		u = new BlockUniform<int>( name, INT_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "float" ) == 0 )
	{
		u = new BlockUniform<float>( name, FLOAT_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec2" ) == 0 )
	{
		u = new BlockUniform<vec2>( name, VEC2_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec3" ) == 0 )
	{
		u = new BlockUniform<vec3>( name, VEC3_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec4" ) == 0 )
	{
		u = new BlockUniform<vec4>( name, VEC4_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "mat3" ) == 0 )
	{
		u = new BlockUniform<mat3>( name, MAT3_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "mat4" ) == 0 )
	{
		u = new BlockUniform<mat4>( name, MAT4_TYPE );
		uniforms.push_back( u );
		return u;
	}
	return u;
}

void UniformBlock::setLocations()
{
	GLchar **names = new GLchar*[uniforms.size()];
	for( unsigned int i = 0; i < uniforms.size(); ++i )
	{
		string &s_name = uniforms.at( i )->getName();
		names[i] = new GLchar[16];
		memcpy( names[i], s_name.c_str(), s_name.size()+1 ); // include /0 terminator
	}
	GLuint *indices = new GLuint[uniforms.size()];
	glGetUniformIndices( program, uniforms.size(), (const GLchar**)names, indices );
	GLint *offsets = new GLint[uniforms.size()];
	glGetActiveUniformsiv( program, uniforms.size(), indices, GL_UNIFORM_OFFSET, offsets );
	for( unsigned int i = 0; i < uniforms.size(); ++i )
	{
		cout << names[i] << ": " << offsets[i] << endl;
		uniforms.at( i )->setOffset( offsets[i] );
	}

	delete[] indices;
	delete[] offsets;
}

void UniformBlock::assignUniformValues()
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform* uv = *it;
		uv->set( shader );
	}
}

// private
template<typename DataType>
int Uniform<DataType>::getLocation( int program )
{
	return glGetUniformLocation( program, name.c_str() );
}
