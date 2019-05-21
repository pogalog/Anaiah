/*
 * Vec2i.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef MATH_VEC2I_H_
#define MATH_VEC2I_H_

#include <glm/glm.hpp>

class Vec2i
{
public:
	Vec2i();
	Vec2i( int x, int y );
	Vec2i( const glm::ivec2 &v );
	~Vec2i();
	
	int hexDistanceTo( const Vec2i &v );
	
	// operators
	void operator +=( const Vec2i &v );
	Vec2i operator +( const Vec2i &v );
	bool operator ==( const Vec2i &v ) const;

	
	int x;
	int y;
};

#endif /* MATH_VEC2I_H_ */
