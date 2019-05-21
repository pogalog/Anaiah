/*
 * Vec4.h
 *
 *  Created on: Mar 24, 2016
 *      Author: pogal
 */

#ifndef MATH_VEC4_H_
#define MATH_VEC4_H_

#include "Vec2.h"
#include "Vec3.h"

class Vec4
{
public:
	Vec4();
	Vec4( float x, float y, float z );
	Vec4( float x, float y, float z, float w );
	Vec4( const Vec2 &v );
	Vec4( const Vec3 &v );
	Vec4( const Vec4 &v );
	Vec4( const float *data );
	~Vec4();
	
	// primary operators
	operator float*();
	float operator() ( int i ) const;
	float& operator() ( int i );
	Vec4& operator =( const Vec4 &v );
	Vec4& operator =( const Vec3 &v );
	Vec4 operator +( const Vec4 &v ) const;
	Vec4 operator +( const Vec3 &v ) const;
	Vec4 operator -( const Vec4 &v ) const;
	Vec4 operator -( const Vec3 &v ) const;
	Vec4 operator *( float c ) const;
	Vec4 operator *( const Vec4 &u ) const;
	
	float length() const;
	float lengthSqrd() const;
	
	// static
	static float dot( const Vec4 &u, const Vec4 &v );
	static Vec4 normalize( const Vec4 &u );
	
	// accessors
	float x() const;
	float& x();
	float y() const;
	float& y();
	float z() const;
	float& z();
	float w() const;
	float& w();
	
	
	// utility
	std::string toString() const;
	const char* to_string() const;
	
	float r[4];
};

// non-member
inline Vec4 operator* ( float c, const Vec4 &u ) { return Vec4( c*u(0), c*u(1), c*u(2) ); }
inline Vec4 normalize( const Vec4 &u ) { return Vec4::normalize( u ); }
inline float dot( const Vec4 &u, const Vec4 &v ) { return Vec4::dot( u, v ); }

#endif /* MATH_VEC4_H_ */
