#pragma once

class Keyboard;
class KeyboardListener
{
public:
	virtual void keyPressed( Keyboard*, const char key ) = 0;
	virtual void keyReleased( Keyboard*, const char key ) = 0;
	virtual void keyTyped( Keyboard*, const char key ) = 0;
};