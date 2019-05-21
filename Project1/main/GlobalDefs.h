#pragma once

#include "lua/LuaController.h"
#include "lua/LuaKeyboard.h"
#include "game/GameInstance.h"
#include "render/IntroRenderer.h"



namespace defs
{
	int RenderMode = 0;
	IntroRenderer *intro;

	GameInstance *game;
	AudioManager *audio;
	Keyboard *keyboard;
	CXBOXController* Player1;
	ControllerPort *port;
	lua_State *lua_mainState;

	lua_controller::LuaController *mainController;
	lua_controller::LuaController *gameController;
	lua_keyboard::LuaKeyboard *mainKeyboard;
	lua_keyboard::LuaKeyboard *gameKeyboard;
}
