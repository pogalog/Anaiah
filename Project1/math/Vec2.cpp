/*
 * Vec2.cpp
 *
 *  Created on: Mar 23, 2016
 *      Author: pogal
 */

#include <math/Vec2.h>

#include <cmath>
#include <cstdio>


Vec2::Vec2()
: r{0, 0} 
{
}

Vec2::Vec2( float x, float y )
: r{x, y}
{
	
}

Vec2::Vec2( const Vec2 &v )
: r{v.r[0], v.r[1]}
{
	
}

Vec2::~Vec2()
{
}


// primary operators
float Vec2::operator() ( int i ) const
{
	if( i < 0 || i > 1 )
	{
		// TODO throw Exception
		return 0;
	}
	return r[i];
}

float& Vec2::operator ()( int i )
{
	if( i < 0 || i > 1 )
	{
		// TODO throw Exception
	}
	return r[i];
}

Vec2& Vec2::operator=( const Vec2 &v )
{
	r[0] = v(0);
	r[1] = v(1);
	return *this;
}
Vec2 Vec2::operator+( const Vec2& v ) const
{
	return Vec2( r[0] + v(0), r[1] + v(1) );
}
Vec2 Vec2::operator-( const Vec2& v ) const
{
	return Vec2( r[0] - v(0), r[1] - v(1) );
}
Vec2 Vec2::operator*( float c ) const
{
	return Vec2( c*r[0], c*r[1] );
}
Vec2 Vec2::operator*( const Vec2 &u ) const
{
	return Vec2( r[0]*u(0), r[1]*u(1) );
}
float Vec2::length() const
{
	return sqrt( dot( *this, *this ) );
}
float Vec2::lengthSqrd() const
{
	return dot( *this, *this );
}


// static utility
float Vec2::dot( const Vec2 &u, const Vec2 &v )
{
	return u(0)*v(0) + u(1)*v(1) + u(2)*v(2);
}
Vec2 Vec2::normalize( Vec2 &u )
{
	float invlen = 1.0/sqrt( dot( u, u ) );
	return u = u * invlen;
}
float Vec2::cross( const Vec2 &u, const Vec2 &v )
{
	return u(0)*v(1) - u(1)*v(0);
}


// local
Vec2& Vec2::operator+=( const Vec2 &u )
{
	r[0] += u(0);
	r[1] += u(1);
	return *this;
}

Vec2& Vec2::operator-=( const Vec2 &u )
{
	r[0] -= u(0);
	r[1] -= u(1);
	return *this;
}

Vec2& Vec2::operator*=( float c )
{
	r[0] *= c;
	r[1] *= c;
	return *this;
}

/**
 * This is actually the same as the copy constructor. Probably should just use that, instead.
 */
void Vec2::set( const Vec2 &u )
{
	r[0] = u.r[0];
	r[1] = u.r[1];
}

void Vec2::set( float x, float y )
{
	r[0] = x;
	r[1] = y;
}


// accessors
float Vec2::x() const
{
	return r[0];
}
float& Vec2::x()
{
	return r[0];
}
float Vec2::y() const
{
	return r[1];
}
float& Vec2::y()
{
	return r[1];
}


// utility
std::string Vec2::toString() const
{
	char buffer[50];
	sprintf( buffer, "Vec2[%.3f, %.3f]", r[0], r[1] );
	return std::string( buffer );
}

const char* Vec2::to_string() const
{
	char buffer[50];
	sprintf( buffer, "Vec2[%.3f, %.3f]", r[0], r[1] );
	return std::string( buffer ).c_str();
}
