/*
 * Vec3.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#ifndef MATH_VEC3_H_
#define MATH_VEC3_H_

#include <string>

class Vec3
{
public:
	Vec3();
	Vec3( float x, float y, float z );
	Vec3( const Vec3 &v );
	Vec3( const float *data );
	
	// primary operators
	operator float*();
	float operator() ( int i ) const;
	float& operator() ( int i );
	Vec3& operator =( const Vec3 &v );
	Vec3 operator +( const Vec3 &v ) const;
	Vec3 operator -( const Vec3 &v ) const;
	Vec3 operator *( float c ) const;
	Vec3 operator *( const Vec3 &u ) const;
	
	float length() const;
	float lengthSqrd() const;
	
	// static utility
	static Vec3 Position( float x, float y, float z );
	static Vec3 Direction( float x, float y, float z );
	static float dot( const Vec3 &u, const Vec3 &v );
	static Vec3 normalize( const Vec3 &u );
	static Vec3 cross( const Vec3 &u, const Vec3 &v );
	
	// local
	Vec3& operator +=( const Vec3 &u );
	Vec3& operator -=( const Vec3 &u );
	Vec3& operator *=( float c );
	void set( const Vec3 &u );
	void set( float x, float y, float z );
	
	// accessors
	float x() const;
	float& x();
	float y() const;
	float& y();
	float z() const;
	float& z();
	
	// utility
	std::string toString() const;
	const char* to_string() const;
	
	float r[3];
	bool position;
};

// non-member functions
inline Vec3 operator* ( float c, const Vec3 &u ) { return Vec3( c*u(0), c*u(1), c*u(2) ); }
inline Vec3 normalize( const Vec3 &u ) { return Vec3::normalize( u ); }
inline Vec3 cross( const Vec3 &u, const Vec3 &v ) { return Vec3::cross( u, v ); }
inline float dot( const Vec3 &u, const Vec3 &v ) { return Vec3::dot( u, v ); }

#endif /* MATH_VEC3_H_ */
