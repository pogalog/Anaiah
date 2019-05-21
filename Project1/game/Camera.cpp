/*
 * Camera.cpp
 *
 *  Created on: Apr 15, 2016
 *      Author: pogal
 */

#include "game/Camera.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <iostream>

using namespace std;
using namespace glm;

Camera::Camera()
{
	orthoLens = Lens( 0, 1920, 0, 1080, -1, 1 );

	stiffness = 100.0f;
	damping = 15.0f;
	orbitRadius = 10;
	offset = vec3( 0, orbitRadius, orbitRadius );
	orbitLow = 0.125f;
	orbitHigh = 1.35f;
}

Camera::~Camera()
{
}

void Camera::move( const glm::vec3 &movement )
{
	transform.position += movement;
	setMatrix();
}

void Camera::moveTo( const glm::vec3 &position )
{
	transform.setPosition( position );
}

void Camera::lookAt( const glm::vec3 &center, const glm::vec3 &up )
{
	transform.localZ = glm::normalize( vec3( center - transform.position ) );
	transform.localX = glm::normalize( glm::cross( transform.localY, transform.localZ ) );
	transform.localY = glm::cross( transform.localZ, transform.localX );

	transform.matrix = glm::lookAt( transform.position, center, transform.localY );
}

void Camera::lookAt( const glm::vec3 &center )
{
	transform.localY = vec3( 0, 1, 0 );
	transform.localZ = glm::normalize( vec3( center - transform.position ) );
	transform.localX = glm::normalize( glm::cross( transform.localY, transform.localZ ) );
	transform.localY = glm::cross( transform.localZ, transform.localX );

	transform.matrix = glm::lookAt( transform.position, center, transform.localY );
}

void Camera::rotateX( float angle )
{
	transform.rotateX( angle );
}

void Camera::rotateY( float angle )
{
	transform.rotateY( angle );
}

void Camera::rotateZ( float angle )
{
	transform.rotateZ( angle );
}

void Camera::orbitX( float angle )
{
	// find distance and vector from axis
	vec3 axis = vec3( 0, 1, 0 );
	float dist = glm::length( glm::cross( axis, offset ) );
	vec3 pointOnAxis = lookPoint + vec3( 0, transform.position.y - lookPoint.y, 0 );
	vec4 axisToPoint = vec4( offset.x, 0.0, offset.z, 0.0f );

	// rotate about vertical axis
	mat4 rotation = Transform::getRotationY( angle );
	axisToPoint = rotation * axisToPoint;
	offset = vec3( axisToPoint.x, offset.y, axisToPoint.z );
	attachPoint = lookPoint + offset;
}

void Camera::orbitY( float angle )
{
	vec3 axis = transform.localX;
	// check bounds
	float currentAngle = acos( offset.y / glm::length( offset ) );
	
	float newAngle = currentAngle + angle;
	if( newAngle < orbitLow ) angle -= orbitLow - newAngle;
	if( newAngle > orbitHigh ) angle += newAngle - orbitHigh;
	mat4 rotation = Transform::getRotation( axis, angle );
	offset = vec3( rotation * vec4( offset, 0.0 ) );
	attachPoint = lookPoint + offset;
}


void Camera::setMatrix( const glm::mat4 &matrix )
{
	transform.matrix = mat4( matrix );

	transform.position.x = -matrix[3][0];
	transform.position.y = -matrix[3][1];
	transform.position.z = -matrix[3][2];

	vec3 Sx = vec3( matrix[0] );
	vec3 Sy = vec3( matrix[1] );
	vec3 Sz = vec3( matrix[2] );
	float sx = glm::length( Sx );
	float sy = glm::length( Sy );
	float sz = glm::length( Sz );

	transform.scale = vec3( sx, sy, sz );
	transform.localX = vec3( matrix[0][0] / sx, matrix[1][0] / sy, matrix[2][0] / sz );
	transform.localY = vec3( matrix[0][1] / sx, matrix[1][1] / sy, matrix[2][1] / sz );
	transform.localZ = vec3( matrix[0][2] / sx, matrix[1][2] / sy, matrix[2][2] / sz );
}

void Camera::setMatrix()
{
	mat4 &matrix = transform.matrix;
	vec3 &localX = transform.localX;
	vec3 &localY = transform.localY;
	vec3 &localZ = transform.localZ;
	vec3 &position = transform.position;
	transform.matrix = glm::lookAt( transform.position, transform.position + transform.localZ, transform.localY );

	//matrix[0][0] = localX.x * transform.scale.x;
	//matrix[1][0] = localY.x * transform.scale.y;
	//matrix[2][0] = localZ.x * transform.scale.z;
	//matrix[3][0] = 0.0;
	//matrix[0][1] = localX.y * transform.scale.x;
	//matrix[1][1] = localY.y * transform.scale.y;
	//matrix[2][1] = localZ.y * transform.scale.z;
	//matrix[3][1] = 0.0;
	//matrix[0][2] = localX.z * transform.scale.x;
	//matrix[1][2] = localY.z * transform.scale.y;
	//matrix[2][2] = localZ.z * transform.scale.z;
	//matrix[3][2] = 0.0;
	//matrix[3][0] = matrix[0][0] * position.x + matrix[1][0] * position.y + matrix[2][0] * position.z;
	//matrix[3][1] = matrix[0][1] * position.x + matrix[1][1] * position.y + matrix[2][1] * position.z;
	//matrix[3][2] = matrix[0][2] * position.x + matrix[1][2] * position.y + matrix[2][2] * position.z;
	//matrix[3][3] = 1.0;

	//matrix[3][0] *= -1;
	//matrix[3][1] *= -1;
	//matrix[3][2] *= -1;
}


void Camera::lookDownAtTile( const MapTile *tile )
{
	if( !tile ) return;

	attachPoint = tile->position + offset;
}

void Camera::lookDownAtPosition( const vec3 &position )
{
	attachPoint = position + offset;
}

void Camera::update()
{
	float dt = 0.016f;
	acceleration = -stiffness * (transform.position - attachPoint) - damping * velocity;
	velocity += acceleration * dt;
	lookPoint += velocity * dt;
	transform.position = lookPoint + offset;

	lookAt( lookPoint );
}
