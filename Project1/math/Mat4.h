/*
 * Mat4.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#ifndef MATH_MAT4_H_
#define MATH_MAT4_H_

class Mat3;
class Vec3;
class Vec4;
class Mat4
{
public:
	Mat4();
	Mat4( float c );
	Mat4( const float *data );
	Mat4( const float *data, int size, int off );
	Mat4( const Vec3 &u, const Vec3 &v, const Vec3 &w );
	Mat4( const Vec4 &u, const Vec4 &v, const Vec4 &w, const Vec4 &r );
	Mat4( const Vec3 &axis, float angle );
	Mat4( const Mat3 &A );
	Mat4( const Mat4 &A );
	
	// primary operators
	operator float*();
	float operator() ( int i ) const;
	float& operator() ( int i );
	float operator() ( int row, int col ) const;
	float& operator() ( int row, int col );
	Mat4 operator +( const Mat4 &A ) const;
	Mat4 operator -( const Mat4 &A ) const;
	Mat4 operator *( const Mat4 &A ) const;
	Mat4 operator *( const Mat3 &A ) const;
	Vec3 operator *( const Vec3 &u ) const;
	Vec4 operator *( const Vec4 &u ) const;
	Mat4 operator *( float c ) const;
	
	// static utility
	static Mat4 inv( const Mat4 &A );
	static Mat4 lookAt( const Vec3 &eye, const Vec3 &center, const Vec3 &up );
	static Mat4 perspective( float fov, float aspect, float zNear, float zFar );
	static Mat4 ortho( float left, float right, float bottom, float top, float zNear, float zFar );
	static float det( const Mat4 &A );
	
	// local operation
	Mat4& operator +=( const Mat4 &A );
	Mat4& operator -=( const Mat4 &A );
	Mat4& operator *=( const Mat4 &A );
	Mat4& operator *=( float c );
	void set( const Mat4 &A );
	void set( const float *data );
	void set( float c );
	void setLookAt( const Vec3 &eye, const Vec3 &center, const Vec3 &up );
	void setPerspective( float fov, float aspect, float zNear, float zFar );
	void setOrtho( float left, float right, float bottom, float top, float zNear, float zFar );
	
	float m[16];
};

// non-member functions
inline Mat4 operator* ( float c, const Mat4 &A ) { return c * A; }
inline Mat4 inv( const Mat4 &A ) { return Mat4::inv( A ); }
inline Mat4 lookAt( const Vec3 &eye, const Vec3 &center, const Vec3 &up ) { return Mat4::lookAt( eye, center, up ); }
inline Mat4 perspective( float fov, float aspect, float zNear, float zFar ) { return Mat4::perspective( fov, aspect, zNear, zFar ); }
inline Mat4 ortho( float left, float right, float bottom, float top, float zNear, float zFar ) { return Mat4::ortho( left, right, bottom, top, zNear, zFar ); }
inline float det( const Mat4 &A ) { return Mat4::det( A ); }

#endif /* MATH_MAT4_H_ */
