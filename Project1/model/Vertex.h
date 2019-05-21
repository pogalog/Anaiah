/*
 * Vertex.h
 *
 *  Created on: Mar 11, 2016
 *      Author: pogal
 */

#ifndef MODEL_VERTEX_H_
#define MODEL_VERTEX_H_

#include "math/Vec4.h"

#include <vector>

class Vertex
{
public:
	Vertex();
	Vertex( const Vec3 &p );
	Vertex( const Vec3 &p, const Vec2 &t );
	Vertex( const Vec3 &p, const Vec3 &n );
	Vertex( const Vec3 &p, const Vec2 &t, const Vec3 &n );
	~Vertex();
	
	
	std::vector<Vec4> attributes;
};

#endif /* MODEL_VERTEX_H_ */
