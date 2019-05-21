#pragma once

#include <string>
#include <vector>
#include <GL/glew.h>
#include "glm/glm.hpp"
#include "Uniform.h"


enum VertexAttrib
{
    VERTEX_ATTRIB_POSITION = 0,
    VERTEX_ATTRIB_NORMAL = 1,
    VERTEX_ATTRIB_TEXCOORD0 = 2,
    VERTEX_ATTRIB_TEXCOORD1 = 3,
	VERTEX_ATTRIB_BONE_ID = 4,
	VERTEX_ATTRIB_BONE_WEIGHT = 5,
    VERTEX_ATTRIB_COLOR = 6,
	VERTEX_ATTRIB_NONE = 7
};


class Shader
{
public:
    Shader();
	Shader( const char *vertexPath, const char *fragPath );
    Shader( std::string vertexPath, std::string fragPath );
	Shader( std::string vertexPath, std::string fragPath, int attribs );
    Shader( const Shader& orig );
    virtual ~Shader();

	static Shader* shaderWithSource( std::string vertSource, std::string fragSource );
    
    void assignUniformValues();
	void assignBlockUniformValues();
    IUniform* getUniform( std::string name );
	IUniform* addUniform( std::string name, std::string type );
	void useProgram();
	UniformBlock* getBlockFromBindingPoint( GLuint bindingPoint );
    
    bool valid;
    GLuint programID;
    std::string vertexSource, fragSource;
    GLuint projectionMatrixID, modelviewMatrixID, modelviewProjectionMatrixID;
	std::vector<IUniform*> uniforms;
	std::vector<UniformBlock*> blocks;

private:
    bool compileShader( GLuint *shader, GLenum type, std::string file );
    bool linkProgram( GLuint prog );
    bool validateProgram( GLuint prog );

	bool setupShader( const char *vertPath, const char *fragPath );
	
};
