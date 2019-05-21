#pragma once

#include <vector>
#include <string>

#include "MapTile.h"
#include "math/Transform.h"
#include "math/Range.h"
#include "model/Node.h"
#include "game/Weapon.h"

class Unit
{
public:
	Unit();
	Unit( const Unit &unit );
	~Unit();
	
	int getMovementRange() const;
	Range getAttackRange() const;
	void setLocation( MapTile *tile );
	
	void draw( const Camera&, bool shaderOverride = false );
	void drawTeamID( const Camera&, const Transform& );
	void drawGhost( const Camera& );

	
	// operators
	bool operator ==( const Unit &unit );


	// accessor
	Weapon* getEquipped() const { return equipped; }
	glm::vec4* getTeamColor() { return &teamColor;  }
	bool isGhostVisible() { return ghostVisible; }

	// mutator
	void addAnimation( Animation *anim, AnimationState state );
	void setAnimation( unsigned int index );
	void setTeamColor( glm::vec4 color ) { teamColor = glm::vec4( color ); }
	void setGhostVisible( bool vis ) { ghostVisible = vis; }
	void setGhostPosition( glm::vec3 pos ) { ghostPosition = pos; }
	void updateCoexistTransform()
	{
		if( !coexist ) return;
		coexistTransform = transform.extractRotation();
		coexistTransform.setPosition( coexistLocation->position + glm::vec3( 0, coexistLocation->height, 0 ) );
	}


	// Team *team;
	MapTile *location, *coexistLocation;
	// UnitWeapon *equipped;
	// std::vector<UnitWeapon> weapons;
	// std::vector<InventoryItem> items;
	std::vector<MapTile*> tiles;
	int maxEquip, maxItem, size, unitID, direction;
	int HP, STR, MAG, DEF, RES, SPD, CLK, MV, EVA;
	double growthHP, growthSTR, growthMAG, growthDEF, growthRES, growthSPD;
	double VIS, height;
	std::string name, bio, filename;
	Transform transform, coexistTransform;
	bool staticPosition, isMoving, ghostVisible, visible, enabled, coexist;
	std::vector<Node*> nodes;
	Model ringModel;
	glm::vec3 ghostPosition;
	
	std::vector<Weapon> weapons;
	Weapon *equipped;
	std::vector<Animation*> animations;
	Animation *currentAnimation;

private:
	Node* getNode( std::string name );
	void connectAnimation( Animation *animation );

	glm::vec4 teamColor;
};

