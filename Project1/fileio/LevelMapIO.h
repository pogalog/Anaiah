#pragma once


#include <string>

#include "game/LevelMap.h"
#include "lua/lua_util.h"


class LevelMapIO
{
public:
	
	static LevelMap* readLevelMap( std::string &filename, lua_State *L );
};

