/*
 * GridRow.cpp
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#include "GridRow.h"

#include <iostream>

using namespace std;

GridRow::GridRow( int index )
{
	this->index = index;
	tiles = vector<MapTile>();
}

GridRow::~GridRow()
{
	
}

// TODO rename or rewrite this function. Also, maybe just delete it.
void GridRow::setSize( int size )
{
	if( size < 0 ) return;
	for( int i = tiles.size()-1; i > size; --i )
	{
	}
}


void GridRow::removeAll()
{
	tiles.clear();
}

void GridRow::addTile( const MapTile &tile )
{
	tiles.push_back( tile );
}

