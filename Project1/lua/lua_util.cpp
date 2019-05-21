#include "lua_util.h"

#include <cstdio>
#include <iostream>
#include <string>


#include "render/Uniform.h"
#include <vector>

using namespace std;
using namespace glm;

namespace lua
{

	void pushKey( lua_State*, lua_State* );

	void copyGameState( lua_State *L_src, lua_State *L_dest, int index )
	{
		lua_newtable( L_dest );
		lua_pushnil( L_src );

		while( lua_next( L_src, index ) )
		{
			int type = lua_type( L_src, -1 );

			switch( type )
			{
				case LUA_TBOOLEAN:
				{
					pushKey( L_src, L_dest );
					bool val = lua_toboolean( L_src, -1 );
					string boolVal = val ? "true" : "false";
					lua_pushboolean( L_dest, val );
					lua_settable( L_dest, -3 );
					break;
				}
				case LUA_TNUMBER:
				{
					pushKey( L_src, L_dest );
					double val = (double)lua_tonumber( L_src, -1 );
					lua_pushnumber( L_dest, val );
					lua_settable( L_dest, -3 );
					break;
				}
				case LUA_TSTRING:
				{
					pushKey( L_src, L_dest );
					const char *val = lua_tostring( L_src, -1 );
					lua_pushstring( L_dest, val );
					lua_settable( L_dest, -3 );
					break;
				}
				case LUA_TTABLE:
				{
					pushKey( L_src, L_dest );
					// need to recursively store stuff in the new table
					copyGameState( L_src, L_dest, lua_gettop( L_src ) );
					lua_settable( L_dest, -3 );
					break;
				}
				default: break;
			}
			lua_pop( L_src, 1 );
		}
	}

	void pushKey( lua_State *L_src, lua_State *L_dest )
	{
		if( lua_isnumber( L_src, -2 ) )
		{
			float key = lua_tonumber( L_src, -2 );
			lua_pushnumber( L_dest, key );
		}
		else
		{
			const char *key = lua_tostring( L_src, -2 );
			lua_pushstring( L_dest, key );
		}
	}

	const char* getIndent( int level )
	{
		string indent = string();
		for( int i = 0; i < level; ++i )
		{
			indent.append( "\t" );
		}
		return indent.c_str();
	}



	int retrieveInt( lua_State *L, int index )
	{
		return (int)lua_tonumber( L, index );
	}

	float retrieveFloat( lua_State *L, int index )
	{
		return (float)lua_tonumber( L, index );
	}

	double retrieveDouble( lua_State *L, int index )
	{
		return (double)lua_tonumber( L, index );
	}

	glm::vec2 retrieveVec2( lua_State *L, int table )
	{
		bool x = false;
		bool y = false;
		glm::vec2 v;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			const char *key = lua_tostring( L, -2 );
			if( std::strcmp( key, "x" ) == 0 )
			{
				v.x = (float)lua_tonumber( L, -1 );
				x = true;
			}
			else if( std::strcmp( key, "y" ) == 0 )
			{
				v.y = (float)lua_tonumber( L, -1 );
				y = true;
			}
			if( x && y ) return v;

			lua_pop( L, 1 );
		}
		return v;
	}

	glm::ivec2 retrieveIVec2( lua_State *L, int table )
	{
		bool x = false;
		bool y = false;
		glm::ivec2 v;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			const char *key = lua_tostring( L, -2 );
			if( std::strcmp( key, "x" ) == 0 )
			{
				v.x = (int)lua_tonumber( L, -1 );
				x = true;
			}
			else if( std::strcmp( key, "y" ) == 0 )
			{
				v.y = (int)lua_tonumber( L, -1 );
				y = true;
			}
			if( x && y ) return v;

			lua_pop( L, 1 );
		}
		return v;
	}

	vec3 retrieveVec3( lua_State *L, int table )
	{
		bool x = false;
		bool y = false;
		bool z = false;
		vec3 v;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			const char *key = lua_tostring( L, -2 );
			if( std::strcmp( key, "x" ) == 0 )
			{
				v.x = (float)lua_tonumber( L, -1 );
				x = true;
			}
			else if( std::strcmp( key, "y" ) == 0 )
			{
				v.y = (float)lua_tonumber( L, -1 );
				y = true;
			}
			else if( std::strcmp( key , "z" ) == 0 )
			{
				v.z = (float)lua_tonumber( L, -1 );
				z = true;
			}
			if( x && y && z ) return v;

			lua_pop( L, 1 );
		}
		return v;
	}

	vec4 retrieveVec4( lua_State *L, int table )
	{
		bool x = false;
		bool y = false;
		bool z = false;
		bool w = false;
		vec4 v;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			const char *key = lua_tostring( L, -2 );
			if( std::strcmp( key, "x" ) == 0 )
			{
				v.x = (float)lua_tonumber( L, -1 );
				x = true;
			}
			else if( std::strcmp( key, "y" ) == 0 )
			{
				v.y = (float)lua_tonumber( L, -1 );
				y = true;
			}
			else if( std::strcmp( key, "z" ) == 0 )
			{
				v.z = (float)lua_tonumber( L, -1 );
				z = true;
			}
			else if( std::strcmp( key, "w" ) == 0 )
			{
				v.w = (float)lua_tonumber( L, -1 );
				w = true;
			}
			if( x && y && z && w ) return v;

			lua_pop( L, 1 );
		}
		return v;
	}


	mat3 retrieveMat3( lua_State *L, int table )
	{
		float data[9];
		int i = 0;

		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			data[i] = (float)lua_tonumber( L, -1 );
			lua_pop( L, 1 );
		}

		return glm::mat3( *data );
	}


	mat4 retrieveMat4( lua_State *L, int table )
	{
		float data[16];
		int i = 0;

		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			data[i] = (float)lua_tonumber( L, -1 );
			lua_pop( L, 1 );
		}

		return glm::mat4( *data );
	}


	Color retrieveColor( lua_State *L, int table )
	{
		bool r = false;
		bool g = false;
		bool b = false;
		bool a = false;
		Color c;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			const char *key = lua_tostring( L, -2 );
			if( std::strcmp( key, "r" ) == 0 )
			{
				c.r( (float)lua_tonumber( L, -1 ) );
				r = true;
			}
			else if( std::strcmp( key, "g" ) == 0 )
			{
				c.g( (float)lua_tonumber( L, -1 ) );
				g = true;
			}
			else if( std::strcmp( key, "b" ) == 0 )
			{
				c.b( (float)lua_tonumber( L, -1 ) );
				b = true;
			}
			else if( std::strcmp( key, "a" ) == 0 )
			{
				c.a( (float)lua_tonumber( L, -1 ) );
				a = true;
			}
			if( r && g && b && a ) return c;

			lua_pop( L, 1 );
		}
		return c;
	}

	string retrieveString( lua_State *L, int index )
	{
		return string( lua_tostring( L, index ) );
	}

	vector<void*> retrieveUserdata( lua_State *L, int table )
	{
		vector<void*> data;
		lua_pushnil( L );
		while( lua_next( L, table ) )
		{
			void *ud = lua_touserdata( L, -1 );
			data.push_back( ud );
			lua_pop( L, 1 );
		}

		return data;
	}


	void storeVec3( lua_State *L, vec3 v )
	{
		lua_createtable( L, 0, 3 );
		lua_pushstring( L, "x" );
		lua_pushnumber( L, v.x );
		lua_settable( L, -3 );
		lua_pushstring( L, "y" );
		lua_pushnumber( L, v.y );
		lua_settable( L, -3 );
		lua_pushstring( L, "z" );
		lua_pushnumber( L, v.z );
		lua_settable( L, -3 );
	}

	void storeMat4( lua_State *L, mat4 m )
	{
		lua_createtable( L, 0, 3 );
		for( int i = 0; i < 16; ++i )
		{
			lua_pushnumber( L, i + 1 );
			lua_pushnumber( L, m[i % 4][i / 4] );
			lua_settable( L, -3 );
		}
	}


	void printTable( lua_State *L, int index )
	{
		lua_pushnil( L );
		while( lua_next( L, index ) )
		{
			int type = lua_type( L, -1 );
			const char *key = lua_tostring( L, -2 );
			switch( type )
			{
				case LUA_TSTRING:
				{
					const char *val = lua_tostring( L, -1 );
					printf( "%s: %s\n", key, val );
					break;
				}
				case LUA_TBOOLEAN:
				{
					string boolVal = lua_toboolean( L, -1 ) ? "true" : "false";
					printf( "%s: %s\n", key, boolVal.c_str() );
					break;
				}
				case LUA_TNUMBER:
				{
					printf( "%s: %g\n", key, lua_tonumber( L, -1 ) );
					break;
				}
				case LUA_TFUNCTION:
				{
					const char *val = lua_typename( L, type );
					printf( "%s: %s\n", key, val );
					break;
				}
				case LUA_TTABLE:
				{
					const char *val = lua_typename( L, type );
					printf( "%s: %s\n", key, val );
					printTable( L, lua_gettop( L ) );
					break;
				}
			}
			lua_pop( L, 1 );
		}
	}

	void printStack( lua_State *L )
	{
		printf( "Print Lua Stack\n" );
		int top = lua_gettop( L );

		int indentLevel = 0;

		for( int i = 1; i <= top; ++i )
		{
			int type = lua_type( L, i );
			switch( type )
			{
				case LUA_TSTRING:
				{
					const char *indent = getIndent( indentLevel );
					printf( "%sLuaString: %s\n", indent, lua_tostring( L, i ) );
					break;
				}
				case LUA_TBOOLEAN:
				{
					const char *indent = getIndent( indentLevel );
					printf( lua_toboolean( L, i ) ? "%strue\n" : "%sfalse\n", indent );
					break;
				}
				case LUA_TNUMBER:
				{
					const char *indent = getIndent( indentLevel );
					printf( "%sLuaNumber: %g\n", indent, lua_tonumber( L, i ) );
					break;
				}
				case LUA_TTABLE:
				{
					printTable( L, i );

					++indentLevel;
					break;
				}
				default:
				{
					const char *indent = getIndent( indentLevel );
					printf( "%sOther\n", indent );
					break;
				}
			}
		}
	}

	

	double popDouble( lua_State *L )
	{
		double val = lua_tonumber( L, -1 );
		lua_pop( L, 1 );
		return val;
	}



	void registerLuacFunction( lua_State *L, const char *luaName, lua_CFunction cfunc )
	{
		lua_register( L, luaName, cfunc );
	}


}

