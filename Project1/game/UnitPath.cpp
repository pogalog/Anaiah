#include "UnitPath.h"
#include "math/Transform.h"
#include "game/Unit.h"

#include <iostream>

using namespace std;
using namespace glm;

UnitPath::UnitPath( Unit *unit, vector<MapTile*> tiles )
	:unit( unit ), tiles( tiles ), finished( false ), currentTileIndex( 0 ), progressParam( 0.0f )
{
	unit->isMoving = true;


	// update Unit direction
	int pvd = tiles.at( 0 )->pathValDir;
	int dir0 = unit->direction;
	unit->direction = pvd < 0 ? dir0 : pvd;
	int dir1 = unit->direction;

	int change = (dir1 - dir0 + 6) % 6;
	float angleChange = math_util::PI * change / 3.0f;
	mat4 rotation = Transform::getRotationY( -angleChange );

	vec3 currPos = unit->transform.position;
	mat4 revTran = Transform::getTranslate( -currPos );
	unit->transform.mul( revTran );
	unit->transform.mul( rotation );
	mat4 forTran = Transform::getTranslate( currPos );
	unit->transform.mul( forTran );
}

UnitPath::~UnitPath()
{

}


bool UnitPath::update()
{
	// make progress
	progressParam += 0.075f;

	// are we ready to move to the next tile?
	if( progressParam >= 1.0f )
	{
		// set index to next Tile
		++currentTileIndex;

		// subtract 1.0 rather than setting to 0.0 to avoid slowing the unit down
		progressParam -= 1.0f;

		// update Unit direction
		int pvd = tiles.at( currentTileIndex )->pathValDir;
		int dir0 = unit->direction;
		unit->direction = pvd < 0 ? dir0 : pvd;
		int dir1 = unit->direction;

		int change = (dir1 - dir0 + 6) % 6;
		float angleChange = math_util::PI * change / 3.0f;
		mat4 rotation = Transform::getRotationY( -angleChange );

		vec3 currPos = unit->transform.position;
		mat4 revTran = Transform::getTranslate( -currPos );
		unit->transform.mul( revTran );
		unit->transform.mul( rotation );
		mat4 forTran = Transform::getTranslate( currPos );
		unit->transform.mul( forTran );
	}

	// are we done?
	if( currentTileIndex >= tiles.size() - 1 )
	{
		finished = true;
		unit->isMoving = false;
		return true;
	}

	// set unit position and orientation
	MapTile *tile0 = tiles.at( currentTileIndex );
	MapTile *tile1 = tiles.at( currentTileIndex + 1 );
	vec3 p0 = tiles.at( currentTileIndex )->position + vec3( 0, tile0->height, 0 );
	vec3 p1 = tiles.at( currentTileIndex + 1 )->position + vec3( 0, tile1->height, 0 );
	vec3 r = (p1 - p0) * progressParam;
	vec3 p = p0 + r;
	
	vec3 currPos = unit->transform.position;
	mat4 revTran = Transform::getTranslate( -currPos );
	unit->transform.mul( revTran );
	mat4 forTran = Transform::getTranslate( p );
	unit->transform.mul( forTran );


	return false;
}
