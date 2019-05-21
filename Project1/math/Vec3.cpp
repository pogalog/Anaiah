/*
 * Vec3.cpp
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#include "Vec3.h"

#include <cmath>
#include <cstdio>

Vec3::Vec3()
: r{0, 0, 0}, position( false )
{
}

Vec3::Vec3( float x, float y, float z )
:r{x, y, z}, position( false )
{
}

Vec3::Vec3( const float *data )
{
	if( data )
	{
		r[0] = data[0];
		r[1] = data[1];
		r[2] = data[2];
	}
	position = false;
}

/**
 * Copy ctor
 */
Vec3::Vec3( const Vec3 &v )
{
	r[0] = v.r[0];
	r[1] = v.r[1];
	r[2] = v.r[2];
	position = v.position;
}

// primary operators
Vec3::operator float*()
{
	return r;
}

float Vec3::operator() ( int i ) const
{
	if( i < 0 || i > 2 )
	{
		// TODO throw Exception
		return 0;
	}
	return r[i];
}

float& Vec3::operator ()( int i )
{
	if( i < 0 || i > 2 )
	{
		// TODO throw Exception
	}
	return r[i];
}

Vec3& Vec3::operator=( const Vec3 &v )
{
	r[0] = v(0);
	r[1] = v(1);
	r[2] = v(2);
	return *this;
}
Vec3 Vec3::operator+( const Vec3& v ) const
{
	return Vec3( r[0] + v(0), r[1] + v(1), r[2] + v(2) );
}
Vec3 Vec3::operator-( const Vec3& v ) const
{
	return Vec3( r[0] - v(0), r[1] - v(1), r[2] - v(2) );
}
Vec3 Vec3::operator*( float c ) const
{
	return Vec3( c*r[0], c*r[1], c*r[2] );
}
Vec3 Vec3::operator*( const Vec3 &u ) const
{
	return Vec3( r[0]*u(0), r[1]*u(1), r[2]*u(2) );
}
float Vec3::length() const
{
	return sqrt( dot( *this, *this ) );
}
float Vec3::lengthSqrd() const
{
	return dot( *this, *this );
}


// static utility
Vec3 Vec3::Position( float x, float y, float z )
{
	Vec3 v = Vec3( x, y, z );
	v.position = true;
	return v;
}
Vec3 Vec3::Direction( float x, float y, float z )
{
	Vec3 v = Vec3( x, y, z );
	v.position = false;
	return v;
}
float Vec3::dot( const Vec3 &u, const Vec3 &v )
{
	return u(0)*v(0) + u(1)*v(1) + u(2)*v(2);
}
Vec3 Vec3::normalize( const Vec3 &u )
{
	double len = sqrt( dot( u, u ) );
	double invlen = len > 0 ? 1.0/len : 0.0;
	return u * invlen;
}
Vec3 Vec3::cross( const Vec3 &u, const Vec3 &v )
{
	return Vec3( u(1)*v(2) - u(2)*v(1), u(2)*v(0) - u(0)*v(2), u(0)*v(1) - u(1)*v(0) );
}


// local
Vec3& Vec3::operator+=( const Vec3 &u )
{
	r[0] += u(0);
	r[1] += u(1);
	r[2] += u(2);
	return *this;
}

Vec3& Vec3::operator-=( const Vec3 &u )
{
	r[0] -= u(0);
	r[1] -= u(1);
	r[2] -= u(2);
	return *this;
}

Vec3& Vec3::operator*=( float c )
{
	r[0] *= c;
	r[1] *= c;
	r[2] *= c;
	return *this;
}

/**
 * This is actually the same as the copy constructor. Probably should just use that, instead.
 */
void Vec3::set( const Vec3 &u )
{
	r[0] = u.r[0];
	r[1] = u.r[1];
	r[2] = u.r[2];
}

void Vec3::set( float x, float y, float z )
{
	r[0] = x;
	r[1] = y;
	r[2] = z;
}

// accessors
float Vec3::x() const
{
	return r[0];
}
float& Vec3::x()
{
	return r[0];
}
float Vec3::y() const
{
	return r[1];
}
float& Vec3::y()
{
	return r[1];
}
float Vec3::z() const
{
	return r[2];
}
float& Vec3::z()
{
	return r[2];
}


// utility
std::string Vec3::toString() const
{
	char buffer[50];
	sprintf( buffer, "Vec3[%.3f, %.3f, %.3f]", r[0], r[1], r[2] );
	return std::string( buffer );
}

const char* Vec3::to_string() const
{
	char buffer[50];
	sprintf( buffer, "Vec3[%.3f, %.3f, %.3f]", r[0], r[1], r[2] );
	return std::string( buffer ).c_str();
}


