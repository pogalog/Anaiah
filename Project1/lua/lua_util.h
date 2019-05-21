#pragma once

extern "C"
{
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include <string>
#include <vector>
#include <glm/glm.hpp>

#include "render/Color.h"

namespace lua
{
	void copyGameState( lua_State *L_src, lua_State *L_dest, int index );

	double popDouble( lua_State *L );
	

	void registerLuacFunction( lua_State *L, const char *luaName, lua_CFunction cfunc );

	int retrieveInt( lua_State *L, int index );
	float retrieveFloat( lua_State *L, int index );
	double retrieveDouble( lua_State *L, int index );
	glm::vec2 retrieveVec2( lua_State *L, int table );
	glm::ivec2 retrieveIVec2( lua_State *L, int table );
	glm::vec3 retrieveVec3( lua_State *L, int table );
	glm::vec4 retrieveVec4( lua_State *L, int table );
	glm::mat3 retrieveMat3( lua_State *L, int table );
	glm::mat4 retrieveMat4( lua_State *L, int table );
	Color retrieveColor( lua_State *L, int table );
	std::string retrieveString( lua_State *L, int index );
	std::vector<void*> retrieveUserdata( lua_State *L, int index );

	void storeVec3( lua_State *L, glm::vec3 v );
	void storeMat4( lua_State *L, glm::mat4 m );

	void printTable( lua_State *L, int index );
	void printStack( lua_State *L );
}

