#ifndef _XBOX_CONTROLLER_H_
#define _XBOX_CONTROLLER_H_

// No MFC
//#define WIN32_LEAN_AND_MEAN

// We need the Windows Header and the XInput Header
#include <windows.h>
#include <XInput.h>

// Now, the XInput Library
// NOTE: COMMENT THIS OUT IF YOU ARE NOT USING A COMPILER THAT SUPPORTS THIS METHOD OF LINKING LIBRARIES
#pragma comment( lib, "XInput.lib" )

// XBOX Controller Class Definition
class CXBOXController
{
private:

	XINPUT_GAMEPAD pad0, pad1;
	XINPUT_STATE _controllerState;
	int _controllerNum;
public:
	CXBOXController(int playerNumber);
	XINPUT_STATE GetState();
	XINPUT_GAMEPAD GetOldPad();
	XINPUT_GAMEPAD GetNewPad();
	bool IsConnected();
	void Vibrate( int leftVal = 0, int rightVal = 0 );

};

#endif