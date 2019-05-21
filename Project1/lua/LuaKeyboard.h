#pragma once


#include "lua/lua_util.h"
#include "input/Keyboard.h"
#include "input/KeyboardListener.h"


namespace lua_keyboard
{
	using namespace std;


	class LuaKeyboard : public KeyboardListener
	{
	public:
		LuaKeyboard( lua_State *L );

		void keyPressed( Keyboard*, const char key );
		void keyReleased( Keyboard*, const char key );
		void keyTyped( Keyboard*, const char key );

		lua_State *L;
	};
}