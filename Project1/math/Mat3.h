/*
 * Mat3.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 *  
 *  A column-major 3x3 matrix.
 *  [0 3 6]
 *  [1 4 7]
 *  [2 5 8]
 */

#ifndef MATH_MAT3_H_
#define MATH_MAT3_H_

class Vec3;
class Mat4;
class Mat3
{
public:
	Mat3();
	Mat3( const float *data );
	Mat3( const float *data, int size, int off );
	Mat3( const Vec3 &u, const Vec3 &v, const Vec3 &w );
	Mat3( const Vec3 &axis, float angle );
	Mat3( const Mat3 &A );
	
	// primary operators
	operator float*();
	float operator() ( int i ) const;
	float& operator() ( int i );
	float operator() ( int row, int col ) const;
	float& operator() ( int row, int col );
	Vec3 operator[] ( int col ) const;
	Mat3 operator +( const Mat3 &A ) const;
	Mat3 operator -( const Mat3 &A ) const;
	Mat3 operator *( const Mat3 &A ) const;
	Mat3 operator *( const Mat4 &A ) const;
	Vec3 operator *( const Vec3 &u ) const;
	Mat3 operator *( float c ) const;
	
	// static utility
	static Mat3 inv( const Mat3 &A );
	static float det( const Mat3 &A );
	
	// local operation
	Mat3& operator +=( const Mat3 &A );
	Mat3& operator -=( const Mat3 &A );
	Mat3& operator *=( const Mat3 &A );
	Mat3& operator *=( float c );
	void set( const Mat3 &A );
	void set( const float *data );
	
	
	float m[9];
};

// non-member functions
inline Mat3 operator* ( double c, const Mat3 &A ) { return c * A; }
inline Mat3 inv( const Mat3 &A ) { return Mat3::inv( A ); }
inline double det( const Mat3 &A ) { return Mat3::det( A ); }

#endif /* MATH_MAT3_H_ */
