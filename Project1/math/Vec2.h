/*
 * Vec2.h
 *
 *  Created on: Mar 23, 2016
 *      Author: pogal
 */

#ifndef MATH_VEC2_H_
#define MATH_VEC2_H_

#include <string>

class Vec2
{
public:
	Vec2();
	Vec2( float x, float y );
	Vec2( const Vec2 &v );
	~Vec2();
		
	// primary operators
	float operator() ( int i ) const;
	float& operator() ( int i );
	Vec2& operator =( const Vec2 &v );
	Vec2 operator +( const Vec2 &v ) const;
	Vec2 operator -( const Vec2 &v ) const;
	Vec2 operator *( float c ) const;
	Vec2 operator *( const Vec2 &u ) const;
	
	float length() const;
	float lengthSqrd() const;
	
	// static utility
	static float dot( const Vec2 &u, const Vec2 &v );
	static Vec2 normalize( Vec2 &u );
	static float cross( const Vec2 &u, const Vec2 &v );
	
	// local
	Vec2& operator +=( const Vec2 &u );
	Vec2& operator -=( const Vec2 &u );
	Vec2& operator *=( float c );
	void set( const Vec2 &u );
	void set( float x, float y );
	
	// accessors
	float x() const;
	float& x();
	float y() const;
	float& y();
	
	// utility
	std::string toString() const;
	const char* to_string() const;
	
	float r[2];
};

#endif /* MATH_VEC2_H_ */
