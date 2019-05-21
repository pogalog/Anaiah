#pragma once

#include "lua/lua_util.h"
#include "render/Shader.h"
#include "render/Framebuffer.h"


namespace lua_shader
{
	using namespace std;
	using namespace glm;


	// Shader( std::string vertexPath, std::string fragPath, int attribs );
	int newShader( lua_State *L )
	{
		string vertexFile = lua::retrieveString( L, 1 );
		string fragFile = lua::retrieveString( L, 2 );
		Shader *shader = new Shader( vertexFile, fragFile );

		lua_pushlightuserdata( L, shader );
		return 1;
	}

	int newShaderWithSource( lua_State *L )
	{
		string vertSource = lua::retrieveString( L, 1 );
		string fragSource = lua::retrieveString( L, 2 );
		Shader *shader = Shader::shaderWithSource( vertSource, fragSource );

		lua_pushlightuserdata( L, shader );
		return 1;
	}


	int newUniform( lua_State *L )
	{
		Shader *shader = (Shader*)lua_touserdata( L, 1 );
		string type = string( lua_tostring( L, 2 ) );
		string name = string( lua_tostring( L, 3 ) );
		IUniform *uniform = shader->addUniform( name, type );

		lua_pushlightuserdata( L, uniform );
		return 1;
	}

	int newBlock( lua_State *L )
	{
		Shader *shader = (Shader*)lua_touserdata( L, 1 );
		string name = string( lua_tostring( L, 2 ) );
		UniformBlock *block = new UniformBlock( name, shader );
		shader->blocks.push_back( block );

		lua_pushlightuserdata( L, block );
		return 1;
	}

	int newBlockUniform( lua_State *L )
	{
		UniformBlock *block = (UniformBlock*)lua_touserdata( L, 1 );
		string type = string( lua_tostring( L, 2 ) );
		string name = string( lua_tostring( L, 3 ) );
		IUniform *uniform = block->addUniform( name, type );
		uniform->setBlock( block );

		lua_pushlightuserdata( L, uniform );
		return 1;
	}

	int setBlockLocations( lua_State *L )
	{
		UniformBlock *block = (UniformBlock*)lua_touserdata( L, 1 );
		block->setLocations();

		return 0;
	}

	int newBuffer( lua_State *L )
	{
		int size = lua::retrieveInt( L, 1 );
		int bindingPoint = lua::retrieveInt( L, 2 );
		UniformBuffer *buffer = new UniformBuffer( size, bindingPoint );

		lua_pushlightuserdata( L, buffer );
		return 1;
	}

	int bindBuffer( lua_State *L )
	{
		UniformBlock *block = (UniformBlock*)lua_touserdata( L, 1 );
		UniformBuffer *buffer = (UniformBuffer*)lua_touserdata( L, 2 );
		buffer->bindBlock( block );

		return 0;
	}

	int setUniformInt( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		int data = (int)lua_tonumber( L, 2 );
		Uniform<int> *ui = (Uniform<int>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformFloat( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		float data = (float)lua_tonumber( L, 2 );
		Uniform<float> *ui = (Uniform<float>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformVec2( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		vec2 data = lua::retrieveVec2( L, 2 );
		Uniform<vec2> *ui = (Uniform<vec2>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformVec3( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		vec3 data = lua::retrieveVec3( L, 2 );
		Uniform<vec3> *ui = (Uniform<vec3>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformVec4( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		vec4 data = lua::retrieveVec4( L, 2 );
		Uniform<vec4> *ui = (Uniform<vec4>*)uniform;
		ui->setData( data );

		return 0;
	}


	int setUniformMat3( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		mat3 data = lua::retrieveMat3( L, 2 );
		Uniform<mat3> *ui = (Uniform<mat3>*)uniform;
		ui->setData( data );

		return 0;
	}


	int setUniformMat4( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		mat4 data = lua::retrieveMat4( L, 2 );
		Uniform<mat4> *ui = (Uniform<mat4>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformTexture( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		GLuint data = lua::retrieveInt( L, 2 );
		Uniform<GLuint> *ui = (Uniform<GLuint>*)uniform;
		ui->setData( data );

		return 0;
	}

	int setUniformFramebuffer( lua_State *L )
	{
		IUniform *uniform = (IUniform*)lua_touserdata( L, 1 );
		Framebuffer *fb = (Framebuffer*)lua_touserdata( L, 2 );
		Uniform<GLuint> *ui = (Uniform<GLuint>*)uniform;
		ui->setData( fb->texture.name );

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Shader_new", newShader );
		lua::registerLuacFunction( L, "Shader_withSource", newShaderWithSource );
		lua::registerLuacFunction( L, "Uniform_new", newUniform );
		lua::registerLuacFunction( L, "Uniform_newBlock", newBlock );
		lua::registerLuacFunction( L, "Uniform_newBlockUniform", newBlockUniform );
		lua::registerLuacFunction( L, "Uniform_setBlockLocations", setBlockLocations );
		lua::registerLuacFunction( L, "Uniform_newBuffer", newBuffer );
		lua::registerLuacFunction( L, "Uniform_bindBuffer", bindBuffer );
		lua::registerLuacFunction( L, "Uniform_setInt", setUniformInt );
		lua::registerLuacFunction( L, "Uniform_setFloat", setUniformFloat );
		lua::registerLuacFunction( L, "Uniform_setVec2", setUniformVec2 );
		lua::registerLuacFunction( L, "Uniform_setVec3", setUniformVec3 );
		lua::registerLuacFunction( L, "Uniform_setVec4", setUniformVec4 );
		lua::registerLuacFunction( L, "Uniform_setMat3", setUniformMat3 );
		lua::registerLuacFunction( L, "Uniform_setMat4", setUniformMat4 );
		lua::registerLuacFunction( L, "Uniform_setTexture", setUniformTexture );
		lua::registerLuacFunction( L, "Uniform_setFramebuffer", setUniformFramebuffer );
	}

}