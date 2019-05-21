/*
 * LevelMap.h
 *
 *  Created on: Mar 9, 2016
 *      Author: pogal
 */

#ifndef GAME_LEVELMAP_H_
#define GAME_LEVELMAP_H_

#include <string>
#include <list>
#include <vector>

#include "MapGrid.h"
#include "game/Unit.h"

class LevelMap
{
public:
	LevelMap();
	~LevelMap();
	

	// mutators
	void addUnit( Unit *unit ) { units.push_back( unit ); }
	void removeUnit( Unit *unit ) { units.remove( unit ); }

	// game
	bool moveUnit( Unit *unit, MapTile *tile );
	bool moveUnit( Unit *unit, const Vec2i address );
	void setUnitCoexist( Unit *unit, const Vec2i address );

	
	std::string name;
	std::string lua_MainName;
	double ambientBrightness;
	MapGrid grid;
	//LuaScript mainScript;
	std::list<Unit*> units;
	std::list<Model*> debugModels;
	
	MapTile *selectedTile;
};

#endif /* GAME_LEVELMAP_H_ */
