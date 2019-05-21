/*
 * Lens.cpp
 *
 *  Created on: Apr 15, 2016
 *      Author: pogal
 */

#include "game/Lens.h"

#include <glm/gtc/matrix_transform.hpp>
#include <cassert>
#include <cmath>
#include <cstdlib>

// constants
const float EPS = 1.0e-4f;

Lens::Lens()
: fov(60.0f), aspect(16.0f/9.0f), zNear(0.1f), zFar(1000.0f),
  left(0.0f), right(1920.0f), bottom(0.0f), top(1080.0f)
{
}

Lens::Lens( float fov, float aspect, float zNear, float zFar )
: fov(fov), aspect(aspect), zNear(zNear), zFar(zFar),
  left(0.0f), right(1920.0f), bottom(0.0f), top(1080.0f)
{
	perspective();
}

Lens::Lens( float left, float right, float bottom, float top, float zNear, float zFar )
: fov(60.0f), aspect(16.0f/9.0f), zNear(zNear), zFar(zFar),
  left(left), right(right), bottom(bottom), top(top)
{
	ortho();
}



Lens::~Lens()
{
}

void Lens::perspective()
{
	projectionMatrix = glm::perspective( fov, aspect, zNear, zFar );
}

void Lens::perspective( float fov, float aspect, float zNear, float zFar )
{
	this->fov = fov;
	this->aspect = aspect;
	this->zNear = zNear;
	this->zFar = zFar;
	
	projectionMatrix = glm::perspective( fov, aspect, zNear, zFar );
}

void Lens::ortho()
{
	projectionMatrix = glm::ortho( left, right, bottom, top );
}

void Lens::ortho( float left, float right, float bottom, float top, float zNear, float zFar )
{
	this->left = left;
	this->right = right;
	this->bottom = bottom;
	this->top = top;
	this->zNear = zNear;
	this->zFar = zFar;
	
	projectionMatrix = glm::ortho( left, right, bottom, top );
}

