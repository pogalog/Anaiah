#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"
#include "ui/Overlay.h"
#include "ui/OverlayItem.h"


namespace lua_overlay
{
	using namespace std;
	using namespace glm;


	int newOverlay( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Overlay *overlay = new Overlay();
		game->overlayAssetManager.addOverlay( overlay );

		lua_pushlightuserdata( L, overlay );
		return 1;
	}

	int addItem( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		string text = lua::retrieveString( L, 2 );
		OverlayItem *item = overlay->addOverlayItem( text );

		lua_pushlightuserdata( L, item );
		return 1;
	}

	int setShader( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		overlay->setShader( shader );

		return 0;
	}

	int setItemShader( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		overlay->setItemShader( shader );

		return 0;
	}

	int setItemColor( lua_State *L )
	{
		OverlayItem *item = (OverlayItem*)lua_touserdata( L, 1 );
		Color color = lua::retrieveColor( L, 2 );
		item->getText()->setColor( color );

		return 0;
	}

	int setFont( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		FontMap *font = (FontMap*)lua_touserdata( L, 2 );
		overlay->setFont( font );

		return 0;
	}

	int build( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		overlay->buildModel();

		return 0;
	}

	int setSize( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		vec2 size = lua::retrieveVec2( L, 2 );
		overlay->setSize( size );

		return 0;
	}

	int setPosition( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		vec2 position = lua::retrieveVec2( L, 2 );
		overlay->setPosition( position );

		return 0;
	}

	int setVisible( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		bool visible = lua_toboolean( L, 2 );
		overlay->setVisible( visible );

		return 0;
	}


	int setLayout( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		vector<void*> ud = lua::retrieveUserdata( L, 2 );
		vector<OverlayItem*> items;
		for( vector<void*>::iterator it = ud.begin(); it != ud.end(); ++it )
		{
			OverlayItem *item = (OverlayItem*)*it;
			items.push_back( item );
		}
		overlay->setLayout( items );

		return 0;
	}

	int setOverlayItemVisible( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		OverlayItem *item = (OverlayItem*)lua_touserdata( L, 2 );
		bool visible = lua_toboolean( L, 3 );

		item->setVisible( visible );
		overlay->resize();

		return 0;
	}

	int restoreOverlay( lua_State *L )
	{
		Overlay *overlay = (Overlay*)lua_touserdata( L, 1 );
		for( vector<OverlayItem*>::iterator it = overlay->getItems().begin(); it != overlay->getItems().end(); ++it )
		{
			OverlayItem *gmi = *it;
			gmi->setVisible( true );
		}
		overlay->resize();

		return 0;
	}

	int disposeOverlay( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Overlay *overlay = (Overlay*)lua_touserdata( L, 2 );
		game->overlayAssetManager.removeOverlay( overlay );

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Overlay_new", newOverlay );
		lua::registerLuacFunction( L, "Overlay_addItem", addItem );
		lua::registerLuacFunction( L, "Overlay_setShader", setShader );
		lua::registerLuacFunction( L, "Overlay_setItemShader", setItemShader );
		lua::registerLuacFunction( L, "Overlay_setItemColor", setItemColor );
		lua::registerLuacFunction( L, "Overlay_setFont", setFont );
		lua::registerLuacFunction( L, "Overlay_build", build );
		lua::registerLuacFunction( L, "Overlay_setSize", setSize );
		lua::registerLuacFunction( L, "Overlay_setPosition", setPosition );
		lua::registerLuacFunction( L, "Overlay_setVisible", setVisible );
		lua::registerLuacFunction( L, "Overlay_setLayout", setLayout );
		lua::registerLuacFunction( L, "Overlay_setItemVisible", setOverlayItemVisible );
		lua::registerLuacFunction( L, "Overlay_restore", restoreOverlay );
		lua::registerLuacFunction( L, "Overlay_dispose", disposeOverlay );
	}

}