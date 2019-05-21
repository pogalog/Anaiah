#pragma once
#include <boost/timer/timer.hpp>
#include <list>

#include "audio/AudioManager.h"
#include "game/LevelMap.h"
#include "game/Camera.h"
#include "game/AssetManager.h"
#include "gui/CursorInputProcessor.h"
#include "input/ControllerListener.h"
#include "input/ControllerPort.h"
#include "input/InputProc.h"
#include "lua/LuaScript.h"
#include "network/Client.h"
#include "network/Server.h"
#include "render/GameRenderer.h"
#include "text/TextAssetManager.h"
#include "ui/MenuAssetManager.h"
#include "ui/OverlayAssetManager.h"

class GameInstance : ControllerListener
{
public:
	GameInstance( ControllerPort *controllerPort, lua_State *mainState, AudioManager *audioManager );
	~GameInstance();

	int lua_init();
	void spawnAIThread( std::string data );
	void update();
	void updateLogic();
	void executeAI( std::string data );
	std::string fetchAIResult();

	// ControllerListener
	void controllerConnected( CXBOXController *controller );
	void controllerDisconnected( CXBOXController *controller );
	void digitalButtonStateChanged( CXBOXController *controller );
	void leftTriggerStateChanged( CXBOXController *controller );
	void rightTriggerStateChanged( CXBOXController *controller );
	void leftAnalogMovedX( CXBOXController *controller );
	void leftAnalogMovedY( CXBOXController *controller );
	void rightAnalogMovedX( CXBOXController *controller );
	void rightAnalogMovedY( CXBOXController *controller );

	float globalTime;
	Camera camera;
	LevelMap *levelMap;
	CursorInputProcessor cip;
	ControllerPort *cport;
	lua_State *mainState, *gameState;
	AudioManager *audioManager;
	AssetManager assetManager;
	MenuAssetManager menuAssetManager;
	TextAssetManager textAssetManager;
	OverlayAssetManager overlayAssetManager;
	InputState state;
	GameRenderer renderer;
	boost::timer::cpu_timer timer;
	boost::mutex aiMutex;

private:
	std::list<lua_State*> aiStates;
};