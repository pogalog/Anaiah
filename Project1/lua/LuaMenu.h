#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"


namespace lua_menu
{
	using namespace std;
	using namespace glm;

	int newMenu( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		GameMenu *menu = new GameMenu();
		game->menuAssetManager.addMenu( menu );

		lua_pushlightuserdata( L, menu );
		return 1;
	}

	int addItem( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		string text = lua::retrieveString( L, 2 );
		GameMenuItem *item = menu->addMenuItem( text );

		lua_pushlightuserdata( L, item );
		return 1;
	}
	
	int setShader( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		menu->setShader( shader );

		return 0;
	}

	int setItemShader( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		menu->setItemShader( shader );

		return 0;
	}

	int setFont( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		FontMap *font = (FontMap*)lua_touserdata( L, 2 );
		menu->setFont( font );

		return 0;
	}

	int build( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		menu->buildModel();

		return 0;
	}

	int setSize( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		vec2 size = lua::retrieveVec2( L, 2 );
		menu->setSize( size );
		
		return 0;
	}

	int setPosition( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		vec2 position = lua::retrieveVec2( L, 2 );
		menu->setPosition( position );
		
		return 0;
	}

	int setVisible( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		bool visible = lua_toboolean( L, 2 );
		menu->setVisible( visible );

		return 0;
	}

	int setCursorPosition( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		int cursor = lua_tonumber( L, 2 );
		menu->setCursorPosition( cursor );

		return 0;
	}

	int setLayout( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		vector<void*> ud = lua::retrieveUserdata( L, 2 );
		vector<GameMenuItem*> items;
		for( vector<void*>::iterator it = ud.begin(); it != ud.end(); ++it )
		{
			GameMenuItem *item = (GameMenuItem*)*it;
			items.push_back( item );
		}
		menu->setLayout( items );

		return 0;
	}

	int setMenuItemVisible( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		GameMenuItem *item = (GameMenuItem*)lua_touserdata( L, 2 );
		bool visible = lua_toboolean( L, 3 );

		item->setVisible( visible );
		menu->resize();

		return 0;
	}

	int restoreMenu( lua_State *L )
	{
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 1 );
		for( vector<GameMenuItem*>::iterator it = menu->getItems().begin(); it != menu->getItems().end(); ++it )
		{
			GameMenuItem *gmi = *it;
			gmi->setVisible( true );
		}
		menu->resize();

		return 0;
	}

	int newOverlay( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		GameMenu *menu = new GameMenu();
		game->menuAssetManager.addMenu( menu );

		lua_pushlightuserdata( L, menu );

		return 1;
	}

	int disposeMenu( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		GameMenu *menu = (GameMenu*)lua_touserdata( L, 2 );
		game->menuAssetManager.removeMenu( menu );

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Menu_new", newMenu );
		lua::registerLuacFunction( L, "Menu_addItem", addItem );
		lua::registerLuacFunction( L, "Menu_setShader", setShader );
		lua::registerLuacFunction( L, "Menu_setItemShader", setItemShader );
		lua::registerLuacFunction( L, "Menu_setFont", setFont );
		lua::registerLuacFunction( L, "Menu_build", build );
		lua::registerLuacFunction( L, "Menu_setSize", setSize );
		lua::registerLuacFunction( L, "Menu_setPosition", setPosition );
		lua::registerLuacFunction( L, "Menu_setVisible", setVisible );
		lua::registerLuacFunction( L, "Menu_setCursorPosition", setCursorPosition );
		lua::registerLuacFunction( L, "Menu_setLayout", setLayout );
		lua::registerLuacFunction( L, "Menu_setItemVisible", setMenuItemVisible );
		lua::registerLuacFunction( L, "Menu_restore", restoreMenu );
		lua::registerLuacFunction( L, "Overlay_new", newOverlay );
		lua::registerLuacFunction( L, "Menu_dispose", disposeMenu );
	}

}