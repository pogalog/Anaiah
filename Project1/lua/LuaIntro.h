#pragma once


#include "lua/lua_util.h"
#include "render/IntroRenderer.h"
#include "geom/ProceduralGeom.h"



namespace lua_intro
{
	using namespace std;
	using namespace glm;
	using namespace defs;

	int Intro_new( lua_State *L )
	{
		int width = (int)lua_tonumber( L, 1 );
		int height = (int)lua_tonumber( L, 2 );
		intro = new IntroRenderer( width, height );

		lua_pushlightuserdata( L, intro );
		return 1;
	}

	int createIntroMenu( lua_State *L )
	{
		IntroRenderer *intro = (IntroRenderer*)lua_touserdata( L, 1 );
		GameMenu *menu = new GameMenu();
		intro->addMenu( menu );

		lua_pushlightuserdata( L, menu );
		return 1;
	}

	int setClearColor( lua_State *L )
	{
		IntroRenderer *intro = (IntroRenderer*)lua_touserdata( L, 1 );
		vec4 color = lua::retrieveVec4( L, 2 );
		intro->setClearColor( color );

		return 0;
	}

	int Text_new( lua_State *L )
	{
		IntroRenderer *intro = (IntroRenderer*)lua_touserdata( L, 1 );
		FontMap *font = (FontMap*)lua_touserdata( L, 2 );
		string message = lua::retrieveString( L, 3 );
		TextItem *ti = intro->createTextItem( font, message );

		lua_pushlightuserdata( L, ti );
		return 1;
	}


	int quit( lua_State *L )
	{
		exit( 0 );
		return 0;
	}

	int controlSleep( lua_State *L )
	{
		port->removeListener( mainController );

		return 0;
	}

	int controlResume( lua_State *L )
	{
		port->addListener( mainController );

		return 0;
	}

	int createQuad( lua_State *L )
	{
		IntroRenderer *intro = (IntroRenderer*)lua_touserdata( L, 1 );
		float aspect = lua_tonumber( L, 2 );
		vec4 color = lua::retrieveVec4( L, 3 );
		Model *quad = geom::createQuad_p( aspect, color );
		quad->getPrimaryMesh().buildVAO();
		intro->addModel( quad );

		lua_pushlightuserdata( L, quad );
		return 1;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Intro_new", Intro_new );
		lua::registerLuacFunction( L, "IntroMenu_new", createIntroMenu );
		lua::registerLuacFunction( L, "Intro_setClearColor", setClearColor );
		lua::registerLuacFunction( L, "IntroText_new", Text_new );
		lua::registerLuacFunction( L, "Intro_quit", quit );
		lua::registerLuacFunction( L, "Intro_controlSleep", controlSleep );
		lua::registerLuacFunction( L, "Intro_controlResume", controlResume );
		lua::registerLuacFunction( L, "Intro_createQuad", createQuad );
	}
}