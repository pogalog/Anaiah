/*
 * LevelMap.cpp
 *
 *  Created on: Mar 9, 2016
 *      Author: pogal
 */

#include "LevelMap.h"
#include "MapGrid.h"

#include <iostream>

using namespace std;


LevelMap::LevelMap()
{
}

LevelMap::~LevelMap()
{
}


// game
bool LevelMap::moveUnit( Unit *unit, MapTile *tile )
{
	return grid.moveUnit( unit, tile );
}

bool LevelMap::moveUnit( Unit *unit, const Vec2i address )
{
	return grid.moveUnit( unit, address );
}

void LevelMap::setUnitCoexist( Unit *unit, const Vec2i address )
{
	MapTile *tile = grid.getTileAtAddress( address.x, address.y );
	unit->coexistLocation = tile;
	unit->updateCoexistTransform();
}