#include "ControllerPort.h"
#include "CXBOXController.h"

#include <iostream>

using namespace std;

ControllerPort::ControllerPort( Keyboard *keyboard )
	:keyboard( keyboard )
{
}

ControllerPort::~ControllerPort()
{

}


bool ControllerPort::checkController()
{
	if( !controller ) return false;
	bool conn = controller->IsConnected();
	// check if controller has connected or disconnected
	if( controllerConnected )
	{
		if( !conn )
		{
			// disconnected
			for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
			{
				ControllerListener* listener = *it;
				listener->controllerDisconnected( controller );
			}
		}
	}
	else
	{
		if( conn )
		{
			// connected
			for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
			{
				ControllerListener* listener = *it;
				listener->controllerConnected( controller );
			}
		}
	}
	controllerConnected = conn;
	return conn;
}

bool ControllerPort::checkControllerState()
{
	if( !controller ) return false;
	if( !controllerConnected ) return false;
	bool changed = false;

	// collect state information
	controller->GetState();
	XINPUT_GAMEPAD pad0 = controller->GetOldPad();
	XINPUT_GAMEPAD pad = controller->GetNewPad();

	// generate digital button event
	if( pad0.wButtons != pad.wButtons )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->digitalButtonStateChanged( controller );
		}
	}

	// generate leftAnalogX event
	if( pad0.sThumbLX != pad.sThumbLX )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->leftAnalogMovedX( controller );
		}
	}

	// generate leftAnalogY event
	if( pad0.sThumbLY != pad.sThumbLY )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->leftAnalogMovedY( controller );
		}
	}

	// generate rightAnalogX event
	if( pad0.sThumbRX != pad.sThumbRX )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->rightAnalogMovedX( controller );
		}
	}

	// generate rightAnalogY event
	if( pad0.sThumbRY != pad.sThumbRY )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->rightAnalogMovedY( controller );
		}
	}

	// generate leftTrigger event
	if( pad0.bLeftTrigger != pad.bLeftTrigger )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->leftTriggerStateChanged( controller );
		}
	}

	// generate rightTrigger event
	if( pad0.bRightTrigger != pad.bRightTrigger )
	{
		changed = true;
		for( list<ControllerListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			ControllerListener *listener = *it;
			listener->rightTriggerStateChanged( controller );
		}
	}

	return changed;
}
