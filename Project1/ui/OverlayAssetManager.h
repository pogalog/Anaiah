#pragma once

#include <list>
#include <string>
#include <iostream>

#include "Overlay.h"

class OverlayAssetManager
{

public:
	OverlayAssetManager() {}
	~OverlayAssetManager() {}

	// mutator
	void addOverlay( Overlay *overlay )
	{
		overlays.push_back( overlay );
	}

	void removeOverlay( Overlay *overlay )
	{
		overlays.remove( overlay );
		delete overlay;
	}

	// accessors
	std::list<Overlay*>& getOverlays() { return overlays; }


private:
	std::list<Overlay*> overlays;
};