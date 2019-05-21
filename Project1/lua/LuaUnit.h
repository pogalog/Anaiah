#pragma once

#include "lua/lua_util.h"
#include "game/GameInstance.h"
#include "fileio/ModelIO.h"


namespace lua_unit
{
	using namespace std;
	using namespace glm;


	// Create a new Unit and add it to the map (requires GameInstance)
	int Unit_new( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Unit *unit = new Unit();
		game->levelMap->addUnit( unit );
		lua_pushlightuserdata( L, unit );
		return 1;
	}

	int setTeamColor( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		vec4 color = lua::retrieveVec4( L, 2 );
		unit->setTeamColor( color );
		return 0;
	}

	int setRingShader( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		unit->ringModel.getPrimaryMesh().setShader( shader );
		return 0;
	}

	int loadModel( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		unit->nodes = *ModelIO::readModelFromDisk( filename );
		return 0;
	}

	int loadAnimation( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		string filename = lua::retrieveString( L, 2 );
		int state = (int)lua_tonumber( L, 3 );
		Animation *animation = ModelIO::readAnimationFromFile( filename );
		unit->addAnimation( animation, (AnimationState)state );
		animation->fixTimeShift();

		lua_pushboolean( L, animation->loops() );
		lua_pushnumber( L, animation->getEndTime() );
		return 2;
	}

	int animateUnit( lua_State *L )
	{
		GameInstance *game = (GameInstance*)lua_touserdata( L, 1 );
		Unit *unit = (Unit*)lua_touserdata( L, 2 );
		float time = lua_tonumber( L, 3 );
		game->renderer.animateUnit( unit, time );

		return 0;
	}

	int setAnimation( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		unsigned int animationState = (unsigned int)lua_tonumber( L, 2 );
		unit->setAnimation( animationState );

		return 0;
	}

	int setShader( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		Shader *shader = (Shader*)lua_touserdata( L, 2 );
		for( unsigned int i = 0; i < unit->nodes.size(); ++i )
		{
			Node *node = unit->nodes.at( i );
			for( vector<Mesh>::iterator mit = node->getMeshes().begin(); mit != node->getMeshes().end(); ++mit )
			{
				Mesh &mesh = *mit;
				mesh.setShader( shader );
			}
		}

		return 0;
	}

	int rotateUnit( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		float angle = lua_tonumber( L, 2 );

		mat4 rotation = Transform::getRotationY( angle );
		vec3 currPos = unit->transform.position;
		mat4 revTran = Transform::getTranslate( -currPos );
		unit->transform.mul( revTran );
		unit->transform.mul( rotation );
		mat4 forTran = Transform::getTranslate( currPos );
		unit->transform.mul( forTran );

		return 0;
	}

	int setForwardVector( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		Transform &t = unit->transform;
		t.localZ = lua::retrieveVec3( L, 2 );
		t.localZ.z *= -1;
		t.localY = vec3( 0, 1, 0 );
		vec3 pos = t.position;
		mat4 look = glm::lookAt( vec3(), t.localZ, t.localY );
		t.setMatrix( look );
		mat4 forTran = Transform::getTranslate( pos );
		t.mul( forTran );

		return 0;
	}

	int getForwardVector( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );

		lua::storeVec3( L, unit->transform.localZ );
		return 1;
	}


	int advanceUnit( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		vec3 p = lua::retrieveVec3( L, 2 );

		vec3 currPos = unit->transform.position;
		mat4 revTran = Transform::getTranslate( -currPos );
		unit->transform.mul( revTran );
		mat4 forTran = Transform::getTranslate( p );
		unit->transform.mul( forTran );

		return 0;
	}

	int setGhostVisible( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		bool visible = lua_toboolean( L, 2 );
		unit->setGhostVisible( visible );

		return 0;
	}

	int setGhostTile( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		MapTile *tile = (MapTile*)lua_touserdata( L, 2 );
		unit->setGhostPosition( tile->position + vec3( 0, tile->height, 0 ) );
		
		return 0;
	}

	int setUnitVisible( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		bool visible = lua_toboolean( L, 2 );
		unit->visible = visible;

		return 0;
	}

	int setUnitEnabled( lua_State *L )
	{
		Unit *unit = (Unit*)lua_touserdata( L, 1 );
		bool enable = lua_toboolean( L, 2 );
		unit->enabled = enable;

		return 0;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Unit_new", Unit_new );
		lua::registerLuacFunction( L, "Unit_setTeamColor", setTeamColor );
		lua::registerLuacFunction( L, "Unit_setRingShader", setRingShader );
		lua::registerLuacFunction( L, "Unit_loadModel", loadModel );
		lua::registerLuacFunction( L, "Unit_loadAnimation", loadAnimation );
		lua::registerLuacFunction( L, "Unit_animate", animateUnit );
		lua::registerLuacFunction( L, "Unit_setAnimation", setAnimation );
		lua::registerLuacFunction( L, "Unit_setShader", setShader );
		lua::registerLuacFunction( L, "Unit_rotate", rotateUnit );
		lua::registerLuacFunction( L, "Unit_setForwardVector", setForwardVector );
		lua::registerLuacFunction( L, "Unit_getForwardVector", getForwardVector );
		lua::registerLuacFunction( L, "Unit_advance", advanceUnit );
		lua::registerLuacFunction( L, "Unit_setGhostVisible", setGhostVisible );
		lua::registerLuacFunction( L, "Unit_setGhostTile", setGhostTile );
		lua::registerLuacFunction( L, "Unit_setVisible", setUnitVisible );
		lua::registerLuacFunction( L, "Unit_setEnabled", setUnitEnabled );
	}

}