/*
 * MapGrid.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef GAME_MAPGRID_H_
#define GAME_MAPGRID_H_

#include <vector>
#include <list>

#include "math/Vec2i.h"
#include "GridRow.h"
#include "model/Model.h"
#include "render/Shader.h"
#include "game/UnitPath.h"
#include "game/TileRange.h"
#include "Edge.h"

#include <glm/glm.hpp>

class LevelMap;
class MapTile;
class Unit;
class MapGrid
{
public:
	MapGrid();
	MapGrid( const Vec2i &dim );
	~MapGrid();
	
	std::vector<MapTile*>& getTilesWithinMovementRange( const Unit &unit );
	std::vector<MapTile*>& getTilesWithinAttackRange( const Unit &unit );
	std::vector<MapTile*>& getTilesWithinItemRange( const Unit &unit );
	void buildMovementRangeModel();
	void buildAttackRangeModel();
	void buildItemRangeModel();
	void buildPathFindModel();
	//std::vector<MapTile*> getTilesWithinAttackRangeSingle( const Unit &unit );
	
	
	bool moveUnit( Unit *unit, MapTile *tile );
	bool moveUnit( Unit *unit, const Vec2i address );
	void findPath( Unit *unit );
	void findPath( const Unit &unit );
	void compilePathForUnit( Unit *unit );
	std::vector<Edge> findIslandBorder( std::vector<MapTile*> island );
	MapTile* findExternalTile( std::vector<MapTile*> island );
	int findExternalVertex( std::vector<MapTile*> island, MapTile *externalTile );
	void updateUnitPaths();
	void clearPathfinding();
	void addPFTarget( MapTile *target ) { pathFindTargets.push_back( target ); target->isTarget = true; }
	void buildMesh();
	void draw( const Camera &camera );
	void drawRange( const Camera &camera, Model &rangeModel, const Color &color );
	void drawRanges( const Camera &camera );
	void drawPathfinding( const Camera &camera );
	
	int getLargestRowSize();
	void setTile( const MapTile &tile );
	void addRow( int size );
	MapTile* getTileAtAddress( unsigned int i, unsigned int j );
	
	// accessors
	bool isVisible() { return visible; }
	Model& getMoveRangeModel() { return moveRangeModel; }
	Model& getAttackRangeModel() { return attackRangeModel; }
	Model& getPathFindModel() { return pathFindModel; }


	// mutators
	void setVisible( bool visible ) { this->visible = visible; }
	void addRange( TileRange *range ) { this->ranges.push_back( range ); }
	void removeRange( TileRange *range ) { this->ranges.remove( range ); }


	LevelMap *map;
	Model model;
	Vec2i dim;
	bool pathVisible;
	glm::vec3 origin;
	std::vector<GridRow> rows;
	std::list<TileRange*> ranges;
	std::vector<MapTile*> moveRange, attackRange, itemRange, pathFindTargets;
	std::vector<UnitPath> unitPaths;
	Model moveRangeModel, attackRangeModel, itemRangeModel, pathFindModel;
	Shader *shader, *rangeShader;
	
private:
	void buildNeighbors();
	
	std::vector<MapTile> generateAttackShape( const Unit &unit );
	void clearPFMarkings();
	void clearMarkings();


	bool visible;
};

#endif /* GAME_MAPGRID_H_ */
