#include "InputProc.h"

XBoxProcessor::XBoxProcessor( GameInstance *game )
	:game(game)
{
}

XBoxProcessor::~XBoxProcessor()
{

}


// All (maybe?) controller events will be sent to the GameInstance for further processing.


