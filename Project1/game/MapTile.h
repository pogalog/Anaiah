/*
 * MapTile.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef GAME_MAPTILE_H_
#define GAME_MAPTILE_H_

#include <string>
#include <vector>
#include <cmath>
#include <glm/glm.hpp>

#include "math/Vec2i.h"
#include "model/Model.h"


class Unit;
class MapTile
{
public:
	MapTile();
	MapTile( const Vec2i &address );
	MapTile( const std::string name, const Vec2i &address );
	~MapTile();
	
	void clearNeighbors();
	void addNeighbor( MapTile *tile, int dir );
	void buildModels();
	bool setOccupant( Unit *unit );

	void setPositionFromAddress( const Vec2i &v );
	void setPositionFromAddress( int i, int j );
	int getDirectionToNeighbor( const MapTile &neighbor );
	bool isAvailable( const Unit *unit ) const;
	
	bool operator ==( const MapTile &t ) const;
	
	void draw();
	
	std::string name;
	std::string description;
	bool visible, exists, selected, occupiable, lockToTerrain, wall, isTarget;
	Unit *occupant;
	std::vector<MapTile*> neighbors;
	std::vector<float> heights;
	Vec2i address;
	glm::vec3 position;
	int attackMod, defenseMod, iceMod, lightningMod, fireMod, movePenalty;
	float visMod, ambOverride, height;
	
	
	int moveID, pathValDir, pathValCost, mapFlowIndex, localFlowIndex;
	MapTile *bestTile, *goal;
	Model wireModel;
	Model solidModel;
	Model arrowModel;
};

#endif /* GAME_MAPTILE_H_ */
