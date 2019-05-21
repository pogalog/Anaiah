#pragma once

/*
 * The controller port is a responsible for switching between input methods when
 * the player requests it. If a gamepad disconnects, the controller port will
 * notify the game logic to display a message to the player. The game can then
 * be held up until a controller is connected again.
 */

#include <list>
#include "ControllerListener.h"
#include "Keyboard.h"


class CXBOXController;
class ControllerPort
{
public:
	ControllerPort( Keyboard *keyboard );
	~ControllerPort();

	bool checkController();
	bool checkControllerState();
	CXBOXController *controller;
	Keyboard *keyboard;

	// mutator
	void addListener( ControllerListener *listener ) { listeners.push_back( listener ); }
	void addListener( KeyboardListener *listener ) { keyboard->addListener( listener ); }
	void removeListener( ControllerListener *listener ) { listeners.remove( listener ); }
	void removeListener( KeyboardListener *listener ) { keyboard->removeListener( listener ); }


	std::list<ControllerListener*> listeners;
	bool controllerConnected;

};