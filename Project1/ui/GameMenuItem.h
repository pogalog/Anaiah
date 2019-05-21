#pragma once
#include "text/TextAssetManager.h"

#include <string>

class GameMenu;
class GameMenuItem
{
public:
	GameMenuItem( GameMenu *menu, std::string message );
	~GameMenuItem();

	// mutator
	void setVisible( bool visible ) { this->visible = visible; }

	// accessor
	TextItem* getText() { return text; }
	bool isVisible() { return visible; }


private:

	GameMenu *menu;
	TextItem *text;
	bool visible;

};