#include "GameInstance.h"
#include "input/CXBOXController.h"
#include "lua/lua_util.h"

#include <iostream>
#include <windows.h>

using namespace std;

GameInstance::GameInstance( ControllerPort *controllerPort, lua_State *mainState, AudioManager *audioManager )
	:cport(controllerPort), mainState(mainState), audioManager(audioManager), renderer(this)
{
	controllerPort->listeners.push_back( this );
	gameState = luaL_newstate();
}

GameInstance::~GameInstance()
{

}

void GameInstance::executeAI( string data )
{
	// create Lua state and set it up for operation
	lua_State *aiState = luaL_newstate();

	luaL_openlibs( aiState );
	luaL_dofile( aiState, "resource/lua/game/ai/init.lua" );

	// transfer data from gameState to aiState
	lua_getglobal( aiState, "storeAIData" );
	lua_pushlstring( aiState, data.c_str(), data.length() );
	lua_call( aiState, 1, 0 );

	lua_getglobal( aiState, "processTask" );
	lua_call( aiState, 0, 1 );
	bool keep = lua_toboolean( aiState, 1 );
	if( !keep )
	{
		lua_close( aiState );
		return;
	}

	// store the aiState in the list, synchronized for thread safety
	aiMutex.lock();
	aiStates.push_back( aiState );
	aiMutex.unlock();
}

string GameInstance::fetchAIResult()
{
	string data;
	aiMutex.lock();
	if( aiStates.size() > 0 )
	{
		lua_State *aiState = aiStates.front();
		lua_getglobal( aiState, "getResult" );
		lua_call( aiState, 0, 2 );
		size_t len = lua_tonumber( aiState, -2 );
		data = string( lua_tolstring( aiState, -1, &len ), len );
		aiStates.pop_front();
		lua_close( aiState );
	}
	aiMutex.unlock();

	return data;
}

int GameInstance::lua_init()
{
	lua_getglobal( gameState, "Game_init" );
	lua_pushnumber( gameState, timer.elapsed().wall );
	lua_call( gameState, 1, 0 );
	return 0;
}

void GameInstance::spawnAIThread( string data )
{
	// spawn a new thread, run AI processing on new thread
	boost::thread( boost::bind( &GameInstance::executeAI, this, data ) );
}

void GameInstance::update()
{
	// update the global clock
	globalTime = timer.elapsed().wall;

	cport->checkController();
	cport->checkControllerState();
}


void GameInstance::updateLogic()
{
	// call into Lua for game logic
	lua_getglobal( gameState, "Game_main" );
	lua_pushnumber( gameState, globalTime );
	lua_call( gameState, 1, 0 );
}


// ControllerListener
void GameInstance::controllerConnected( CXBOXController *controller )
{

}

void GameInstance::controllerDisconnected( CXBOXController *controller )
{

}

void GameInstance::digitalButtonStateChanged( CXBOXController *controller )
{
	// determine which button was pressed
	// send the event to the GameInstance
	XINPUT_GAMEPAD &gamepad = controller->GetNewPad();
	XINPUT_GAMEPAD &gamepad0 = controller->GetOldPad();
	WORD buttons = gamepad.wButtons;
	WORD buttons0 = gamepad0.wButtons;
	int change = (int)buttons - (int)buttons0;


}

void GameInstance::leftTriggerStateChanged( CXBOXController *controller )
{

}

void GameInstance::rightTriggerStateChanged( CXBOXController *controller )
{

}

void GameInstance::leftAnalogMovedX( CXBOXController *controller )
{

}

void GameInstance::leftAnalogMovedY( CXBOXController *controller )
{

}

void GameInstance::rightAnalogMovedX( CXBOXController *controller )
{

}

void GameInstance::rightAnalogMovedY( CXBOXController *controller )
{

}