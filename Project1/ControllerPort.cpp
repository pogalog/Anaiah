#include "ControllerPort.h"
#include "input/CXBOXController.h"

ControllerPort::ControllerPort()
{

}

ControllerPort::~ControllerPort()
{

}


bool ControllerPort::checkController()
{
	if( !controller ) return false;
	return true;
}
