#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"
#include "fileio/LevelMapIO.h"
#include "main/GlobalDefs.h"
#include <boost/timer/timer.hpp>

#include "lua/LuaCamera.h"
#include "lua/LuaShader.h"
#include "lua/LuaLevelMap.h"
#include "lua/LuaUnit.h"
#include "lua/LuaText.h"
#include "lua/LuaMenu.h"
#include "lua/LuaController.h"
#include "lua/LuaModel.h"
#include "lua/LuaNetwork.h"
#include "lua/LuaOverlay.h"
#include "lua/LuaScene.h"
#include "lua/LuaRender.h"
#include "lua/LuaAsset.h"


namespace lua_gameinstance
{
	using namespace std;
	using namespace glm;
	using namespace defs;

	void registerFunctions( lua_State *L );


	int getControllerAndAudio( lua_State *L )
	{
		lua_pushlightuserdata( L, port );
		lua_pushlightuserdata( L, audio );
		return 2;
	}

	int createNewGameInstance( lua_State *L )
	{
		ControllerPort *controllerPort = (ControllerPort*)lua_touserdata( L, 1 );
		AudioManager *audioManager = (AudioManager*)lua_touserdata( L, 2 );
		game = new GameInstance( controllerPort, L, audioManager );

		lua_pushlightuserdata( L, game );
		lua_pushlightuserdata( L, game->gameState );
		return 2;
	}


	int registerGameLuacFunctions( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		luaL_openlibs( game->gameState );
		registerFunctions( game->gameState );
		lua_render::registerFunctions( game->gameState );
		lua_shader::registerFunctions( game->gameState );
		lua_levelmap::registerFunctions( game->gameState );
		lua_unit::registerFunctions( game->gameState );
		lua_text::registerFunctions( game->gameState );
		lua_menu::registerFunctions( game->gameState );
		lua_camera::registerFunctions( game->gameState );
		lua_controller::LuaController::registerFunctions( game->gameState );
		lua_model::registerFunctions( game->gameState );
		lua_network::registerFunctions( game->gameState );
		lua_overlay::registerFunctions( game->gameState );
		lua_scene::registerFunctions( game->gameState );
		lua_asset::registerFunctions( game->gameState );

		return 0;
	}

	int feedGameInstance( lua_State *L )
	{
		lua_State *state = (lua_State*)lua_touserdata( L, 1 );
		GameInstance *gi = (GameInstance*)lua_touserdata( L, 2 );
		NetworkNode *network = (NetworkNode*)lua_touserdata( L, 3 );

		lua_getglobal( state, "setGameInstance" );
		lua_pushlightuserdata( state, gi );
		if( network != NULL )
		{
			lua_pushlightuserdata( state, network );
		}
		else
		{
			lua_pushnil( state );
		}
		lua_call( state, 2, 0 );

		gi->lua_init();

		return 0;
	}

	int doFile( lua_State *L )
	{
		lua_State *state = (lua_State*)lua_touserdata( L, 1 );
		const char *filename = lua_tostring( L, 2 );
		int error_code = luaL_dofile( state, filename );
		if( error_code > 0 )
		{
			string error = lua::retrieveString( state, -1 );
			cout << "Lua Interpreter Error\n" << error << endl;
		}

		return 0;
	}

	int callFunction( lua_State *L )
	{
		lua_State *state = (lua_State*)lua_touserdata( L, 1 );
		const char *functionName = lua_tostring( L, 2 );
		lua_getglobal( state, functionName );
		lua_call( state, 0, 0 );

		return 0;
	}

	int registerAILuacFunctions( lua_State *L )
	{

		return 0;
	}

	int fetchAIResult( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		string data = game->fetchAIResult();
		lua_pushlstring( L, data.c_str(), data.length() );
		return 1;
	}


	// static LevelMap* LevelMapIO::readLevelMap( std::string &filename ); 
	// also requires a GameInstance* as first parameter
	int readLevelMap( lua_State *L )
	{
		GameInstance *gameInstance = (GameInstance*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		game->levelMap = LevelMapIO::readLevelMap( filename, L );

		// lua_pushlstring( L, buffer, size ) is called inside the LevelMapIO::readLevelMap(...) function
		return 1;
	}



	int getTime( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		boost::timer::cpu_times ct = game->timer.elapsed();
		

		lua_pushnumber( L, ct.user );
		return 1;
	}

	int startAIThread( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		size_t size = lua_tonumber( L, 2 );
		string data = string( lua_tolstring( L, 3, &size ), size );
		game->spawnAIThread( data );

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Main_getControllerAndAudio", getControllerAndAudio );
		lua::registerLuacFunction( L, "Main_createNewGameInstance", createNewGameInstance );
		lua::registerLuacFunction( L, "Game_readLevelMap", readLevelMap );
		lua::registerLuacFunction( L, "Game_registerGameLuacFunctions", registerGameLuacFunctions );
		lua::registerLuacFunction( L, "Game_registerAILuacFunctions", registerAILuacFunctions );
		lua::registerLuacFunction( L, "Game_fetchAIResult", fetchAIResult );
		lua::registerLuacFunction( L, "Lua_doFile", doFile );
		lua::registerLuacFunction( L, "Lua_callFunction", callFunction );
		lua::registerLuacFunction( L, "Lua_feedGameInstance", feedGameInstance );
		lua::registerLuacFunction( L, "Lua_getTime", getTime );
		lua::registerLuacFunction( L, "Game_startAI", startAIThread );
	}

}