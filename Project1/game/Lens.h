/*
 * Lens.h
 *
 *  Created on: Apr 15, 2016
 *      Author: pogal
 */

#ifndef GAME_LENS_H_
#define GAME_LENS_H_

#include <glm/glm.hpp>


class Lens
{
public:
	Lens();
	Lens( float fov, float aspect, float zNear, float zFar );
	Lens( float left, float right, float bottom, float top, float zNear, float zFar );
	~Lens();
	
	void perspective( float fov, float aspect, float zNear, float zFar );
	void perspective();
	void ortho( float left, float right, float bottom, float top, float zNear, float zFar );
	void ortho();
	
	glm::mat4 projectionMatrix;
	float fov, aspect, zNear, zFar;
	float left, right, bottom, top;
};

#endif /* GAME_LENS_H_ */
