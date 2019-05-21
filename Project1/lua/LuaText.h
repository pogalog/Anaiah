#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"
#include "text/TextItem.h"


namespace lua_text
{
	using namespace std;
	using namespace glm;

	int loadFont( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		string fontName = lua::retrieveString( L, 2 );
		Shader *shader = (Shader*)lua_touserdata( L, 3 );
		FontMap *font = game->textAssetManager.loadFontMap( fontName.c_str() );
		font->setShader( shader );

		lua_pushlightuserdata( L, font );
		return 1;
	}

	int Text_new( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		FontMap *font = (FontMap*)lua_touserdata( L, 2 );
		string message = lua::retrieveString( L, 3 );
		TextItem *ti = game->textAssetManager.createTextItem( font, message );

		lua_pushlightuserdata( L, ti );
		return 1;
	}

	int Text_dispose( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		TextItem *ti = (TextItem*)lua_touserdata( L, 2 );
		game->textAssetManager.removeTextItem( ti );

		return 0;
	}

	int Text_setPosition( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		vec3 position = lua::retrieveVec3( L, 2 );
		ti->getTransform().setPosition( position );
		return 0;
	}

	int Text_setScale( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		vec3 scale = lua::retrieveVec3( L, 2 );
		ti->getTransform().setScale( scale );
		return 0;
	}

	int setText( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		const char *message = lua_tostring( L, 2 );
		ti->setText( string( message ) );

		return 0;
	}

	int setVisible( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		bool visible = lua_toboolean( L, 2 );
		ti->setVisible( visible );

		return 0;
	}

	int setColor( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		Color color = lua::retrieveColor( L, 2 );
		ti->setColor( color );

		return 0;
	}

	int set2D( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		ti->set2D( true );

		return 0;
	}

	int set3D( lua_State *L )
	{
		TextItem *ti = (TextItem*)lua_touserdata( L, 1 );
		ti->set2D( false );

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Font_load", loadFont );
		lua::registerLuacFunction( L, "Text_new", Text_new );
		lua::registerLuacFunction( L, "Text_dispose", Text_dispose );
		lua::registerLuacFunction( L, "Text_setPosition", Text_setPosition );
		lua::registerLuacFunction( L, "Text_setScale", Text_setScale );
		lua::registerLuacFunction( L, "Text_setColor", setColor );
		lua::registerLuacFunction( L, "Text_setText", setText );
		lua::registerLuacFunction( L, "Text_setVisible", setVisible );
		lua::registerLuacFunction( L, "Text_set2D", set2D );
		lua::registerLuacFunction( L, "Text_set3D", set3D );
	}

}