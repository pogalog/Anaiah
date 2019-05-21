/*
 * MapTile.cpp
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#include "MapTile.h"
#include "geom/ProceduralGeom.h"
#include "game/Unit.h"

#include <iostream>

using namespace std;
using namespace glm;

const double TILE_RADIUS = 1.0;
const double SQRT3 = sqrt(3.0);
const double TILE_WIDTH = SQRT3 * TILE_RADIUS;

MapTile::MapTile()
: name( string( "Tile" ) ), description( string( "Plain" ) ), visible( true ), exists( true ), selected( false ),
  occupiable( true ), lockToTerrain( true ), wall( false ), occupant( NULL ), neighbors( vector<MapTile*>() ), address( Vec2i() ),
  position( vec3() ), attackMod(0), defenseMod( 0 ), iceMod( 0 ), lightningMod( 0 ), fireMod(0), movePenalty( 0 ), visMod( 0 ), ambOverride( 0 ), height( 0 ),
  moveID( 0 ), pathValDir( 0 ), pathValCost( 0 ), mapFlowIndex( 0 ), localFlowIndex( 0 ), bestTile( NULL ), goal( NULL )
{
	for( int i = 0; i < 6; ++i )
	{
		neighbors.push_back( NULL );
	}
}

MapTile::MapTile( const Vec2i &address )
: name( string( "Tile" ) ), description( string( "Plain" ) ), visible( true ), exists( true ), selected( false ),
  occupiable( true ), lockToTerrain( true ), wall( false ), occupant( NULL ), neighbors( vector<MapTile*>() ), address( address ),
  position( vec3() ), attackMod(0), defenseMod( 0 ), iceMod( 0 ), lightningMod( 0 ), fireMod(0), movePenalty( 0 ), visMod( 0 ), ambOverride( 0 ), height( 0 ),
  moveID( 0 ), pathValDir( 0 ), pathValCost( 0 ), mapFlowIndex( 0 ), localFlowIndex( 0 ), bestTile( NULL ), goal( NULL )
{
	for( int i = 0; i < 6; ++i )
	{
		neighbors.push_back( NULL );
	}

	// compute the position of the tile
	position = vec3( TILE_WIDTH * (address.x - 0.5 * address.y), 0.0, -1.5 * TILE_RADIUS * address.y );
}

MapTile::MapTile( const std::string name, const Vec2i &address )
: name( name ), description( string( "Plain" ) ), visible( true ), exists( true ), selected( false ),
  occupiable( true ), lockToTerrain( true ), wall( false ), occupant( NULL ), neighbors( vector<MapTile*>() ), address( address ),
  position( vec3() ), attackMod(0), defenseMod( 0 ), iceMod( 0 ), lightningMod( 0 ), fireMod(0), movePenalty( 0 ), visMod( 0 ), ambOverride( 0 ), height( 0 ),
  moveID( 0 ), pathValDir( 0 ), pathValCost( 0 ), mapFlowIndex( 0 ), localFlowIndex( 0 ), bestTile( NULL ), goal( NULL )
{
	for( int i = 0; i < 6; ++i )
	{
		neighbors.push_back( NULL );
	}

	// compute the position of the tile
	position = vec3( TILE_WIDTH * (address.x - 0.5 * address.y), 0.0, -1.5 * TILE_RADIUS * address.y );
}

MapTile::~MapTile()
{
}


bool MapTile::setOccupant( Unit *unit )
{
	if( occupant ) return false;

	if( unit->location ) unit->location->occupant = NULL;
	unit->location = this;
	occupant = unit;

	return true;
}


void MapTile::buildModels()
{
	for( int i = 0; i < 6; ++i )
	{
		heights.push_back( 0.0 );

		int j = (i + 1) % 6;
		int num = 1;
		float sum = (float)height;
		if( neighbors[i] != NULL )
		{
			++num;
			sum += (float)neighbors[i]->height;
		}
		if( neighbors[j] != NULL )
		{
			++num;
			sum += (float)neighbors[j]->height;
		}
		
		heights[i] = sum / (float)num;
	}
	wireModel = geom::createLineHex( heights );
	solidModel = geom::createFilledHex( heights, height );
	arrowModel = geom::createPFArrow();
}


void MapTile::clearNeighbors()
{
	for( int i = 0; i < 6; ++i )
	{
		neighbors[i] = NULL;
	}
}

void MapTile::addNeighbor( MapTile *tile, int dir )
{
	neighbors[dir] = tile;
}

void MapTile::setPositionFromAddress( const Vec2i &v )
{
	address = v;
	position = vec3( TILE_WIDTH * (v.x - v.y/2.0), position.y, -1.5 * TILE_RADIUS * v.y );
}

void MapTile::setPositionFromAddress( int i, int j )
{
	position = vec3( TILE_WIDTH * (i - j/2.0), position.y, -1.5 * TILE_RADIUS * j );
}

int MapTile::getDirectionToNeighbor( const MapTile &tile )
{
	for( int i = 0; i < 6; ++i )
	{
		if( &tile == neighbors[i] )
			return i;
	}
	return 0;
}

bool MapTile::isAvailable( const Unit *unit ) const
{
	return !wall && occupiable && exists && (occupant == NULL || unit == occupant);
}


bool MapTile::operator ==( const MapTile &t ) const
{
	return t.address == this->address;
}


void MapTile::draw()
{
	
}


