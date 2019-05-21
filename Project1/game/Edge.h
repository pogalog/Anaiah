#pragma once

#include "MapTile.h"

class Edge
{
public:
	Edge( MapTile *tile, int direction )
	{
		this->tile = tile;
		this->direction = direction;
	}

	bool operator==( const Edge &edge ) const
	{
		return edge.tile == tile && edge.direction == direction;
	}

	MapTile *tile;
	int direction;
};