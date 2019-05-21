#pragma once


#include "lua/lua_util.h"
#include "game/AssetManager.h"
#include "game/GameInstance.h"


namespace lua_asset
{
	using namespace std;


	int asyncLoad( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		AssetManager &am = game->assetManager;

		return 0;
	}

	int syncLoad( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		AssetManager &am = game->assetManager;

		return 1;
	}

	int retrieve( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		AssetManager &am = game->assetManager;

		return 1;
	}
	

	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Asset_asyncLoad", asyncLoad );
		lua::registerLuacFunction( L, "Asset_syncLoad", syncLoad );
		lua::registerLuacFunction( L, "Asset_retrieve", retrieve );
	}
}
