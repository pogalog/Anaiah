/*
 * LuaScript.cpp
 *
 *  Created on: Mar 14, 2016
 *      Author: pogal
 */

#include "LuaScript.h"
#include <cstdarg>
#include <iostream>


extern "C"
{
#include "lualib.h"
#include "lauxlib.h"
}

//#include <luabind/luabind.hpp>


LuaScript::LuaScript( lua_State *L, std::string filename )
{
	this->L = L;
	this->filename = filename;
	//luabind::open( L );
}

LuaScript::~LuaScript()
{
}


void LuaScript::execute() const
{
	luaL_dofile( L, filename.c_str() );
}

//std::vector<LuaVar> LuaScript::callFunction( std::string functionName, std::vector<LuaVar> *argList ) const
//{
//	return lua_callFunction( L, functionName, argList );
//}
//
//
//// non-member functions
//std::vector<LuaVar> lua_callFunction( lua_State *L, std::string functionName, std::vector<LuaVar> *argList )
//{
//	return lua_callFunction( L, functionName.c_str(), argList );
//}
//std::vector<LuaVar> lua_callFunction( lua_State *L, const char *functionName, std::vector<LuaVar> *argList )
//{
//	lua_getglobal( L, functionName );
//	if( argList )
//	{
//		lua_call( L, argList->size(), 1 );
//	}
//	else
//	{
//		lua_call( L, 0, 1 );
//	}
//	
//	std::vector<LuaVar> ret;
//	
//	int k = lua_gettop( L );
//	
//	// determine the type
//	if( lua_isboolean( L, k ) )
//	{
//		LuaVar lv = lua_toboolean( L, k );
//		lv.type = LuaVar::BOOL;
//		ret.push_back( lv );
//		return ret;
//	}
//	if( lua_isnumber( L, k ) )
//	{
//		LuaVar lv = lua_tonumber( L, k );
//		std::cout << "A " << lv.doubleVal << std::endl;
//		lv.type = LuaVar::DOUBLE;
//		ret.push_back( lv );
//		return ret;
//	}
//	if( lua_isstring( L, k ) )
//	{
//		LuaVar lv = lua_tostring( L, k );
//		lv.type = LuaVar::STRING;
//		ret.push_back( lv );
//		return ret;
//	}
//	if( lua_istable( L, k ) )
//	{
//		lua_pushnil( L ); 
//		
//		while( lua_next( L, k ) != 0 )
//		{
////			int key = lua_tonumber( L, 2 );
//			// determine the type
//			if( lua_isboolean( L, 3 ) )
//			{
//				LuaVar lv = lua_toboolean( L, 3 );
//				lv.type = LuaVar::BOOL;
//				ret.push_back( lv );
//				lua_pop( L, 1 );
//				continue;
//			}
//			if( lua_isnumber( L, 3 ) )
//			{
//				LuaVar lv = lua_tonumber( L, 3 );
//				lv.type = LuaVar::DOUBLE;
//				ret.push_back( lv );
//				lua_pop( L, 1 );
//				continue;
//			}
//			if( lua_isstring( L, 3 ) )
//			{
//				LuaVar lv = lua_tostring( L, 3 );
//				lv.type = LuaVar::STRING;
//				ret.push_back( lv );
//				lua_pop( L, 1 );
//				continue;
//			}
//		}
//	}
//	
//	return ret;
//}

