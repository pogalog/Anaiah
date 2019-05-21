#include "GameMenuItem.h"
#include "GameMenu.h"

using namespace std;

GameMenuItem::GameMenuItem( GameMenu *menu, string message )
	:menu( menu ), text( TextAssetManager::makeTextItem( menu->getFont(), message ) ), visible( true )
{
}
GameMenuItem::~GameMenuItem()
{

}