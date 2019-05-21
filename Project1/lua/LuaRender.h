#pragma once


#include "lua/lua_util.h"
#include "main/GlobalDefs.h"
#include "render/RenderUnit.h"
#include "render/Framebuffer.h"
#include "render/Cubemap.h"
#include "game/Unit.h"
#include "ui/Overlay.h"
#include "ui/GameMenu.h"


#include <glm/glm.hpp>


namespace lua_render
{
	using namespace std;
	using namespace defs;
	using namespace glm;

	int changeRenderMode( lua_State *L )
	{
		RenderMode = lua_tonumber( L, 1 );
		if( RenderMode > 1 || RenderMode < 0 ) RenderMode = 0;

		return 0;
	}

	int createRenderUnit( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		string name = lua::retrieveString( L, 2 );
		RenderUnit *ru = new RenderUnit( name );

		lua_pushlightuserdata( L, ru );
		return 1;
	}

	int addRenderUnit( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 2 );
		game->renderer.addRenderUnit( ru );

		return 0;
	}

	int setOutputBuffer( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Framebuffer *fb = (Framebuffer*)lua_touserdata( L, 2 );
		ru->output = fb;
		ru->useDefaultFBO = false;

		return 0;
	}

	int useDefaultFBO( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		ru->useDefaultFBO = true;

		return 0;
	}

	int setStaticShader( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		ru->setStaticShader( shader );

		return 0;
	}

	int setAnimatedShader( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		ru->setAnimatedShader( shader );

		return 0;
	}

	int addStaticModel( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Model *model = (Model*)lua_touserdata( L, 2 );
		ru->addStaticModel( model );

		return 0;
	}

	int addAnimatedModel( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Node *node = (Node*)lua_touserdata( L, 2 );
		ru->addAnimatedModel( node );

		return 0;
	}

	int addUnit( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Unit *unit = (Unit*)lua_touserdata( L, 2 );
		ru->addUnit( unit );

		return 0;
	}

	int addText( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		TextItem *ti = (TextItem*)lua_touserdata( L, 2 );
		ru->addTextItem( ti );

		return 0;
	}

	int removeText( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		TextItem *ti = (TextItem*)lua_touserdata( L, 2 );
		ru->removeTextItem( ti );

		return 0;
	}

	int addOverlay( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Overlay *overlay = (Overlay*)lua_touserdata( L, 2 );
		ru->addOverlay( overlay );

		return 0;
	}

	int removeOverlay( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Overlay *overlay = (Overlay*)lua_touserdata( L, 2 );
		ru->removeOverlay( overlay );

		return 0;
	}

	int addMenu( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 2 );
		ru->addMenu( menu );

		return 0;
	}

	int createFramebuffer( lua_State *L )
	{
		int width = (int)lua_tonumber( L, 1 );
		int height = (int)lua_tonumber( L, 2 );
		Framebuffer *fb = new Framebuffer( width, height );

		lua_pushlightuserdata( L, fb );
		return 1;
	}

	int createCubemap( lua_State *L )
	{
		string path = lua::retrieveString( L, 1 );
		string base = lua::retrieveString( L, 2 );
		Cubemap *cm = new Cubemap( path, base );

		lua_pushlightuserdata( L, cm );
		return 1;
	}

	int addCubemap( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 2 );
		ru->setCubemap( cm );

		return 0;
	}

	int cmPosX( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setPosXImage( filename );

		return 0;
	}

	int cmNegX( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setNegXImage( filename );

		return 0;
	}

	int cmPosY( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setPosYImage( filename );

		return 0;
	}

	int cmNegY( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setNegYImage( filename );

		return 0;
	}

	int cmPosZ( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setPosZImage( filename );

		return 0;
	}

	int cmNegZ( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		cm->setNegZImage( filename );

		return 0;
	}

	int cmSetShader( lua_State *L )
	{
		Cubemap *cm = (Cubemap*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		cm->shader = shader;

		return 0;
	}

	int setBlendFunc( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		GLuint src = (GLuint)lua_tonumber( L, 2 );
		GLuint dst = (GLuint)lua_tonumber( L, 3 );
		ru->blendSource = lua::translateBlendFunc( src );
		ru->blendDest = lua::translateBlendFunc( dst );
		ru->blend = true;

		return 0;
	}

	int useBlend( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		bool blend = lua_toboolean( L, 2 );
		ru->blend = blend;

		return 0;
	}

	int useDepthTest( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		bool test = lua_toboolean( L, 2 );
		ru->depthTest = test;

		return 0;
	}

	int useDepthFunc( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		GLuint func = (GLuint)lua_tonumber( L, 2 );
		ru->depthFunc = func;
		ru->depthTest = true;

		return 0;
	}



	// Matrix functions
	int getOrthoMatrix( lua_State *L )
	{
		int left = lua::retrieveInt( L, 1 );
		int right = lua::retrieveInt( L, 2 );
		int bottom = lua::retrieveInt( L, 3 );
		int top = lua::retrieveInt( L, 4 );
		mat4 ortho = glm::ortho( left, right, bottom, top );

		lua::storeMat4( L, ortho );
		return 1;
	}

	int getPerspectiveMatrix( lua_State *L )
	{
		float fov = lua::retrieveFloat( L, 1 );
		float aspect = lua::retrieveFloat( L, 2 );
		float zNear = lua::retrieveFloat( L, 3 );
		float zFar = lua::retrieveFloat( L, 4 );
		mat4 perspective = glm::perspective( fov, aspect, zNear, zFar );

		lua::storeMat4( L, perspective );
		return 1;
	}


	int clearBufferBits( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		ru->clearBufferBits = true;

		return 0;
	}

	int getWindowSize( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );

		lua_pushnumber( L, game->renderer.windowWidth );
		lua_pushnumber( L, game->renderer.windowHeight );
		return 2;
	}

	int setClearColor( lua_State *L )
	{
		RenderUnit *ru = (RenderUnit*)lua_touserdata( L, 1 );
		vec4 color = lua::retrieveVec4( L, 2 );
		ru->setClearColor( color );

		return 0;
	}

	int transferDepthData( lua_State *L )
	{
		Framebuffer *src = (Framebuffer*)lua_touserdata( L, 1 );
		Framebuffer *dst = (Framebuffer*)lua_touserdata( L, 2 );
		src->transferDepthDataTo( dst );

		return 0;
	}

	int createGBuffer( lua_State *L )
	{
		GLint width = (GLint)lua_tonumber( L, 1 );
		GLint height = (GLint)lua_tonumber( L, 2 );
		Framebuffer *gBuffer = Framebuffer::createGBuffer( width, height );

		lua_pushlightuserdata( L, gBuffer );
		lua_pushlightuserdata( L, &gBuffer->posTexture );
		lua_pushlightuserdata( L, &gBuffer->normTexture );
		lua_pushlightuserdata( L, &gBuffer->texture );
		return 4;
	}

	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Render_changeMode", changeRenderMode );
		lua::registerLuacFunction( L, "Render_createUnit", createRenderUnit );
		lua::registerLuacFunction( L, "Render_addRenderUnit", addRenderUnit );
		lua::registerLuacFunction( L, "Render_setOutput", setOutputBuffer );
		lua::registerLuacFunction( L, "Render_useDefaultFBO", useDefaultFBO );
		lua::registerLuacFunction( L, "Render_setStaticShader", setStaticShader );
		lua::registerLuacFunction( L, "Render_setAnimatedShader", setAnimatedShader );
		lua::registerLuacFunction( L, "Render_addStaticModel", addStaticModel );
		lua::registerLuacFunction( L, "Render_addAnimatedModel", addAnimatedModel );
		lua::registerLuacFunction( L, "Render_addUnit", addUnit );
		lua::registerLuacFunction( L, "Render_addTextItem", addText );
		lua::registerLuacFunction( L, "Render_removeTextItem", removeText );
		lua::registerLuacFunction( L, "Render_addOverlay", addOverlay );
		lua::registerLuacFunction( L, "Render_removeOverlay", removeOverlay );
		lua::registerLuacFunction( L, "Render_addMenu", addMenu );
		lua::registerLuacFunction( L, "Render_createCubemap", createCubemap );
		lua::registerLuacFunction( L, "Render_setCubemap", addCubemap );
		lua::registerLuacFunction( L, "Cubemap_posX", cmPosX );
		lua::registerLuacFunction( L, "Cubemap_negX", cmNegX );
		lua::registerLuacFunction( L, "Cubemap_posY", cmPosY );
		lua::registerLuacFunction( L, "Cubemap_negY", cmNegY );
		lua::registerLuacFunction( L, "Cubemap_posZ", cmPosZ );
		lua::registerLuacFunction( L, "Cubemap_negZ", cmNegZ );
		lua::registerLuacFunction( L, "Cubemap_setShader", cmSetShader );
		lua::registerLuacFunction( L, "Render_useBlendFunc", setBlendFunc );
		lua::registerLuacFunction( L, "Render_useBlend", useBlend );
		lua::registerLuacFunction( L, "Render_useDepthTest", useDepthTest );
		lua::registerLuacFunction( L, "Render_useDepthFunc", useDepthFunc );
		lua::registerLuacFunction( L, "Render_getOrthoMatrix", getOrthoMatrix );
		lua::registerLuacFunction( L, "Render_getPerspectiveMatrix", getPerspectiveMatrix );
		lua::registerLuacFunction( L, "Render_clearBufferBits", clearBufferBits );
		lua::registerLuacFunction( L, "Render_getWindowSize", getWindowSize );
		lua::registerLuacFunction( L, "Render_setClearColor", setClearColor );
		lua::registerLuacFunction( L, "Framebuffer_new", createFramebuffer );
		lua::registerLuacFunction( L, "Framebuffer_transferDepthData", transferDepthData );
		lua::registerLuacFunction( L, "Framebuffer_newGBuffer", createGBuffer );
	}
}