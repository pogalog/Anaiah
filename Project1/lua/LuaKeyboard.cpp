#include "LuaKeyboard.h"

#include <iostream>

using namespace std;

namespace lua_keyboard
{

	LuaKeyboard::LuaKeyboard( lua_State *L )
		:L(L)
	{

	}


	void LuaKeyboard::keyPressed( Keyboard *kb, const char key )
	{
		lua_getglobal( L, "keyPressed" );
		lua_pushlstring( L, &key, 1 );
		lua_call( L, 1, 0 );
	}

	void LuaKeyboard::keyReleased( Keyboard *kb, const char key )
	{
		lua_getglobal( L, "keyReleased" );
		lua_pushlstring( L, &key, 1 );
		lua_call( L, 1, 0 );
	}

	void LuaKeyboard::keyTyped( Keyboard *kb, const char key )
	{

	}

}