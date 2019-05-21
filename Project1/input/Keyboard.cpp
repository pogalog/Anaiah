#include "Keyboard.h"

#include <cstdio>
#include <iostream>

using namespace std;

// macros for key codes
#define KEY_ESCAPE 27

Keyboard::Keyboard()
{
}


Keyboard::~Keyboard()
{
}

void Keyboard::keyPressed( unsigned char key )
{
	bool pressed = keys[(int)key];
	
	if( !pressed )
	{
		for( list<KeyboardListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			KeyboardListener *kl = *it;
			kl->keyPressed( this, key );
		}
	}
	keys[(int)key] = true;
}

void Keyboard::keyReleased( unsigned char key )
{
	keys[(int)key] = false;
	for( list<KeyboardListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
	{
		KeyboardListener *kl = *it;
		kl->keyReleased( this, key );
	}
}
