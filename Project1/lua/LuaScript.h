/*
 * LuaScript.h
 *
 *  Created on: Mar 14, 2016
 *      Author: pogal
 */

#ifndef LUA_LUASCRIPT_H_
#define LUA_LUASCRIPT_H_

#include <string>
#include <vector>

extern "C"
{
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

class LuaScript
{
public:
	LuaScript( lua_State *L, std::string filename );
	~LuaScript();
	
	void execute() const;
	
	std::string filename;
	std::string source;
	std::string name;
	
	lua_State *L;
};

// non-member functions
//std::vector<LuaVar> lua_callFunction( lua_State *L, std::string functionName, std::vector<LuaVar> *argList );
//std::vector<LuaVar> lua_callFunction( lua_State *L, const char *functionName, std::vector<LuaVar> *argList );


#endif /* LUA_LUASCRIPT_H_ */
