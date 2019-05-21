#pragma once

#include "game/MapTile.h"

#include <vector>

class UnitPath
{
public:
	UnitPath( Unit *unit, std::vector<MapTile*> tiles );
	~UnitPath();

	bool update();

	// accessor
	bool isFinished() { return finished; }
	MapTile* getDestination() { return tiles.back(); }

	Unit *unit;
	std::vector<MapTile*> tiles;
	unsigned int currentTileIndex;
	float progressParam;
	bool finished;

};