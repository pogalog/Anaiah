/*
 * Vec3i.cpp
 *
 *  Created on: Mar 31, 2016
 *      Author: pogal
 */

#include "math/Vec3i.h"

#include <cmath>
#include <cstdio>

using namespace std;

Vec3i::Vec3i()
: r{0, 0, 0}
{
}

Vec3i::Vec3i( int x, int y, int z )
:r{x, y, z}
{
}

Vec3i::Vec3i( const int *data )
{
	if( data )
	{
		r[0] = data[0];
		r[1] = data[1];
		r[2] = data[2];
	}
}

/**
 * Copy ctor
 */
Vec3i::Vec3i( const Vec3i &v )
{
	r[0] = v.r[0];
	r[1] = v.r[1];
	r[2] = v.r[2];
}

Vec3i::~Vec3i()
{
	
}

// primary operators
int Vec3i::operator() ( int i ) const
{
	if( i < 0 || i > 2 )
	{
		// TODO throw Exception
		return 0;
	}
	return r[i];
}

int& Vec3i::operator ()( int i )
{
	if( i < 0 || i > 2 )
	{
		// TODO throw Exception
	}
	return r[i];
}

Vec3i& Vec3i::operator=( const Vec3i &v )
{
	r[0] = v(0);
	r[1] = v(1);
	r[2] = v(2);
	return *this;
}
Vec3i Vec3i::operator+( const Vec3i& v ) const
{
	return Vec3i( r[0] + v(0), r[1] + v(1), r[2] + v(2) );
}
Vec3i Vec3i::operator-( const Vec3i& v ) const
{
	return Vec3i( r[0] - v(0), r[1] - v(1), r[2] - v(2) );
}
Vec3i Vec3i::operator*( int c ) const
{
	return Vec3i( c*r[0], c*r[1], c*r[2] );
}
Vec3i Vec3i::operator*( const Vec3i &u ) const
{
	return Vec3i( r[0]*u(0), r[1]*u(1), r[2]*u(2) );
}
double Vec3i::length() const
{
	return sqrt( dot( *this, *this ) );
}
double Vec3i::lengthSqrd() const
{
	return dot( *this, *this );
}


// static utility
double Vec3i::dot( const Vec3i &u, const Vec3i &v )
{
	return u(0)*v(0) + u(1)*v(1) + u(2)*v(2);
}


// local
Vec3i& Vec3i::operator+=( const Vec3i &u )
{
	r[0] += u(0);
	r[1] += u(1);
	r[2] += u(2);
	return *this;
}

Vec3i& Vec3i::operator-=( const Vec3i &u )
{
	r[0] -= u(0);
	r[1] -= u(1);
	r[2] -= u(2);
	return *this;
}

Vec3i& Vec3i::operator*=( int c )
{
	r[0] *= c;
	r[1] *= c;
	r[2] *= c;
	return *this;
}

/**
 * This is actually the same as the copy constructor. Probably should just use that, instead.
 */
void Vec3i::set( const Vec3i &u )
{
	r[0] = u.r[0];
	r[1] = u.r[1];
	r[2] = u.r[2];
}

void Vec3i::set( int x, int y, int z )
{
	r[0] = x;
	r[1] = y;
	r[2] = z;
}

// accessors
int Vec3i::x() const
{
	return r[0];
}
int& Vec3i::x()
{
	return r[0];
}
int Vec3i::y() const
{
	return r[1];
}
int& Vec3i::y()
{
	return r[1];
}
int Vec3i::z() const
{
	return r[2];
}
int& Vec3i::z()
{
	return r[2];
}


// utility
string Vec3i::toString() const
{
	char buffer[50];
	sprintf_s( buffer, "Vec3[%d, %d, %d]", r[0], r[1], r[2] );
	return string( buffer );
}

const char* Vec3i::to_string() const
{
	char buffer[50];
	sprintf_s( buffer, "Vec3[%d, %d, %d]", r[0], r[1], r[2] );
	return string( buffer ).c_str();
}
