/*
 * Shader.cpp
 *
 *  Created on: Mar 9, 2016
 *      Author: pogal
 */

#include "Shader.h"

#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "math/Transform.h"

using namespace std;
using namespace glm;


Shader::Shader()
{
    valid = false;
}

Shader::Shader( const Shader& orig )
{
}

Shader::~Shader()
{
	//for( unsigned int i = 0; i < uniforms.size(); ++i )
	//{
	//	IUniform *iu = uniforms.at( i );
	//	delete iu;
	//}
	//uniforms.clear();
}

Shader::Shader( const char *vertexPath, const char *fragPath )
{
	valid = setupShader( vertexPath, fragPath );
}

Shader::Shader( string vertexPath, string fragPath )
{
	const char *vp = vertexPath.c_str();
	const char *fp = fragPath.c_str();

	valid = setupShader( vp, fp );
}

bool Shader::setupShader( const char *vertexPath, const char *fragPath )
{
	// Read the Vertex Shader code from the file
	std::string VertexShaderCode;
	std::ifstream VertexShaderStream( vertexPath, std::ios::in );
	if( VertexShaderStream.is_open() )
	{
		std::string Line = "";
		while( getline( VertexShaderStream, Line ) )
			VertexShaderCode += "\n" + Line;
		VertexShaderStream.close();
	}
	else
	{
		printf( "Cannot find file %s.\n", vertexPath );
		getchar();
		return false;
	}

	// Read the Fragment Shader code from the file
	std::string FragmentShaderCode;
	std::ifstream FragmentShaderStream( fragPath, std::ios::in );
	if( FragmentShaderStream.is_open() )
	{
		std::string Line = "";
		while( getline( FragmentShaderStream, Line ) )
			FragmentShaderCode += "\n" + Line;
		FragmentShaderStream.close();
	}

	GLint Result = GL_FALSE;
	int InfoLogLength;

	// Create the shaders
	GLuint VertexShaderID = glCreateShader( GL_VERTEX_SHADER );
	GLuint FragmentShaderID = glCreateShader( GL_FRAGMENT_SHADER );

	// Compile Vertex Shader
	char const * VertexSourcePointer = VertexShaderCode.c_str();
	glShaderSource( VertexShaderID, 1, &VertexSourcePointer, NULL );
	glCompileShader( VertexShaderID );

	// Check Vertex Shader
	glGetShaderiv( VertexShaderID, GL_COMPILE_STATUS, &Result );
	glGetShaderiv( VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> VertexShaderErrorMessage( InfoLogLength + 1 );
		glGetShaderInfoLog( VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0] );
		printf( "%s\n", &VertexShaderErrorMessage[0] );
		cout.flush();
	}


	// Compile Fragment Shader
	char const * FragmentSourcePointer = FragmentShaderCode.c_str();
	glShaderSource( FragmentShaderID, 1, &FragmentSourcePointer, NULL );
	glCompileShader( FragmentShaderID );

	// Check Fragment Shader
	glGetShaderiv( FragmentShaderID, GL_COMPILE_STATUS, &Result );
	glGetShaderiv( FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> FragmentShaderErrorMessage( InfoLogLength + 1 );
		glGetShaderInfoLog( FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0] );
		printf( "%s\n", &FragmentShaderErrorMessage[0] );
		cout.flush();
	}

	// Link the program
	GLuint ProgramID = glCreateProgram();
	glAttachShader( ProgramID, VertexShaderID );
	glAttachShader( ProgramID, FragmentShaderID );
	glLinkProgram( ProgramID );

	glBindAttribLocation( programID, VERTEX_ATTRIB_POSITION, "position" );
	glBindAttribLocation( programID, VERTEX_ATTRIB_NORMAL, "normal" );
	glBindAttribLocation( programID, VERTEX_ATTRIB_TEXCOORD0, "texcoord0" );

	// Check the program
	glGetProgramiv( ProgramID, GL_LINK_STATUS, &Result );
	glGetProgramiv( ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> ProgramErrorMessage( InfoLogLength + 1 );
		glGetProgramInfoLog( ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0] );
		printf( "%s\n", &ProgramErrorMessage[0] );
		cout.flush();
	}

	glDetachShader( ProgramID, VertexShaderID );
	glDetachShader( ProgramID, FragmentShaderID );

	glDeleteShader( VertexShaderID );
	glDeleteShader( FragmentShaderID );

	programID = ProgramID;

	return true;
}


Shader* Shader::shaderWithSource( string vertSource, string fragSource )
{
	Shader *shader = new Shader();

	// Create the shaders
	GLuint VertexShaderID = glCreateShader( GL_VERTEX_SHADER );
	GLuint FragmentShaderID = glCreateShader( GL_FRAGMENT_SHADER );

	GLint Result = GL_FALSE;
	int InfoLogLength;

	// Compile Vertex Shader
	char const * VertexSourcePointer = vertSource.c_str();
	glShaderSource( VertexShaderID, 1, &VertexSourcePointer, NULL );
	glCompileShader( VertexShaderID );

	// Check Vertex Shader
	glGetShaderiv( VertexShaderID, GL_COMPILE_STATUS, &Result );
	glGetShaderiv( VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> VertexShaderErrorMessage( InfoLogLength + 1 );
		glGetShaderInfoLog( VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0] );
		printf( "%s\n", &VertexShaderErrorMessage[0] );
		cout.flush();
	}


	// Compile Fragment Shader
	char const * FragmentSourcePointer = fragSource.c_str();
	glShaderSource( FragmentShaderID, 1, &FragmentSourcePointer, NULL );
	glCompileShader( FragmentShaderID );

	// Check Fragment Shader
	glGetShaderiv( FragmentShaderID, GL_COMPILE_STATUS, &Result );
	glGetShaderiv( FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> FragmentShaderErrorMessage( InfoLogLength + 1 );
		glGetShaderInfoLog( FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0] );
		printf( "%s\n", &FragmentShaderErrorMessage[0] );
		cout.flush();
	}

	// Link the program
	GLuint ProgramID = glCreateProgram();
	glAttachShader( ProgramID, VertexShaderID );
	glAttachShader( ProgramID, FragmentShaderID );
	glLinkProgram( ProgramID );

	glBindAttribLocation( ProgramID, VERTEX_ATTRIB_POSITION, "position" );
	glBindAttribLocation( ProgramID, VERTEX_ATTRIB_NORMAL, "normal" );
	glBindAttribLocation( ProgramID, VERTEX_ATTRIB_TEXCOORD0, "texcoord0" );

	// Check the program
	glGetProgramiv( ProgramID, GL_LINK_STATUS, &Result );
	glGetProgramiv( ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength );
	if( InfoLogLength > 0 )
	{
		std::vector<char> ProgramErrorMessage( InfoLogLength + 1 );
		glGetProgramInfoLog( ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0] );
		printf( "%s\n", &ProgramErrorMessage[0] );
		cout.flush();
	}

	glDetachShader( ProgramID, VertexShaderID );
	glDetachShader( ProgramID, FragmentShaderID );

	glDeleteShader( VertexShaderID );
	glDeleteShader( FragmentShaderID );

	shader->programID = ProgramID;
	shader->valid = true;

	return shader;
}




Shader::Shader( string vertexPath, string fragPath, int attribs )
{
	GLuint vertShader, fragShader;
	string vertShaderPathname, fragShaderPathname;

	// Create shader program
	programID = glCreateProgram();

	// Create and compile vertex shader
	if( !compileShader( &vertShader, GL_VERTEX_SHADER, vertexPath ) )
	{
		printf( "Failed to compile vertex shader (attr): %s\n", vertexPath.c_str() );
	}

	// Create and compile fragment shader
	if( !compileShader( &fragShader, GL_FRAGMENT_SHADER, fragPath ) )
	{
		printf( "Failed to compile fragment shader (attr): %s\n", fragPath.c_str() );
	}

	// Attach vertex shader to program
	glAttachShader( programID, vertShader );

	// Attach fragment shader to program
	glAttachShader( programID, fragShader );

	// Bind attribute locations
	// This needs to be done prior to linking
	if( attribs | VERTEX_ATTRIB_POSITION )
	    glBindAttribLocation( programID, VERTEX_ATTRIB_POSITION, "position" );
	if( attribs | VERTEX_ATTRIB_NORMAL )
	    glBindAttribLocation( programID, VERTEX_ATTRIB_NORMAL, "normal" );
	if( attribs | VERTEX_ATTRIB_TEXCOORD0 )
	    glBindAttribLocation( programID, VERTEX_ATTRIB_TEXCOORD0, "texcoord0" );
	if( attribs | VERTEX_ATTRIB_TEXCOORD1 )
	    glBindAttribLocation( programID, VERTEX_ATTRIB_TEXCOORD1, "texcoord1" );
	if( attribs | VERTEX_ATTRIB_COLOR )
	    glBindAttribLocation( programID, VERTEX_ATTRIB_COLOR, "color" );
	if( attribs | VERTEX_ATTRIB_BONE_ID )
		glBindAttribLocation( programID, VERTEX_ATTRIB_BONE_ID, "boneIDs" );
	if( attribs | VERTEX_ATTRIB_BONE_WEIGHT )
		glBindAttribLocation( programID, VERTEX_ATTRIB_BONE_WEIGHT, "weights" );

	// Link program
	if( !linkProgram( programID ) )
	{
		cout << "Failed to link program: " << programID << endl;

		if( vertShader )
		{
			glDeleteShader( vertShader );
			vertShader = 0;
		}
		if( fragShader )
		{
			glDeleteShader( fragShader );
			fragShader = 0;
		}
		if( programID )
		{
			glDeleteProgram( programID );
			programID = 0;
		}
		return;
	}

	// Release vertex and fragment shaders.
	if( vertShader )
	{
		glDetachShader( programID, vertShader );
		glDeleteShader( vertShader );
	}
	if( fragShader )
	{
		glDetachShader( programID, fragShader );
		glDeleteShader( fragShader );
	}

	valid = true;
}




IUniform* Shader::addUniform( string name, string type )
{
	IUniform *u = NULL;
	if( type.compare( "sampler2D" ) == 0 )
	{
		u = new Uniform<GLuint>( name, SAMPLER2D_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "int" ) == 0 )
	{
		u = new Uniform<int>( name, INT_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "float" ) == 0 )
	{
		u = new Uniform<float>( name, FLOAT_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec2" ) == 0 )
	{
		u = new Uniform<vec2>( name, VEC2_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec3" ) == 0 )
	{
		u = new Uniform<vec3>( name, VEC3_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "vec4" ) == 0 )
	{
		u = new Uniform<vec4>( name, VEC4_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "mat3" ) == 0 )
	{
		u = new Uniform<mat3>( name, MAT3_TYPE );
		uniforms.push_back( u );
		return u;
	}
	if( type.compare( "mat4" ) == 0 )
	{
		u = new Uniform<mat4>( name, MAT4_TYPE );
		uniforms.push_back( u );
		return u;
	}
	return u;
}


void Shader::assignUniformValues()
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform* uv = *it;
		uv->set( this );
    }

	assignBlockUniformValues();
}

void Shader::assignBlockUniformValues()
{
	for( vector<UniformBlock*>::iterator it = blocks.begin(); it != blocks.end(); ++it )
	{
		UniformBlock *block = *it;
		block->assignUniformValues();
		block->buffer->commitBuffer();
	}
}

UniformBlock* Shader::getBlockFromBindingPoint( GLuint bindingPoint )
{
	for( vector<UniformBlock*>::iterator it = blocks.begin(); it != blocks.end(); ++it )
	{
		UniformBlock *block = *it;
		if( block->buffer->bindingPoint == bindingPoint )
		{
			return block;
		}
	}
	return NULL;
}

IUniform* Shader::getUniform( string name )
{
	for( vector<IUniform*>::iterator it = uniforms.begin(); it != uniforms.end(); ++it )
	{
		IUniform *uv = *it;
		if( name.compare( uv->getName() ) == 0 ) return uv;
	}

	// check blocks
	for( vector<UniformBlock*>::iterator it = blocks.begin(); it != blocks.end(); ++it )
	{
		UniformBlock *block = *it;
		for( vector<IUniform*>::iterator uit = block->uniforms.begin(); uit != block->uniforms.end(); ++uit )
		{
			IUniform *bu = *uit;
			if( name.compare( bu->getName() ) == 0 ) return bu;
		}
	}
	return NULL;
}

void Shader::useProgram()
{
	glUseProgram( programID );
}

bool Shader::compileShader( GLuint *shader, GLenum type, string file )
{
    GLint success = 0;
    
    ifstream ifile( file.c_str() );
    string filetext;

    while( ifile.good() )
    {
        string line;
        getline( ifile, line );
        filetext.append( line + "\n" );
    }
    if( filetext.length() == 0 )
    {
        printf( "Failed to load shader source: %s\n", file.c_str() );
        return false;
    }

    const char *source = filetext.c_str();
    *shader = glCreateShader( type );
//    GLint srcLen = filetext.length();
    glShaderSource( *shader, 1, &source, 0 );
    glCompileShader( *shader );
    glGetShaderiv( *shader, GL_COMPILE_STATUS, &success );
    if( success == GL_FALSE )
    {
        GLint logLength = 0;
        glGetProgramiv( *shader, GL_INFO_LOG_LENGTH, &logLength );
        if( logLength == 0 )
		{
        	printf( "Failed, but log is empty...\n" );
        	return false;
		}
        vector<GLchar> infoLog( logLength );
        glGetProgramInfoLog( *shader, logLength, &logLength, &infoLog[0] );
        printf( "Failed to compile source (%d): \n%s\n", logLength, &infoLog[0] );
        return false;
    }

    return true;
}

bool Shader::linkProgram( GLuint prog )
{
    GLint status;
    glLinkProgram( prog );

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv( prog, GL_INFO_LOG_LENGTH, &logLength );
    if( logLength > 0 )
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog( prog, logLength, &logLength, log );
        NSLog( @"Program link log:\n%s", log );
        free(log);
    }
#endif

    glGetProgramiv( prog, GL_LINK_STATUS, &status );
    if( status == GL_FALSE )
    {
        GLint logLength = 0;
        glGetProgramiv( prog, GL_INFO_LOG_LENGTH, &logLength );
        vector<GLchar> infoLog( logLength );
        glGetProgramInfoLog( prog, logLength, &logLength, &infoLog[0] );
        printf( "Failed to link program (%d): \n%s\n", logLength, &infoLog[0] );
        return false;
    }

    return true;
}

bool Shader::validateProgram( GLuint prog )
{
    GLint logLength = 0, status;

    glGetProgramiv( prog, GL_INFO_LOG_LENGTH, &logLength );
    if( logLength > 0 )
    {
        vector<GLchar> infoLog( logLength );
        glGetProgramInfoLog( prog, logLength, &logLength, &infoLog[0] );
        printf( "Failed to link program (%d): \n%s\n", logLength, &infoLog[0] );
        return false;
    }

    glGetProgramiv( prog, GL_VALIDATE_STATUS, &status );
    if( status == 0 )
    {
        return false;
    }

    return true;
}
