#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"

/*
Static utility functions are called by Lua, and pass in a lightuserdata C++ pointer to
the instance of the object. The utility functions then call the member variable counterpart.
The general pattern for incoming parameters is:
Arg0: the lightuserdata C++ pointer to the object
Arg1-n: parameters which are appropriate to the specific functions in question

The format of the data retrieved from the Lua stack will depend upon the type of the data passed
to the member function. If the member function takes primitive data, then these data are read
directly from the stack. If the function takes a pointer or a reference to a C++, then a
lightuserdata is used. If no userdata exist in the Lua reflection of the C++ structure, then the
Lua 'object' is passed as the parameter (i.e. in the case of Vec2, Vec3, etc.).
*/

namespace lua_camera
{
	using namespace std;
	using namespace glm;

	// void Camera::move( const glm::vec3 &movement );
	int move( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;		
		vec3 mv = lua::retrieveVec3( L, 2 );
		camera->move( mv );

		return 0;
	}

	// void Camera::moveTo( const glm::vec3 &position )
	int moveTo( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;
		vec3 pos = lua::retrieveVec3( L, 2 );
		camera->moveTo( pos );

		return 0;
	}

	// void Camera::lookAt( const glm::vec3 &center, const glm::vec3 &up )
	int lookAt( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;

		vec3 center = lua::retrieveVec3( L, 2 );
		vec3 up = lua::retrieveVec3( L, 2 );
		camera->lookAt( center, up );

		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	int lookDownAtTile( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		MapTile *tile = (MapTile*)lua_touserdata( L, 2 );
		Camera *camera = &game->camera;
		if( tile != NULL )
		{
			camera->lookDownAtTile( tile );
		}

		vec3 fv = camera->transform.localY + camera->transform.localZ;
		lua::storeVec3( L, fv );
		return 1;
	}

	int lookDownAtPosition( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		vec3 position = lua::retrieveVec3( L, 2 );
		Camera *camera = &game->camera;
		camera->lookDownAtPosition( position );

		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	// void Camera::rotateX( float angle )
	int rotateX( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;

		float angle = lua::retrieveFloat( L, 2 );
		camera->rotateX( angle );

		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	// void Camera::rotateY( float angle )
	int rotateY( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;

		float angle = lua::retrieveFloat( L, 2 );
		camera->rotateY( angle );

		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	// void Camera::rotateZ( float angle )
	int rotateZ( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;

		float angle = lua::retrieveFloat( L, 2 );
		camera->rotateZ( angle );

		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	int orbitX( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;
		float angle = lua::retrieveFloat( L, 2 );
		camera->orbitX( angle );


		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}

	int orbitY( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Camera *camera = &game->camera;
		float angle = lua::retrieveFloat( L, 2 );
		camera->orbitY( -angle );


		lua::storeVec3( L, camera->transform.localY + camera->transform.localZ );
		return 1;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Camera_move", move );
		lua::registerLuacFunction( L, "Camera_moveTo", moveTo );
		lua::registerLuacFunction( L, "Camera_lookAt", lookAt );
		lua::registerLuacFunction( L, "Camera_lookDownAtTile", lookDownAtTile );
		lua::registerLuacFunction( L, "Camera_lookDownAtPosition", lookDownAtPosition );
		lua::registerLuacFunction( L, "Camera_rotateX", rotateX );
		lua::registerLuacFunction( L, "Camera_rotateY", rotateY );
		lua::registerLuacFunction( L, "Camera_rotateZ", rotateZ );
		lua::registerLuacFunction( L, "Camera_orbitX", orbitX );
		lua::registerLuacFunction( L, "Camera_orbitY", orbitY );
	}

}