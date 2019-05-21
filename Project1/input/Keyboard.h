#pragma once

#include <list>

#include "KeyboardListener.h"

class Keyboard
{
public:
	Keyboard();
	~Keyboard();

	void keyPressed( unsigned char key );
	void keyReleased( unsigned char key );


	// mutator
	void addListener( KeyboardListener *kl ) { listeners.push_back( kl ); }
	void removeListener( KeyboardListener *kl ) { listeners.remove( kl ); }


	// accessor
	std::list<KeyboardListener*>& getListeners() { return listeners; }


private:
	std::list<KeyboardListener*> listeners;
	bool keys[128];
};

