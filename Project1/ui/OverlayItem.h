#pragma once

#include "game/Camera.h"
#include "text\TextItem.h"

#include <string>
#include <vector>
#include <glm/glm.hpp>

class Overlay;
class OverlayItem
{

public:
	OverlayItem( Overlay *overlay, std::string message );
	~OverlayItem();

	// mutator
	void setVisible( bool visible ) { this->visible = visible; }

	// accessor
	TextItem* getText() { return text; }
	bool isVisible() { return visible; }


private:

	Overlay *overlay;
	TextItem *text;
	bool visible;

};