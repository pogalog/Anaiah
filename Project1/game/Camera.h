#pragma once 

#include "math/Transform.h"
#include "Lens.h"
#include "game/MapTile.h"

#include <glm/glm.hpp>

class Camera
{
public:
	Camera();
	~Camera();
	
	void move( const glm::vec3 &movement );
	void moveTo( const glm::vec3 &position );
	void lookAt( const glm::vec3 &center, const glm::vec3 &up );
	void lookAt( const glm::vec3 &center );
	void rotateX( float angle );
	void rotateY( float angle );
	void rotateZ( float angle );
	void orbitX( float angle );
	void orbitY( float angle );

	void lookDownAtTile( const MapTile *tile );
	void lookDownAtPosition( const glm::vec3 &position );

	void useOrthoLens() { activeLens = &orthoLens; }
	void usePerspectiveLens() { activeLens = &lens; }

	void update();

	void setMatrix( const glm::mat4 &m );
	void setMatrix();
	
	
	Transform transform;
	Lens lens;
	Lens orthoLens;
	Lens *activeLens;
	glm::vec3 velocity, acceleration, attachPoint, lookPoint, offset;
	float stiffness, damping, orbitRadius;
	float orbitHigh, orbitLow;
};

