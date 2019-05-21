/*
 * Vec2i.cpp
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#include "Vec2i.h"
#include <cmath>
#include <algorithm>

using namespace std;

Vec2i::Vec2i()
: x( 0 ), y( 0 )
{

}

Vec2i::Vec2i( int x, int y )
: x( x ), y( y )
{
	
}

Vec2i::Vec2i( const glm::ivec2 &v )
	: x( v.x ), y( v.y )
{

}

Vec2i::~Vec2i()
{
}

int Vec2i::hexDistanceTo( const Vec2i &v )
{
	int dx = abs( x - v.x );
	int dy = abs( y - v.y );
	return max( dx, dy );
}


// operators
void Vec2i::operator+=( const Vec2i &v )
{
	x += v.x;
	y += v.y;
}

Vec2i Vec2i::operator+( const Vec2i &v )
{
	return Vec2i( x + v.x, y + v.y );
}

bool Vec2i::operator ==( const Vec2i &v ) const
{
	return x == v.x && y == v.y;
}
