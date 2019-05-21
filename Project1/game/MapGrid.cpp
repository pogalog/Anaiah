/*
 * MapGrid.cpp
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#include <algorithm>

#include "MapGrid.h"
#include "Edge.h"
#include "Unit.h"
#include "util/Util.h"
#include "model/ModelUtil.h"
#include "game/Camera.h"
#include "math/Range.h"

using namespace std;
using namespace glm;
using namespace util;

MapGrid::MapGrid()
: map( NULL ), pathVisible( false ), origin( vec3() ), rows( vector<GridRow>() ), visible( true ),
  moveRange( vector<MapTile*>() ), attackRange( vector<MapTile*>() ), pathFindTargets( vector<MapTile*>() )
{
}

MapGrid::MapGrid( const Vec2i &dim )
: map( NULL ), pathVisible( false ), origin( vec3() ), dim( dim ), visible( true ),
  moveRange( vector<MapTile*>() ), attackRange( vector<MapTile*>() ), pathFindTargets( vector<MapTile*>() )
{
	rows = vector<GridRow>();

	for( int i = 0; i < dim.y; ++i )
	{
		addRow( dim.x );
	}
}


MapGrid::~MapGrid()
{
	
}



// range functions
vector<MapTile*>& MapGrid::getTilesWithinMovementRange( const Unit &unit )
{
	moveRange.clear();
	moveRange.push_back( unit.location );
	vector<MapTile*> assignment;
	vector<MapTile*> traversal;
	clearMarkings();

	bool big = unit.size > 1;

	// add unit's tile to traversal list
	traversal.push_back( unit.location );

	unit.location->moveID = 0;
	int i = 0;
	while( i <= unit.getMovementRange() )
	{
		for( vector<MapTile*>::iterator trit = traversal.begin(); trit != traversal.end(); ++trit )
		{
			MapTile *trav = *trit;
			
			for( vector<MapTile*>::iterator nit = trav->neighbors.begin(); nit != trav->neighbors.end(); ++nit )
			{
				MapTile *neighbor = *nit;
				if( !neighbor ) continue;

				bool occupied = neighbor->occupant && neighbor->occupant != &unit;
				if( occupied )
				{
					// check for team?
					continue;
				}
				int newID = trav->moveID + trav->movePenalty + 1;
				if( neighbor->moveID > newID && neighbor->isAvailable( &unit ) )
				{
					if( newID > unit.getMovementRange() ) continue;
					neighbor->moveID = newID;
					if( !occupied )
					{
						// for units of size > 1 tile
						//if( big && !neighbor->areNeighborsAvailable( &unit ) ) continue;

						// add all tiles that fall within unit's physical extent
						if( big )
						{
							// do stuff (look it up, I was lazy)
						}
						assignment.push_back( neighbor );
						if( !containsPointer( moveRange, neighbor ) ) moveRange.push_back( neighbor );
					}
				}
			}
		}

		// move assignment to traversal
		traversal.clear();
		for( vector<MapTile*>::iterator ait = assignment.begin(); ait != assignment.end(); ++ait )
		{
			MapTile *tile = *ait;
			traversal.push_back( tile );
		}
		assignment.clear();
		++i;
	}

	return moveRange;
}

vector<MapTile*>& MapGrid::getTilesWithinAttackRange( const Unit &unit )
{
	attackRange.clear();
	vector<MapTile> stamp = generateAttackShape( unit );
	if( stamp.size() == 0 ) return attackRange;
	vec3 yhat = vec3( 0, 1, 0 );

	for( vector<MapTile*>::iterator mit = moveRange.begin(); mit != moveRange.end(); ++mit )
	{
		MapTile *mv = *mit;
		for( vector<MapTile>::iterator stit = stamp.begin(); stit != stamp.end(); ++stit )
		{
			MapTile &st = *stit;
			Vec2i realAddy = st.address + mv->address;
			MapTile *actual = getTileAtAddress( realAddy.x, realAddy.y );
			if( !actual ) continue;
			if( !actual->exists ) continue;
			if( !st.exists ) continue;
			if( containsPointer( attackRange, actual ) ) continue;
			
			// nothing can get in the way of a direct attack
			int distance = mv->address.hexDistanceTo( actual->address );
			if( distance == 1 )
			{
				attackRange.push_back( actual );
				continue;
			}

			// check the path between the tile 'mv' and 'actual' to see if there might be a wall that blocks attacks
			// Do this later, maybe.
		}
	}

	return attackRange;
}

vector<MapTile*>& MapGrid::getTilesWithinItemRange( const Unit &unit )
{
	itemRange.clear();
	vector<MapTile> stamp = generateAttackShape( unit );
	if( stamp.size() == 0 ) return itemRange;
	vec3 yhat = vec3( 0, 1, 0 );

	for( vector<MapTile*>::iterator mit = moveRange.begin(); mit != moveRange.end(); ++mit )
	{
		MapTile *mv = *mit;
		for( vector<MapTile>::iterator stit = stamp.begin(); stit != stamp.end(); ++stit )
		{
			MapTile &st = *stit;
			Vec2i realAddy = st.address + mv->address;
			MapTile *actual = getTileAtAddress( realAddy.x, realAddy.y );
			if( !actual ) continue;
			if( !actual->exists ) continue;
			if( !st.exists ) continue;
			if( containsPointer( itemRange, actual ) ) continue;

			// nothing can get in the way of a direct attack
			int distance = mv->address.hexDistanceTo( actual->address );
			if( distance == 1 )
			{
				itemRange.push_back( actual );
				continue;
			}

			// check the path between the tile 'mv' and 'actual' to see if there might be a wall that blocks attacks
			// Do this later, maybe.
		}
	}

	return itemRange;
}

vector<MapTile> MapGrid::generateAttackShape( const Unit &unit )
{
	vector<MapTile> shape;
	if( !unit.getEquipped() ) return shape;
	Range range = unit.getAttackRange();

	for( int i = 1; i <= range.high; ++i )
	{
		bool included = range.isRangeInclusive( i );

		// top-left corner
		MapTile t0( Vec2i( 0, i ) );
		t0.exists = included;
		shape.push_back( t0 );

		// sweep +n (x): top
		for( int j = 1; j <= i; ++j )
		{
			MapTile top( Vec2i( j, i ) );
			top.exists = included;
			shape.push_back( top );
		}

		// sweep -n (y): top-right
		for( int j = 1 - 1; j >= 0; --j )
		{
			MapTile topRight( Vec2i( i, j ) );
			topRight.exists = included;
			shape.push_back( topRight );
		}

		// sweep -n (x,y): bottom-right
		for( int j = 1; j <= i; ++j )
		{
			MapTile bottomRight( Vec2i( i - j, -j ) );
			bottomRight.exists = included;
			shape.push_back( bottomRight );
		}

		// sweep -n (x): bottom
		for( int j = 1; j <= i; ++j )
		{
			MapTile bottom( Vec2i( -j, -i ) );
			bottom.exists = included;
			shape.push_back( bottom );
		}

		// sweep -n (x): bottom-left
		for( int j = 1; j <= i; ++j )
		{
			MapTile bottomLeft( Vec2i( -i, -i + j ) );
			bottomLeft.exists = included;
			shape.push_back( bottomLeft );
		}

		// sweep +n (x,y): top-left
		for( int j = 1; j < i; ++j )
		{
			MapTile topLeft( Vec2i( -i + j, j ) );
			topLeft.exists = included;
			shape.push_back( topLeft );
		}

	}

	return shape;
}

void MapGrid::draw( const Camera &camera )
{
	if( !visible ) return;

	// render all Mesh objects
	Mesh &mesh = model.getPrimaryMesh();
	
	if( !mesh.visible ) return;
	if( !shader->valid ) return;
	
	glUseProgram( shader->programID );
	
	// compute matrices
	//	mat4 modelMatrix = mat4( transform->matrix );
	mat4 modelviewMatrix = camera.transform.matrix;
	mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;
	
	// assign uniform values
	glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
	glUniform3f( glGetUniformLocation( shader->programID, "color" ), 1, 1, 1 );

	glEnableVertexAttribArray( 0 );
	glBindVertexArray( mesh.name );
	glDrawArrays( GL_LINES, 0, mesh.numElements );
	glBindVertexArray( 0 );
	glDisableVertexAttribArray( 0 );
}

void MapGrid::drawRanges( const Camera &camera )
{
	if( !rangeShader ) return;
	if( !rangeShader->valid ) return;

	drawRange( camera, moveRangeModel, Color( 0.1f, 0.6f, 0.1f, 0.3f ) );
	drawRange( camera, attackRangeModel, Color( 0.8f, 0.1f, 0.1f, 0.3f ) );
	drawRange( camera, itemRangeModel, Color( 0.1f, 0.1f, 0.5f, 0.3f ) );

	for( list<TileRange*>::iterator it = ranges.begin(); it != ranges.end(); ++it )
	{
		TileRange *range = *it;
		range->draw( camera );
	}
}

void MapGrid::drawRange( const Camera &camera, Model &rangeModel, const Color &color )
{
	if( rangeModel.visible )
	{
		Mesh &mesh = rangeModel.getPrimaryMesh();

		if( !mesh.visible ) return;

		float opacity = 0.3f;

		glUseProgram( rangeShader->programID );

		// compute matrices
		mat4 shiftUp = mat4( 1.0 );
		shiftUp[3][1] = 0.05f;
		mat4 modelviewMatrix = camera.transform.matrix * shiftUp;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

		// assign uniform values
		glUniformMatrix4fv( glGetUniformLocation( rangeShader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
		glUniform4f( glGetUniformLocation( rangeShader->programID, "color" ), color.r(), color.g(), color.b(), opacity );

		glEnableVertexAttribArray( 0 );
		glBindVertexArray( mesh.name );
		glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
		glBindVertexArray( 0 );
		glDisableVertexAttribArray( 0 );
	}
}

void MapGrid::drawPathfinding( const Camera &camera )
{
	if( !rangeShader ) return;
	if( !rangeShader->valid ) return;

	if( pathFindModel.visible )
	{
		// render all Mesh objects
		Mesh &mesh = pathFindModel.getPrimaryMesh();
		if( !mesh.visible ) return;

		float opacity = 1.0f;

		glUseProgram( rangeShader->programID );

		// compute matrices
		mat4 shiftUp = mat4( 1.0 );
		shiftUp[3][1] = 0.1f;
		mat4 modelviewMatrix = camera.transform.matrix * shiftUp;
		mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

		// assign uniform values
		glUniformMatrix4fv( glGetUniformLocation( rangeShader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
		glUniform4f( glGetUniformLocation( rangeShader->programID, "color" ), 0.8f, 0.8f, 0.8f, opacity );

		glEnableVertexAttribArray( 0 );
		glBindVertexArray( mesh.name );
		glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
		glBindVertexArray( 0 );
		glDisableVertexAttribArray( 0 );
	}
}


int MapGrid::getLargestRowSize()
{
	uint largest = 0;
	for( vector<GridRow>::iterator it = rows.begin(); it != rows.end(); ++it )
	{
		GridRow row = *it;
		if( row.tiles.size() > largest )
		{
			largest = row.tiles.size();
		}
	}
	return largest;
}


void MapGrid::setTile( const MapTile &tile )
{
	const Vec2i &addy = tile.address;
	vector<MapTile> &row = rows.at( addy.y ).tiles;
	row.erase( row.begin()+addy.x );
	row.insert( row.begin()+addy.x, tile );
}



void MapGrid::addRow( int size )
{
	unsigned int yAddress = rows.size();
	GridRow row( yAddress );
	
	for( int i = 0; i < size; ++i )
	{
		Vec2i addy = Vec2i( i, yAddress );
		MapTile tile = MapTile( addy );
		row.addTile( tile );
	}
	rows.push_back( row );
}


void MapGrid::buildMesh()
{
	buildNeighbors();
	
	// build individual tile models
	for( vector<GridRow>::iterator grit = rows.begin(); grit != rows.end(); ++grit )
	{
		GridRow &row = *grit;
		for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
		{
			MapTile &tile = *mtit;
			tile.buildModels();
		}
	}
}

void MapGrid::buildMovementRangeModel()
{
	model_util::createRangeModel( moveRange, moveRangeModel );
}

void MapGrid::buildAttackRangeModel()
{
	model_util::createRangeModel( attackRange, attackRangeModel );
}

void MapGrid::buildItemRangeModel()
{
	model_util::createRangeModel( itemRange, itemRangeModel );
}

void MapGrid::buildPathFindModel()
{
	model_util::createPathFindModel( this );
}


void MapGrid::findPath( Unit *unit )
{
	vector<MapTile*> traversal;
	vector<MapTile*> assignment;
	clearPFMarkings();
	
	for( vector<MapTile*>::iterator it = pathFindTargets.begin(); it != pathFindTargets.end(); ++it )
	{
		MapTile *target = *it;
		traversal.push_back( target );
		target->pathValCost = 0;
		target->goal = target;
	}
	
	while( traversal.size() > 0 )
	{
		for( vector<MapTile*>::iterator it = traversal.begin(); it != traversal.end(); ++it )
		{
			MapTile *tile = *it;
			for( uint i = 0; i < 6; ++i )
			{
				MapTile *neighbor = tile->neighbors[i];
				if( neighbor == NULL ) continue;
				if( !neighbor->isAvailable( unit ) ) continue;
				int neighborCost = neighbor->pathValCost;
				int myCost = tile->pathValCost;
				int mvPenalty = neighbor->movePenalty;
				int dir = i;
				int undir = (dir + 3)%6;
				
				// unquestioned conversion
				if( neighborCost > myCost + 1 + mvPenalty )
				{
					// point neighbor to "me"
					neighbor->pathValCost = myCost + 1 + mvPenalty;
					neighbor->pathValDir = undir;
					neighbor->bestTile = tile;
					neighbor->goal = tile->goal;
					assignment.push_back( neighbor );
					continue;
				}
				
				// conditional: compare distance to goal
				if( neighborCost == myCost+1+mvPenalty && neighbor->pathValDir != undir )
				{
					// get the tile that this neighbor points to
					if( neighbor->bestTile == NULL )
					{
						neighbor->pathValDir = undir;
						neighbor->bestTile = tile;
						neighbor->goal = tile->goal;
						assignment.push_back( neighbor );
						continue;
					}
					int otherDist = neighbor->goal->address.hexDistanceTo( neighbor->bestTile->address );
					int myDist = tile->address.hexDistanceTo( tile->goal->address );
					if( myDist < otherDist )
					{
						neighbor->pathValDir = undir;
						neighbor->bestTile = tile;
						neighbor->goal = tile->goal;
						assignment.push_back( neighbor );
						continue;
					}
				}
			}
		}
		
		// add more stuff to traversal
		traversal.clear();
		for( vector<MapTile*>::iterator it = assignment.begin(); it != assignment.end(); ++it )
		{
			traversal.push_back( *it );
		}
		assignment.clear();
	}
}

void MapGrid::findPath( const Unit &unit )
{
	int cap = unit.getMovementRange();
	vector<MapTile*> traversal;
	vector<MapTile*> assignment;
	clearPFMarkings();
	
	for( vector<MapTile*>::iterator it = pathFindTargets.begin(); it != pathFindTargets.end(); ++it )
	{
		MapTile *target = *it;
		traversal.push_back( target );
		target->pathValCost = 0;
		target->goal = target;
	}
	
	int count = 0;
	while( traversal.size() > 0 && count <= cap )
	{
		for( vector<MapTile*>::iterator it = traversal.begin(); it != traversal.end(); ++it )
		{
			MapTile *tile = *it;
			for( int i = 0; i < 6; ++i )
			{
				MapTile *neighbor = tile->neighbors[i];
				if( neighbor == NULL ) continue;
				if( !neighbor->isAvailable( NULL ) ) continue;
				int neighborCost = neighbor->pathValCost;
				int myCost = tile->pathValCost;
				int mvPenalty = neighbor->movePenalty;
				int dir = i;
				int undir = (dir + 3)%6;
				
				// unquestioned conversion
				if( neighborCost > myCost + 1 + mvPenalty )
				{
					// point neighbor to "me"
					neighbor->pathValCost = myCost + 1 + mvPenalty;
					neighbor->pathValDir = undir;
					neighbor->bestTile = tile;
					neighbor->goal = tile->goal;
					assignment.push_back( neighbor );
					continue;
				}
				
				// conditional: compare distance to goal
				if( neighborCost == myCost+1+mvPenalty && neighbor->pathValDir != undir )
				{
					// get the tile that this neighbor points to
					if( neighbor->bestTile == NULL )
					{
						neighbor->pathValDir = undir;
						neighbor->bestTile = tile;
						neighbor->goal = tile->goal;
						assignment.push_back( neighbor );
						continue;
					}
					int otherDist = neighbor->goal->address.hexDistanceTo( neighbor->bestTile->address );
					int myDist = tile->address.hexDistanceTo( tile->goal->address );
					if( myDist < otherDist )
					{
						neighbor->pathValDir = undir;
						neighbor->bestTile = tile;
						neighbor->goal = tile->goal;
						assignment.push_back( neighbor );
						continue;
					}
				}
			}
		}
		
		// add more stuff to traversal
		traversal.clear();
		for( vector<MapTile*>::iterator it = assignment.begin(); it != assignment.end(); ++it )
		{
			traversal.push_back( *it );
		}
		assignment.clear();
	}
}

void MapGrid::compilePathForUnit( Unit *unit )
{
	if( unit == NULL ) return;

	vector<MapTile*> tiles;
	MapTile *next = unit->location;
	while( next != NULL )
	{
		tiles.push_back( next );
		next = next->bestTile;
	}

	unitPaths.push_back( UnitPath( unit, tiles ) );
}

// Quick note on using std::find
// I am not 100% certain that it will call an overloaded operator==(), and this approach
// not at all efficient anyway. It would be a better idea to mark the tiles in island, and
// check for this marking rather than checking the entire list for containment.
vector<Edge> MapGrid::findIslandBorder( vector<MapTile*> island )
{
	vector<Edge> edges;
	MapTile *externalTile = findExternalTile( island );
	int externalEdge = findExternalVertex( island, externalTile );
	Edge start( externalTile, externalEdge );
	MapTile *tile = start.tile;
	edges.push_back( start );

	int n = externalEdge;
	while( true )
	{
		vector<MapTile*> neighbors = tile->neighbors;
		MapTile *n1 = neighbors[(n + 1) % 6];
		if( n1 == NULL || std::find( island.begin(), island.end(), n1 ) == island.end() )
		{
			Edge e( tile, (n + 1) % 6 );
			if( std::find( edges.begin(), edges.end(), e ) != edges.end() ) break;
			edges.push_back( e );
			n = (n + 1) % 6;
			continue;
		}
		else
		{
			tile = n1;
			n = (n + 4) % 6;
			continue;
		}
	}

	return edges;
}

MapTile* MapGrid::findExternalTile( vector<MapTile*> island )
{
	for( vector<MapTile*>::iterator mtit = island.begin(); mtit != island.end(); ++mtit )
	{
		MapTile *tile = *mtit;
		for( vector<MapTile*>::iterator nit = tile->neighbors.begin(); nit != tile->neighbors.end(); ++nit )
		{
			MapTile *neighbor = *nit;
			if( neighbor == NULL || std::find( island.begin(), island.end(), neighbor ) == island.end() ) return tile;
		}
	}

	return NULL;
}

int MapGrid::findExternalVertex( vector<MapTile*> island, MapTile *externalTile )
{
	if( externalTile == NULL ) return -1;

	for( int i = 0; i < externalTile->neighbors.size(); ++i )
	{
		MapTile *neighbor = externalTile->neighbors[i];
		if( neighbor == NULL || std::find( island.begin(), island.end(), neighbor ) == island.end() ) return i;
	}

	return -1;
}

void MapGrid::updateUnitPaths()
{
	if( unitPaths.size() == 0 ) return;
	// remove paths that are finished
	for( int i = unitPaths.size() - 1; i >= 0; --i )
	{
		UnitPath &path = unitPaths.at( i );
		if( path.isFinished() )
		{
			moveUnit( path.unit, path.getDestination() );
			getTilesWithinMovementRange( *path.unit );
			getTilesWithinAttackRange( *path.unit );
			buildMovementRangeModel();
			buildAttackRangeModel();
			moveRangeModel.visible = true;
			attackRangeModel.visible = true;

			// stop run animation
			path.unit->setAnimation( -1 );

			unitPaths.erase( unitPaths.begin() + i );
		}
	}
	
	// update paths
	for( vector<UnitPath>::iterator it = unitPaths.begin(); it != unitPaths.end(); ++it )
	{
		UnitPath &path = *it;
		path.update();
	}
}

bool MapGrid::moveUnit( Unit *unit, MapTile *tile )
{
	if( !unit ) return false;
	if( !tile ) return false;
	if( !tile->exists ) return false;

	tile->setOccupant( unit );
	unit->transform.setPosition( tile->position  + vec3( 0, tile->height, 0 ) );

	return true;
}

bool MapGrid::moveUnit( Unit *unit, const Vec2i address )
{
	if( !unit ) return false;
	MapTile *tile = getTileAtAddress( address.x, address.y );
	return moveUnit( unit, tile );
}

void MapGrid::clearPathfinding()
{
	for( vector<MapTile*>::iterator mit = pathFindTargets.begin(); mit != pathFindTargets.end(); ++mit )
	{
		MapTile *target = *mit;
		target->isTarget = false;
	}
	pathFindTargets.clear();
	clearPFMarkings();
}

void MapGrid::clearMarkings()
{
	for( vector<GridRow>::iterator grit = rows.begin(); grit != rows.end(); ++grit )
	{
		GridRow &row = *grit;
		for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
		{
			MapTile &tile = *mtit;
			tile.moveID = 1000;
		}
	}
}

void MapGrid::clearPFMarkings()
{
	for( vector<GridRow>::iterator grit = rows.begin(); grit != rows.end(); ++grit )
	{
		GridRow &row = *grit;
		for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
		{
			MapTile &tile = *mtit;
			tile.pathValCost = 1000;
			tile.pathValDir = -1;
			tile.bestTile = NULL;
		}
	}
}

MapTile* MapGrid::getTileAtAddress( unsigned int x, unsigned int y )
{
	if( y >= rows.size() ) return NULL;
	if( x >= rows.at( y ).tiles.size() ) return NULL;

	GridRow &row = rows.at( y );
	MapTile *tile = &(row.tiles.at( x ));
	return tile;
}


// private
void MapGrid::buildNeighbors()
{
	vector<GridRow>::iterator grit;
	for( grit = rows.begin(); grit != rows.end(); ++grit )
	{
		GridRow &row = *grit;
		for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
		{
			MapTile &tile = *mtit;
			tile.clearNeighbors();
		}
	}
	
	// build new neighbors list
	for( grit = rows.begin(); grit != rows.end(); ++grit )
	{
		GridRow &row = *grit;
		for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
		{
			MapTile &tile = *mtit;
			
			Vec2i addy = tile.address;
			// +1,+1 (up-right)
			MapTile *up_right = getTileAtAddress( addy.x+1, addy.y+1 );
			
			// 0,+1 (up-left)
			MapTile *up_left = getTileAtAddress( addy.x, addy.y+1 );
			
			// -1,0 (left)
			MapTile *left = getTileAtAddress( addy.x-1, addy.y );
			
			// -1,-1 (down-left)
			MapTile *down_left = getTileAtAddress( addy.x-1, addy.y-1 );
			
			// 0,-1 (down-right)
			MapTile *down_right = getTileAtAddress( addy.x, addy.y-1 );
			
			// +1,0 (right)
			MapTile *right = getTileAtAddress( addy.x+1, addy.y );
			
			// counter-clockwise, starting from "theta" = 0
			tile.addNeighbor( up_right, 0 );
			tile.addNeighbor( up_left, 1 );
			tile.addNeighbor( left, 2 );
			tile.addNeighbor( down_left, 3 );
			tile.addNeighbor( down_right, 4 );
			tile.addNeighbor( right, 5 );
		}
	}
	
}




