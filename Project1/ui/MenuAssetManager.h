#pragma once
#include "GameMenu.h"

#include <list>
#include <string>
#include <iostream>

class MenuAssetManager
{
public:
	MenuAssetManager() {}
	~MenuAssetManager() {}


	// mutator
	void addMenu( GameMenu *menu )
	{
		menus.push_back( menu );
	}

	void removeMenu( GameMenu *menu )
	{
		menus.remove( menu );
		delete menu;
	}

	// accessor
	std::list<GameMenu*>& getMenus() { return menus; }
	GameMenu* getMenu( std::string name )
	{

		return NULL;
	}



private:

	std::list<GameMenu*> menus;

};