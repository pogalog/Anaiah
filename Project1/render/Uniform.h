#pragma once

#include <GL/glew.h>
#include <string>
#include <vector>
#include <glm/glm.hpp>

class Shader;
class UniformBlock;

enum UniformType
{
	INT_TYPE = 0,
	FLOAT_TYPE = 1,
	VEC2_TYPE = 2,
	VEC3_TYPE = 3,
	VEC4_TYPE = 4,
	MAT3_TYPE = 5,
	MAT4_TYPE = 6,
	SAMPLER2D_TYPE = 7
};

class IUniform
{
public:
	virtual bool set( Shader *shader ) = 0;
	virtual void setBlock( UniformBlock *block ) = 0;
	virtual std::string getName() = 0;
	virtual UniformType getType() = 0;
	virtual void setOffset( GLint offset ) = 0;
	IUniform *linked;
};


template <typename DataType>
class Uniform : public IUniform
{
public:

	Uniform( std::string name, UniformType type )
	{
		this->name = name;
		this->type = type;
	}

	bool set( Shader *shader );
	void setBlock( UniformBlock *block ) {}
	void setData( DataType data ) { this->data = data; }
	void setOffset( GLint offset ) {}
	std::string getName() { return name; }
	UniformType getType() { return type; }

	DataType data;
	std::string name;
	UniformType type;


private:
	int getLocation( int program );
	
};


class UniformBuffer
{
public:
	UniformBuffer( GLuint size, GLuint bindingPoint );
	~UniformBuffer();

	void bindBlock( UniformBlock *block );

	void setData( GLuint offset, int value );
	void setData( GLuint offset, float value );
	void setData( GLuint offset, glm::vec2 value );
	void setData( GLuint offset, glm::vec3 value );
	void setData( GLuint offset, glm::vec4 value );
	void setData( GLuint offset, glm::mat3 value );
	void setData( GLuint offset, glm::mat4 value );
	void commitBuffer();

	GLuint size, bindingPoint, name;
	GLuint start, end;
	bool updated;
	float *data;

private:
	void setDataBounds( GLuint offset, GLuint size );
};




class UniformBlock
{
public:
	UniformBlock( std::string name, Shader *shader );

	IUniform* addUniform( std::string name, std::string type );
	void setLocations();
	void assignUniformValues();

	std::string name;
	std::vector<IUniform*> uniforms;
	GLuint program, blockIndex;
	UniformBuffer *buffer;
	Shader *shader;
};

template <typename DataType>
class BlockUniform : public IUniform
{
public:

	BlockUniform( std::string name, UniformType type )
	{
		this->name = name;
		this->type = type;
	}

	bool set( Shader *shader );
	void setBlock( UniformBlock *block ) { this->block = block; }
	void setData( DataType data ) { this->data = data; }
	void setOffset( GLint offset ) { bufferOffset = offset; }
	std::string getName() { return name; }
	UniformType getType() { return type; }

	DataType data;
	std::string name;
	UniformType type;
	GLuint bufferOffset;
	GLuint bindingPoint;
	UniformBlock *block;
};
