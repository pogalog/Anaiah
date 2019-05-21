/*
 * GridRow.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef GAME_GRIDROW_H_
#define GAME_GRIDROW_H_

#include <vector>

#include "MapTile.h"

class GridRow
{
public:
	GridRow( int index );
	~GridRow();
	
	void setSize( int size );
	void removeAll();
	void addTile( const MapTile &tile );
	
	int index;
	std::vector<MapTile> tiles;
};

#endif /* GAME_GRIDROW_H_ */
