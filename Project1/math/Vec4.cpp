/*
 * Vec4.cpp
 *
 *  Created on: Mar 24, 2016
 *      Author: pogal
 */

#include "math/Vec4.h"

#include <cmath>
#include <cstdio>

Vec4::Vec4()
: r{ 0, 0, 0, 0 }
{
}

Vec4::Vec4( float x, float y, float z )
: r{ x, y, z, 0 }
{
	
}

Vec4::Vec4( float x, float y, float z, float w )
: r{ x, y, z, w }
{
	
}

Vec4::Vec4( const Vec2 &v )
: r{ v.r[0], v.r[1] }
{
	
}

Vec4::Vec4( const Vec3 &v )
: r{ v.r[0], v.r[1], v.r[2], 0 }
{
	
}

Vec4::Vec4( const Vec4 &v )
: r{ v.r[0], v.r[1], v.r[2], v.r[3] }
{
	
}

Vec4::~Vec4()
{
}


// primary operators
Vec4::operator float*()
{
	return r;
}

float Vec4::operator() ( int i ) const
{
	if( i < 0 || i > 3 )
	{
		// TODO throw Exception
		return 0;
	}
	return r[i];
}

float& Vec4::operator ()( int i )
{
	if( i < 0 || i > 3 )
	{
		// TODO throw Exception
	}
	return r[i];
}

Vec4& Vec4::operator=( const Vec4 &v )
{
	r[0] = v(0);
	r[1] = v(1);
	r[2] = v(2);
	r[3] = v(3);
	return *this;
}
Vec4& Vec4::operator=( const Vec3 &v )
{
	r[0] = v(0);
	r[1] = v(1);
	r[2] = v(2);
	r[3] = 0.0;
	return *this;
}
Vec4 Vec4::operator+( const Vec4& v ) const
{
	return Vec4( r[0] + v(0), r[1] + v(1), r[2] + v(2), r[3] + v(3) );
}
Vec4 Vec4::operator+( const Vec3 &v ) const
{
	return Vec4( r[0] + v(0), r[1] + v(1), r[2] + v(2), r[3] );
}
Vec4 Vec4::operator-( const Vec4& v ) const
{
	return Vec4( r[0] - v(0), r[1] - v(1), r[2] - v(2), r[3] - v(3) );
}
Vec4 Vec4::operator-( const Vec3 &v ) const
{
	return Vec4( r[0] - v(0), r[1] - v(1), r[2] - v(2), r[3] );
}
Vec4 Vec4::operator*( float c ) const
{
	return Vec4( c*r[0], c*r[1], c*r[2], c*r[3] );
}
Vec4 Vec4::operator*( const Vec4 &u ) const
{
	return Vec4( r[0]*u(0), r[1]*u(1), r[2]*u(2), r[3]*u(3) );
}

float Vec4::length() const
{
	return sqrt( dot( *this, *this ) );
}
float Vec4::lengthSqrd() const
{
	return dot( *this, *this );
}


// static utility
float Vec4::dot( const Vec4 &u, const Vec4 &v )
{
	return u(0)*v(0) + u(1)*v(1) + u(2)*v(2) + u(3)*v(3);
}
Vec4 Vec4::normalize( const Vec4 &u )
{
	double len = sqrt( dot( u, u ) );
	double invlen = len > 0.0 ? 1.0/len : 0.0;
	return u * invlen;
}


// accessors
float Vec4::x() const { return r[0]; }
float& Vec4::x() { return r[0]; }
float Vec4::y() const { return r[1]; }
float& Vec4::y() { return r[1]; }
float Vec4::z() const { return r[2]; }
float& Vec4::z() { return r[2]; }
float Vec4::w() const { return r[3]; }
float& Vec4::w() { return r[3]; }



std::string Vec4::toString() const
{
	char buffer[50];
	sprintf( buffer, "Vec4[%.3f, %.3f, %.3f, %.3f]", r[0], r[1], r[2], r[3] );
	return std::string( buffer );
}

const char* Vec4::to_string() const
{
	char buffer[50];
	sprintf( buffer, "Vec4[%.3f, %.3f, %.3f, %.3f]", r[0], r[1], r[2], r[3] );
	return std::string( buffer ).c_str();
}

