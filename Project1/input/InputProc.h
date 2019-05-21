#pragma once

enum InputState
{
	GRID_SELECT_STATE,
	UNIT_ACTION_MENU_STATE,
	PAUSE_MENU_STATE
};

class CXBOXController;
class GameInstance;
class XBoxProcessor
{
public:
	XBoxProcessor( GameInstance *game );
	~XBoxProcessor();


	GameInstance *game;
};