/*
 * LightSource.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef RENDER_LIGHTSOURCE_H_
#define RENDER_LIGHTSOURCE_H_

#include "Color.h"

#include "glm/glm.hpp"

class LightSource
{
public:
	LightSource( const Color &c );
	~LightSource();
	
	Color color;
	glm::vec3 position;
	glm::vec3 direction;
	bool attenuate, spotlight;
	double constant, linear, quadratic, innerAngle, outerAngle, intensity;
};

#endif /* RENDER_LIGHTSOURCE_H_ */
