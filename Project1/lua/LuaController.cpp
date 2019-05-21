#include "LuaController.h"
#include "input/CXBOXController.h"
#include <iostream>



namespace lua_controller
{
	using namespace std;

	LuaController::LuaController( lua_State *L )
		:L( L )
	{

	}

	int LuaController::setDigitalButtonIDs( lua_State *L )
	{
		lua_pushnumber( L, XINPUT_GAMEPAD_A );
		lua_pushnumber( L, XINPUT_GAMEPAD_B );
		lua_pushnumber( L, XINPUT_GAMEPAD_X );
		lua_pushnumber( L, XINPUT_GAMEPAD_Y );
		lua_pushnumber( L, XINPUT_GAMEPAD_START );
		lua_pushnumber( L, XINPUT_GAMEPAD_BACK );
		lua_pushnumber( L, XINPUT_GAMEPAD_LEFT_SHOULDER );
		lua_pushnumber( L, XINPUT_GAMEPAD_RIGHT_SHOULDER );
		lua_pushnumber( L, XINPUT_GAMEPAD_DPAD_UP );
		lua_pushnumber( L, XINPUT_GAMEPAD_DPAD_DOWN );
		lua_pushnumber( L, XINPUT_GAMEPAD_DPAD_LEFT );
		lua_pushnumber( L, XINPUT_GAMEPAD_DPAD_RIGHT );
		lua_pushnumber( L, XINPUT_GAMEPAD_LEFT_THUMB );
		lua_pushnumber( L, XINPUT_GAMEPAD_RIGHT_THUMB );
		return 14;
	}

	void LuaController::registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Controller_setDigitalButtonIDs", setDigitalButtonIDs );
	}

	void LuaController::controllerConnected( CXBOXController *controller )
	{
		lua_getglobal( L, "controllerConnected" );
		
		lua_pushlightuserdata( L, controller );
		lua_call( L, 1, 0 );
	}

	void LuaController::controllerDisconnected( CXBOXController *controller )
	{
		lua_getglobal( L, "controllerDisconnected" );
		lua_pushlightuserdata( L, controller );
		lua_call( L, 1, 0 );
	}

	void LuaController::digitalButtonStateChanged( CXBOXController *controller )
	{
		// determine which button was pressed
		// send the event to the GameInstance
		XINPUT_GAMEPAD &gamepad = controller->GetNewPad();
		XINPUT_GAMEPAD &gamepad0 = controller->GetOldPad();
		WORD buttons = gamepad.wButtons;
		WORD buttons0 = gamepad0.wButtons;
		int change = (int)buttons - (int)buttons0;

		lua_getglobal( L, "digitalButton" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, change );
		lua_call( L, 2, 0 );
	}

	void LuaController::leftTriggerStateChanged( CXBOXController *controller )
	{
		lua_getglobal( L, "leftTrigger" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().bLeftTrigger );
		lua_call( L, 2, 0 );
	}

	void LuaController::rightTriggerStateChanged( CXBOXController *controller )
	{
		lua_getglobal( L, "rightTrigger" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().bRightTrigger );
		lua_call( L, 2, 0 );
	}

	void LuaController::leftAnalogMovedX( CXBOXController *controller )
	{
		lua_getglobal( L, "leftStickX" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().sThumbLX );
		lua_call( L, 2, 0 );
	}

	void LuaController::leftAnalogMovedY( CXBOXController *controller )
	{
		lua_getglobal( L, "leftStickY" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().sThumbLY );
		lua_call( L, 2, 0 );
	}

	void LuaController::rightAnalogMovedX( CXBOXController *controller )
	{
		lua_getglobal( L, "rightStickX" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().sThumbRX );
		lua_call( L, 2, 0 );
	}

	void LuaController::rightAnalogMovedY( CXBOXController *controller )
	{
		lua_getglobal( L, "rightStickY" );
		lua_pushlightuserdata( L, controller );
		lua_pushnumber( L, controller->GetNewPad().sThumbRY );
		lua_call( L, 2, 0 );
	}
}
