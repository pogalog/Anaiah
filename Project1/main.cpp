#include <GL/glew.h>
#include <GL/freeglut.h>
#include <cstdlib>
#include <iostream>
#include <cstdio>
#include <cstring>
#include <sys/types.h>
#include <sys/stat.h>
#include <functional>

#include "audio/AudioManager.h"
#include "lua/LuaScript.h"
#include "game/GameInstance.h"
#include "util/Util.h"
#include "input/ControllerPort.h"
#include "input/CXBOXController.h"
#include "input/Keyboard.h"
#include "fileio/LevelMapIO.h"
#include "fileio/ModelIO.h"
#include "fileio/AudioIO.h"

#include "lua/lua_util.h"
#include "lua/LuaCamera.h"
#include "lua/LuaGameInstance.h"
#include "lua/LuaShader.h"
#include "lua/LuaLevelMap.h"
#include "lua/LuaUnit.h"
#include "lua/LuaText.h"
#include "lua/LuaMenu.h"
#include "lua/LuaController.h"
#include "lua/LuaNetwork.h"
#include "lua/LuaIntro.h"
#include "lua/LuaRender.h"
#include "lua/LuaNetwork.h"
#include "lua/LuaKeyboard.h"
#include "lua/LuaModel.h"

#include "main/GlobalDefs.h"


#include "render/Uniform.h"

// globalize namespaces
using namespace std;
using namespace glm;
using namespace defs;


// Keyboard Input
void keyPress( unsigned char key, int mousePositionX, int mousePositionY )
{
	keyboard->keyPressed( key );
}

void keyRelease( unsigned char key, int mousePositionX, int mousePositionY )
{
	keyboard->keyReleased( key );
}

void setVSync( bool sync )
{
	// Function pointer for the wgl extention function we need to enable/disable
	// vsync
	typedef BOOL( APIENTRY *PFNWGLSWAPINTERVALPROC )(int);
	PFNWGLSWAPINTERVALPROC wglSwapIntervalEXT = 0;

	const char *extensions = (char*)glGetString( GL_EXTENSIONS );

	if( strstr( extensions, "WGL_EXT_swap_control" ) == 0 )
	{
		return;
	}
	else
	{
		wglSwapIntervalEXT = (PFNWGLSWAPINTERVALPROC)wglGetProcAddress( "wglSwapIntervalEXT" );

		if( wglSwapIntervalEXT )
			wglSwapIntervalEXT( sync );
	}
}


long t0, t1;
void mainLoop()
{
	switch( RenderMode )
	{
		case 0:
		{
			if( intro == NULL ) return;

			// timed updates (60 Hz)
			t1 = GetTickCount();
			if( abs( t1 - t0 ) < 17 ) return;
			t0 = t1;

			// controller input
			port->checkController();
			port->checkControllerState();

			float dt = 0.016f;
			intro->addTime( dt );
			intro->checkNetwork( defs::lua_mainState );
			intro->display();
			break;
		}
		case 1:
		{
			// rapid updates
			game->update();
			// timed updates (60 Hz)
			t1 = game->timer.elapsed().wall;
			long dt = t1 - t0;
			if( dt < 16666666 ) return;
			t0 = t1;
			game->updateLogic();
			GameRenderer &renderer = game->renderer;
			renderer.display();
			break;
		}
	}
}


void reshape( GLint width, GLint height )
{
	GlutWin &win = game->renderer.win;
	win.width = width;
	win.height = height;
	game->renderer.reshape( width, height );
	glViewport( 0, 0, width, height );
}


void initGL( int argc, char **args )
{
	// initialize Lua
	// Load appropriate libraries, and run scripts in each Lua state.
	// TODO Need to properly use the Lua "game state", not the lua_mainState
	lua_mainState = luaL_newstate();
	lua_gameinstance::registerFunctions( lua_mainState );
	lua_shader::registerFunctions( lua_mainState );
	lua_levelmap::registerFunctions( lua_mainState );
	lua_unit::registerFunctions( lua_mainState );
	lua_text::registerFunctions( lua_mainState );
	lua_menu::registerFunctions( lua_mainState );
	lua_camera::registerFunctions( lua_mainState );
	lua_network::registerFunctions( lua_mainState );
	lua_render::registerFunctions( lua_mainState );
	lua_intro::registerFunctions( lua_mainState );
	lua_controller::LuaController::registerFunctions( lua_mainState );
	lua_model::registerFunctions( lua_mainState );


	luaL_openlibs( lua_mainState );
	if( luaL_loadfile( lua_mainState, "resource/lua/main/init.lua" ) )
	{
		const char *message = lua_tostring( lua_mainState, -1 );
		cout << message << endl;
	}
	if( lua_pcall( lua_mainState, 0, LUA_MULTRET, 0 ) )
	{
		const char *message = lua_tostring( lua_mainState, -1 );
		cout << message << endl;
	}


	GlutWin &win = game->renderer.win;
	win.width = 1280;
	win.height = 720;
	glutInit( &argc, args );
	glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH );
	glutInitWindowPosition( 400, 50 );
	glutInitWindowSize( win.width, win.height );
	glutCreateWindow( "Hex TRPG v0.12" );
	//glutFullScreen();
	//glutEnterGameMode();
	glewExperimental = GL_TRUE;
	

	if( glewInit() ) throw std::runtime_error( "glewInit failed" );
	game->renderer.init();

	glutDisplayFunc( mainLoop );
	glutReshapeFunc( reshape );
	glutIdleFunc( mainLoop );
	glutKeyboardFunc( keyPress );
	glutKeyboardUpFunc( keyRelease );
	//	glutMouseFunc( mouse );


	// ******************* A BUNCH OF CRAP THAT WON'T BE HERE AFTER A WHILE *****************************************
	lua_getglobal( lua_mainState, "loadGame" );
	lua_call( lua_mainState, 0, 0 );

	mainController = new lua_controller::LuaController( lua_mainState );
	gameController = new lua_controller::LuaController( game->gameState );
	port->addListener( mainController );
	port->addListener( gameController );

	mainKeyboard = new lua_keyboard::LuaKeyboard( lua_mainState );
	gameKeyboard = new lua_keyboard::LuaKeyboard( game->gameState );
	port->addListener( mainKeyboard );
	
	// ******************* END OF A BUNCH OF CRAP. YOU MAY GO ABOUT YOUR BUSINESS. *****************************************

	setVSync( true );
	glutMainLoop();
}

int main( int argc, char **argv )
{
	audio = new AudioManager();

	Player1 = new CXBOXController( 1 );
	keyboard = new Keyboard();
	port = new ControllerPort( keyboard );
	port->controller = Player1;


	//ALSound sound0 = readFile( "resource/sound/lion2.wav" );
	//sound0.play();

	//ALfloat listenerOri[] = {0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f};

	//alListener3f( AL_POSITION, 0, 0, 1.0f );
	//alListener3f( AL_VELOCITY, 0, 0, 0 );
	//alListenerfv( AL_ORIENTATION, listenerOri );

	initGL( argc, argv );

	return 0;
}