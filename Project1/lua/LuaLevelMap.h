#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"
#include "game/TileRange.h"


namespace lua_levelmap
{
	using namespace std;
	using namespace glm;

	int addDebugModel( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Model *model = (Model*)lua_touserdata( L, 2 );
		if( model == NULL ) return 0;
		game->levelMap->debugModels.push_back( model );

		return 0;
	}

	int loadMap( lua_State *L )
	{
		string filename = string( lua_tostring( L, 1 ) );
		LevelMap *map = LevelMapIO::readLevelMap( filename, L );

		return 1;
	}

	// Grid::setShader
	int setGridShader( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		game->levelMap->grid.shader = shader;
		return 0;
	}

	int setRangeShader( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		game->levelMap->grid.rangeShader = shader;
		return 0;
	}


	int getMainLuaScript( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		lua_pushstring( L, game->levelMap->lua_MainName.c_str() );
		return 1;
	}

	int moveUnit( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Unit *unit = (Unit*)lua_touserdata( L, 2 );
		unit->coexist = false;
		ivec2 address = lua::retrieveIVec2( L, 3 );

		bool success = game->levelMap->moveUnit( unit, address );
		lua_pushboolean( L, success );
		return 1;
	}

	int moveUnitCoexist( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Unit *unit = (Unit*)lua_touserdata( L, 2 );
		ivec2 address = lua::retrieveIVec2( L, 3 );
		ivec2 coaddress = lua::retrieveIVec2( L, 4 );
		unit->coexist = true;

		bool success = game->levelMap->moveUnit( unit, address );
		game->levelMap->setUnitCoexist( unit, coaddress );
		lua_pushboolean( L, success );
		return 1;
	}


	// Grid operations
	int findPath( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Unit *unit = (Unit*)lua_touserdata( L, 2 );
		game->levelMap->grid.findPath( unit );

		return 0;
	}

	int addPFTarget( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		MapTile *tile = (MapTile*)lua_touserdata( L, 2 );
		game->levelMap->grid.addPFTarget( tile );

		return 0;
	}


	int createNewRange( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		TileRange *range = new TileRange();
		game->levelMap->grid.addRange( range );

		lua_pushlightuserdata( L, range );
		return 1;
	}

	int buildRange( lua_State *L )
	{
		TileRange *range = (TileRange*)lua_touserdata( L, 1 );
		vector<void*> pointers = lua::retrieveUserdata( L, 2 );
		vector<MapTile*> &tiles = range->tiles;
		tiles.clear();
		for( vector<void*>::iterator it = pointers.begin(); it != pointers.end(); ++it )
		{
			void *p = *it;
			MapTile *tile = (MapTile*)p;
			tiles.push_back( tile );
		}
		range->buildModel();

		lua_pushlightuserdata( L, &range->model );
		return 1;
	}


	int getTilePointers( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		MapGrid &grid = game->levelMap->grid;

		int index = 1;
		lua_newtable( L );
		for( vector<GridRow>::iterator grit = grid.rows.begin(); grit != grid.rows.end(); ++grit )
		{
			GridRow &row = *grit;
			for( vector<MapTile>::iterator tit = row.tiles.begin(); tit != row.tiles.end(); ++tit )
			{
				MapTile &tile = *tit;
				lua_pushnumber( L, index++ );
				lua_pushlightuserdata( L, &tile );
				lua_settable( L, -3 );
			}
		}
		return 1;
	}

	int clearPFMarkings( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		MapGrid &grid = game->levelMap->grid;
		grid.clearPathfinding();

		return 0;
	}

	int buildPathFindModel( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		game->levelMap->grid.buildPathFindModel();

		return 0;
	}

	int setPathFindVisible( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		bool visible = (bool)lua_toboolean( L, 2 );
		game->levelMap->grid.getPathFindModel().visible = visible;

		return 0;
	}



	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "LevelMap_addDebugModel", addDebugModel );
		lua::registerLuacFunction( L, "LevelMap_load", loadMap );
		lua::registerLuacFunction( L, "LevelMap_setGridShader", setGridShader );
		lua::registerLuacFunction( L, "LevelMap_setRangeShader", setRangeShader );
		lua::registerLuacFunction( L, "LevelMap_getMainLuaScript", getMainLuaScript );
		lua::registerLuacFunction( L, "LevelMap_moveUnit", moveUnit );
		lua::registerLuacFunction( L, "LevelMap_coexistUnit", moveUnitCoexist );
		lua::registerLuacFunction( L, "Grid_findPath", findPath );
		lua::registerLuacFunction( L, "Grid_addPFTarget", addPFTarget );
		lua::registerLuacFunction( L, "Grid_getTilePointers", getTilePointers );
		lua::registerLuacFunction( L, "Grid_clearPFMarkings", clearPFMarkings );
		lua::registerLuacFunction( L, "Range_new", createNewRange );
		lua::registerLuacFunction( L, "Range_build", buildRange );
		lua::registerLuacFunction( L, "LevelMap_buildPathFindModel", buildPathFindModel );
		lua::registerLuacFunction( L, "LevelMap_setPathFindVisible", setPathFindVisible );
	}



}