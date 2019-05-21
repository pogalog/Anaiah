#pragma once

class CXBOXController;
class ControllerListener
{
public:
	virtual void controllerConnected( CXBOXController *controller ) = 0;
	virtual void controllerDisconnected( CXBOXController *controller ) = 0;

	virtual void digitalButtonStateChanged( CXBOXController *controller ) = 0;
	virtual void leftTriggerStateChanged( CXBOXController *controller ) = 0;
	virtual void rightTriggerStateChanged( CXBOXController *controller ) = 0;
	virtual void leftAnalogMovedX( CXBOXController *controller ) = 0;
	virtual void leftAnalogMovedY( CXBOXController *controller ) = 0;
	virtual void rightAnalogMovedX( CXBOXController *controller ) = 0;
	virtual void rightAnalogMovedY( CXBOXController *controller ) = 0;
};