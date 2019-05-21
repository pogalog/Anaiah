#include "CXBOXController.h"

#include <iostream>

using namespace std;

CXBOXController::CXBOXController( int playerNumber )
{
	// Set the Controller Number
	_controllerNum = playerNumber - 1;
}

XINPUT_STATE CXBOXController::GetState()
{
	// copy the state
	pad0 = pad1;

	XINPUT_GAMEPAD &pad = _controllerState.Gamepad;

	// check done zones
	SHORT LDZ = XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;
	SHORT RDZ = XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE;

	// Zero the state
	//ZeroMemory(&_controllerState, sizeof(XINPUT_STATE));

	// Get the state
	WORD butt0 = pad0.wButtons;
	XInputGetState( _controllerNum, &_controllerState );
	pad1 = _controllerState.Gamepad;
	
	if( (pad.sThumbLX < LDZ && pad.sThumbLX > -LDZ) && (pad.sThumbLY < LDZ && pad.sThumbLY > -LDZ) )
	{
		pad.sThumbLX = 0;
		pad.sThumbLY = 0;
		pad1.sThumbLX = 0;
		pad1.sThumbLY = 0;
	}
	if( (pad.sThumbRX < RDZ && pad.sThumbRX > -RDZ) && (pad.sThumbRY < RDZ && pad.sThumbRY > -RDZ) )
	{
		pad.sThumbRX = 0;
		pad.sThumbRY = 0;
		pad1.sThumbRX = 0;
		pad1.sThumbRY = 0;
	}

	return _controllerState;
}

XINPUT_GAMEPAD CXBOXController::GetOldPad()
{
	return pad0;
}

XINPUT_GAMEPAD CXBOXController::GetNewPad()
{
	return pad1;
}


bool CXBOXController::IsConnected()
{
	// Zeroise the state
	ZeroMemory(&_controllerState, sizeof(XINPUT_STATE));

	// Get the state
	DWORD Result = XInputGetState(_controllerNum, &_controllerState);

	if(Result == ERROR_SUCCESS)
	{
		return true;
	}
	else
	{
		return false;
	}
}

void CXBOXController::Vibrate( int leftVal, int rightVal )
{
	// Create a Vibraton State
	XINPUT_VIBRATION Vibration;

	// Zeroise the Vibration
	ZeroMemory(&Vibration, sizeof(XINPUT_VIBRATION));

	// Set the Vibration Values
	Vibration.wLeftMotorSpeed = leftVal;
	Vibration.wRightMotorSpeed = rightVal;

	// Vibrate the controller
	XInputSetState(_controllerNum, &Vibration);
}


