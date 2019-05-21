#pragma once

#include <glm/glm.hpp>

#include "lua/lua_util.h"
#include "input/ControllerPort.h"

namespace lua_controller
{
	using namespace std;
	using namespace glm;


	class LuaController : public ControllerListener
	{
	public:
		LuaController( lua_State *L );
		~LuaController() {}

		static int setDigitalButtonIDs( lua_State *L );
		static void registerFunctions( lua_State *L );

		void controllerConnected( CXBOXController *controller );
		void controllerDisconnected( CXBOXController *controller );
		void digitalButtonStateChanged( CXBOXController *controller );
		void leftTriggerStateChanged( CXBOXController *controller );
		void rightTriggerStateChanged( CXBOXController *controller );
		void leftAnalogMovedX( CXBOXController *controller );
		void leftAnalogMovedY( CXBOXController *controller );
		void rightAnalogMovedX( CXBOXController *controller );
		void rightAnalogMovedY( CXBOXController *controller );

		lua_State *L;
	};

}