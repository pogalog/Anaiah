/*
 * Vec3i.h
 *
 *  Created on: Mar 31, 2016
 *      Author: pogal
 */

#ifndef MATH_VEC3I_H_
#define MATH_VEC3I_H_

#include <string>

class Vec3i
{
public:
	Vec3i();
	Vec3i( int x, int y, int z );
	Vec3i( const int* data );
	Vec3i( const Vec3i &v );
	~Vec3i();
		
	// primary operators
	int operator() ( int i ) const;
	int& operator() ( int i );
	Vec3i& operator =( const Vec3i &v );
	Vec3i operator +( const Vec3i &v ) const;
	Vec3i operator -( const Vec3i &v ) const;
	Vec3i operator *( int c ) const;
	Vec3i operator *( const Vec3i &u ) const;
	
	double length() const;
	double lengthSqrd() const;
	
	// static utility
	static double dot( const Vec3i &u, const Vec3i &v );
	
	// local
	Vec3i& operator +=( const Vec3i &u );
	Vec3i& operator -=( const Vec3i &u );
	Vec3i& operator *=( int c );
	void set( const Vec3i &u );
	void set( int x, int y, int z );
	
	// accessors
	int x() const;
	int& x();
	int y() const;
	int& y();
	int z() const;
	int& z();
	
	// utility
	std::string toString() const;
	const char* to_string() const;
	
	int r[3];
};

#endif /* MATH_VEC3I_H_ */
