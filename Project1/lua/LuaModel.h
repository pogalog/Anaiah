#pragma once


#include "lua/lua_util.h"
#include "lua/lua_translate.h"
#include "model/Model.h"
#include "model/ModelUtil.h"


#include <glm/glm.hpp>

namespace lua_model
{
	using namespace std;
	using namespace glm;

	int setShader( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		for( vector<Mesh>::iterator mit = model->meshes.begin(); mit != model->meshes.end(); ++mit )
		{
			Mesh &mesh = *mit;
			mesh.setShader( shader );
		}

		return 0;
	}


	int buildModel( lua_State *L )
	{
		// create a new Model
		Model *model = new Model();
		Mesh &pm = model->getPrimaryMesh();

		size_t pos_size = lua_tonumber( L, 1 );
		const char *binaryPosData = luaL_tolstring( L, 2, &pos_size );
		GLfloat *posData = (GLfloat*)binaryPosData;
		pm.numPositions = pos_size / 12;
		pm.positionBuffer = vector<GLfloat>( posData, posData + pos_size / 4 );

		size_t uv_size = lua_tonumber( L, 3 );
		if( uv_size > 0 )
		{
			const char *binaryUVData = luaL_tolstring( L, 4, &uv_size );
			GLfloat *uvData = (GLfloat*)binaryUVData;
			pm.numTexcoords = uv_size / 8;
			pm.uvBuffer = vector<GLfloat>( uvData, uvData + uv_size / 4 );
		}

		size_t norm_size = lua_tonumber( L, 5 );
		if( norm_size > 0 )
		{
			const char *binaryNormData = luaL_tolstring( L, 6, &norm_size );
			GLfloat *normData = (GLfloat*)binaryNormData;
			pm.numNormals = norm_size / 12;
			pm.normalBuffer = vector<GLfloat>( normData, normData + norm_size / 4 );
		}

		size_t color_size = lua_tonumber( L, 7 );
		if( color_size > 0 )
		{
			const char *binaryColorData = luaL_tolstring( L, 8, &color_size );
			GLfloat *colorData = (GLfloat*)binaryColorData;
			pm.numColors = color_size / 16;
			pm.colorBuffer = vector<GLfloat>( colorData, colorData + color_size / 4 );
		}

		size_t elem_size = lua_tonumber( L, 9 );
		const char *binaryElemData = luaL_tolstring( L, 10, &elem_size );
		GLuint *elemData = (GLuint*)binaryElemData;
		pm.elementBuffer = vector<GLuint>( elemData, elemData + elem_size / 4 );
		pm.numElements = elem_size / 4;

		GLenum drawMode = lua::translateDrawMode( lua_tonumber( L, 11 ) );
		pm.drawMode = drawMode;

		GLuint vaoName = pm.buildVAO();
		
		// return userdata (pointer to the Model*)
		lua_pushlightuserdata( L, model );
		lua_pushnumber( L, vaoName );
		return 2;
	}

	int buildVAO( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		Mesh &primary = model->getPrimaryMesh();
		GLuint vaoName = primary.buildVAO();

		lua_pushnumber( L, vaoName );
		return 1;
	}


	int generateGridModel( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		model_util::createGridModel( &game->levelMap->grid );

		lua_pushlightuserdata( L, &game->levelMap->grid.model );
		return 1;
	}


	int setDrawMode( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		GLuint drawMode = (GLuint)lua_tonumber( L, 2 );
		for( vector<Mesh>::iterator mit = model->meshes.begin(); mit != model->meshes.end(); ++mit )
		{
			Mesh &mesh = *mit;
			mesh.drawMode = lua::translateDrawMode( drawMode );
		}

		return 0;
	}

	int setIntUniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		int value = lua::retrieveInt( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setIntUniform( name, value );

		return 0;
	}

	int setFloatUniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		float value = lua::retrieveFloat( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setFloatUniform( name, value );

		return 0;
	}

	int setVec2Uniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		vec2 value = lua::retrieveVec2( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setVec2Uniform( name, value );

		return 0;
	}

	int setVec3Uniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		vec3 value = lua::retrieveVec3( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setVec3Uniform( name, value );

		return 0;
	}

	int setVec4Uniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		vec4 value = lua::retrieveVec4( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setVec4Uniform( name, value );

		return 0;
	}

	int setMat3Uniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		mat3 value = lua::retrieveMat3( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setMat3Uniform( name, value );

		return 0;
	}

	int setMat4Uniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		mat4 value = lua::retrieveMat4( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setMat4Uniform( name, value );

		return 0;
	}

	int setTextureUniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		GLuint value = (GLuint)lua_tonumber( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setSampler2DUniform( name, value );

		return 0;
	}

	int setFramebufferUniform( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		Framebuffer *fb = (Framebuffer*)lua_touserdata( L, 3 );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.setSampler2DUniform( name, fb->texture.name );

		return 0;
	}

	int setLineWidth( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		float width = lua::retrieveFloat( L, 2 );
		model->lineWidth = width;

		return 0;
	}

	int setVisible( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		bool vis = lua_toboolean( L, 2 );
		model->visible = vis;

		return 0;
	}

	int addTexture( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		Texture *texture = (Texture*)lua_touserdata( L, 3 );
		texture->uniformName = name;
		model->textures.push_back( texture );

		return 0;
	}

	int addFramebuffer( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		Framebuffer *fb = (Framebuffer*)lua_touserdata( L, 3 );
		Texture *t = new Texture( fb->texture );
		t->uniformName = name;
		model->textures.push_back( t );

		lua_pushlightuserdata( L, t );
		return 1;
	}

	int setPosition( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		vec3 pos = lua::retrieveVec3( L, 2 );
		model->transform.setPosition( pos );
		model->transform.setMatrix();

		return 0;
	}

	int move( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		vec3 move = lua::retrieveVec3( L, 2 );
		model->transform.setPosition( model->transform.position + move );

		return 0;
	}

	int setScale( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		vec3 scale = lua::retrieveVec3( L, 2 );
		model->transform.setScale( scale );

		return 0;
	}

	int setBillboard( lua_State *L )
	{
		Model *model = (Model*)lua_touserdata( L, 1 );
		bool billboard = lua_toboolean( L, 2 );
		model->billboard = billboard;

		return 0;
	}

	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Model_setShader", setShader );
		lua::registerLuacFunction( L, "Model_build", buildModel );
		lua::registerLuacFunction( L, "Model_buildVAO", buildVAO );
		lua::registerLuacFunction( L, "Model_buildGrid", generateGridModel );
		lua::registerLuacFunction( L, "Model_setDrawMode", setDrawMode );
		lua::registerLuacFunction( L, "Model_setIntUniform", setIntUniform );
		lua::registerLuacFunction( L, "Model_setFloatUniform", setFloatUniform );
		lua::registerLuacFunction( L, "Model_setVec2Uniform", setVec2Uniform );
		lua::registerLuacFunction( L, "Model_setVec3Uniform", setVec3Uniform );
		lua::registerLuacFunction( L, "Model_setVec4Uniform", setVec4Uniform );
		lua::registerLuacFunction( L, "Model_setMat3Uniform", setMat3Uniform );
		lua::registerLuacFunction( L, "Model_setMat4Uniform", setMat4Uniform );
		lua::registerLuacFunction( L, "Model_setTextureUniform", setTextureUniform );
		lua::registerLuacFunction( L, "Model_setFramebufferUniform", setFramebufferUniform );
		lua::registerLuacFunction( L, "Model_setLineWidth", setLineWidth );
		lua::registerLuacFunction( L, "Model_setVisible", setVisible );
		lua::registerLuacFunction( L, "Model_addTexture", addTexture );
		lua::registerLuacFunction( L, "Model_addFramebuffer", addFramebuffer );
		lua::registerLuacFunction( L, "Model_setPosition", setPosition );
		lua::registerLuacFunction( L, "Model_setScale", setScale );
		lua::registerLuacFunction( L, "Model_move", move );
		lua::registerLuacFunction( L, "Model_setBillboard", setBillboard );
	}
}