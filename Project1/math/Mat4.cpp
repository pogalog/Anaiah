/*
 * Mat4.cpp
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 *  
 *  A column-major 4x4 matrix.
 *  [0 4 8  12]
 *  [1 5 9  13]
 *  [2 6 10 14]
 *  [3 7 11 15]
 */

#include "Mat4.h"
#include "Mat3.h"
#include "Vec3.h"
#include "Vec4.h"

#include <cmath>
#include <algorithm>
#include <cassert>


// constants
const float EPS = 1.0e-4;


/**
 * Initializes an identity matrix.
 */
Mat4::Mat4()
: m{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0}
{
}

Mat4::Mat4( float c )
: m{c, 0, 0, 0, 0, c, 0, 0, 0, 0, c, 0, 0, 0, 0, c}
{
}

/**
 * This constructor can make no guarantees is the size of data is
 * not at least 16 elements.
 */
Mat4::Mat4( const float *data )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] = data[i];
	}
}

Mat4::Mat4( const float *data, int size, int off )
{
	int n = std::min( size, 16-off );
	for( int i = off; i < off+n; ++i )
	{
		m[i-off] = data[i];
	}
}


Mat4::Mat4( const Vec3 &u, const Vec3 &v, const Vec3 &w )
{
	m[0] = u(0);
	m[1] = u(1);
	m[2] = u(2);
	m[4] = v(0);
	m[5] = v(1);
	m[6] = v(2);
	m[8] = w(0);
	m[9] = w(1);
	m[10] = w(2);
	
	m[3] = m[7] = m[11] = m[12] = m[13] = m[14] = 0.0;
	m[15] = 1.0;
}

Mat4::Mat4( const Vec4 &u, const Vec4 &v, const Vec4 &w, const Vec4 &r )
{
	m[0] = u(0); m[1] = u(1); m[2] = u(2); m[3] = u(3);
	m[4] = v(0); m[5] = v(1); m[6] = v(2); m[7] = v(3);
	m[8] = w(0); m[9] = w(1); m[10] = w(2); m[11] = w(3);
	m[12] = r(0); m[13] = r(1); m[14] = r(2); m[15] = r(3);
}

Mat4::Mat4( const Vec3 &axis, float angle )
{
	float x = axis.x();
	float y = axis.y();
	float z = axis.z();
	float c = cos( angle );
	float s = sin( angle );
	float t = 1 - c;
	
	m[0] = c + x*x*t;
	m[1] = x*y*t + s*z;
	m[2] = x*z*t - s*y;
	m[4] = x*y*t - s*z;
	m[5] = c + y*y*t;
	m[6] = y*z*t + s*x;
	m[8] = x*z*t + s*y;
	m[9] = y*z*t - s*x;
	m[10] = c + z*z*t;
	
	m[3] = m[7] = m[11] = m[12] = m[13] = m[14] = 0.0;
	m[15] = 1.0;
}

Mat4::Mat4( const Mat4 &A )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] = A(i);
	}
}

Mat4::Mat4( const Mat3 &A )
{
	m[0] = A(0);
	m[1] = A(1);
	m[2] = A(2);
	m[4] = A(3);
	m[5] = A(4);
	m[6] = A(5);
	m[8] = A(6);
	m[9] = A(7);
	m[10] = A(8);
	
	m[3] = m[7] = m[11] = m[12] = m[13] = m[14] = 0.0;
	m[15] = 0.0;
}



// primary operators
Mat4::operator float*()
{
	return m;
}
float Mat4::operator() ( int i ) const
{
	return m[i];
}
float& Mat4::operator() ( int i )
{
	return m[i];
}
float Mat4::operator() ( int row, int col ) const
{
	return m[4*col + row];
}
float& Mat4::operator() ( int row, int col )
{
	return m[4*col + row];
}

Mat4 Mat4::operator +( const Mat4 &A ) const
{
	float dat[] = {m[0]+A(0), m[1]+A(1), m[2]+A(2), m[3]+A(3),
					m[4]+A(4), m[5]+A(5), m[6]+A(6), m[7]+A(7),
					m[8]+A(8), m[9]+A(9), m[10]+A(10), m[11]+A(11),
					m[12]+A(12), m[13]+A(13), m[14]+A(14), m[15]+A(15)};
	Mat4 B( dat );
	return B;
}

Mat4 Mat4::operator -( const Mat4 &A ) const
{
	float dat[] = {m[0]-A(0), m[1]-A(1), m[2]-A(2), m[3]-A(3),
					m[4]-A(4), m[5]-A(5), m[6]-A(6), m[7]-A(7),
					m[8]-A(8), m[9]-A(9), m[10]-A(10), m[11]-A(11),
					m[12]-A(12), m[13]-A(13), m[14]-A(14), m[15]-A(15)};
	Mat4 B( dat );
	return B;
}

Mat4 Mat4::operator *( const Mat4 &A ) const
{
	Mat4 const &m0 = *this;
	Mat4 B = Mat4(0.0);
	for( int i = 0; i < 4; ++i )
	{
		for( int j = 0; j < 4; ++j )
		{
			for( int k = 0; k < 4; ++k )
			{
				B( i, j ) += m0( k, j ) * A( i, k );
			}
		}
	}
//	B( 0, 0 ) = m[0]*A(0) + m[4]*A(1) + m[8]*A(2) + m[12]*A(3);
//	B( 1, 0 ) = m[1]*A(0) + m[5]*A(1) + m[9]*A(2) + m[13]*A(3);
//	B( 2, 0 ) = m[2]*A(0) + m[6]*A(1) + m[10]*A(2) + m[14]*A(3);
//	B( 3, 0 ) = m[3]*A(0) + m[7]*A(1) + m[11]*A(2) + m[15]*A(3);
//	
//	B( 0, 1 ) = m[0]*A(4) + m[4]*A(5) + m[8]*A(6) + m[12]*A(7);
//	B( 1, 1 ) = m[1]*A(4) + m[5]*A(5) + m[9]*A(6) + m[13]*A(7);
//	B( 2, 1 ) = m[2]*A(4) + m[6]*A(5) + m[10]*A(6) + m[14]*A(7);
//	B( 3, 1 ) = m[3]*A(4) + m[7]*A(5) + m[11]*A(6) + m[15]*A(7);
//	
//	B( 0, 2 ) = m[0]*A(8) + m[4]*A(9) + m[8]*A(10) + m[12]*A(11);
//	B( 1, 2 ) = m[1]*A(8) + m[5]*A(9) + m[9]*A(10) + m[13]*A(11);
//	B( 2, 2 ) = m[2]*A(8) + m[6]*A(9) + m[10]*A(10) + m[14]*A(11);
//	B( 3, 2 ) = m[3]*A(8) + m[7]*A(9) + m[11]*A(10) + m[15]*A(11);
//	
//	B( 0, 3 ) = m[0]*A(12) + m[4]*A(13) + m[8]*A(14) + m[12]*A(15);
//	B( 1, 3 ) = m[1]*A(12) + m[5]*A(13) + m[9]*A(14) + m[13]*A(15);
//	B( 2, 3 ) = m[2]*A(12) + m[6]*A(13) + m[10]*A(14) + m[14]*A(15);
//	B( 3, 3 ) = m[3]*A(12) + m[7]*A(13) + m[11]*A(14) + m[15]*A(15);
	
	return B;
}

/*
 * Treat the Mat3 like a Mat4 in the following way
 * [m3 m3 m3 0]
 * [m3 m3 m3 0]
 * [m3 m3 m3 0]
 * [ 0  0  0 1]
 */
Mat4 Mat4::operator *( const Mat3 &A ) const
{
	Mat4 B;
	B( 0, 0 ) = m[0]*A(0) + m[4]*A(1) + m[8]*A(2);
	B( 1, 0 ) = m[1]*A(0) + m[5]*A(1) + m[9]*A(2);
	B( 2, 0 ) = m[2]*A(0) + m[6]*A(1) + m[10]*A(2);
	B( 3, 0 ) = m[3]*A(0) + m[7]*A(1) + m[11]*A(2);
	
	B( 0, 1 ) = m[0]*A(3) + m[4]*A(4) + m[8]*A(5);
	B( 1, 1 ) = m[1]*A(3) + m[5]*A(4) + m[9]*A(5);
	B( 2, 1 ) = m[2]*A(3) + m[6]*A(4) + m[10]*A(5);
	B( 3, 1 ) = m[3]*A(3) + m[7]*A(4) + m[11]*A(5);
	
	B( 0, 2 ) = m[0]*A(6) + m[4]*A(7) + m[8]*A(9);
	B( 1, 2 ) = m[1]*A(6) + m[5]*A(7) + m[9]*A(9);
	B( 2, 2 ) = m[2]*A(6) + m[6]*A(7) + m[10]*A(9);
	B( 3, 2 ) = m[3]*A(6) + m[7]*A(7) + m[11]*A(9);
	
	B( 0, 3 ) = m[12];
	B( 1, 3 ) = m[13];
	B( 2, 3 ) = m[14];
	B( 3, 3 ) = m[15];
	
	return B;
}

Vec3 Mat4::operator *( const Vec3 &u ) const
{
	return Vec3( m[0]*u(0) + m[4]*u(1) + m[8]*u(2) + u.position ? m[12] : 0.0,
				 m[1]*u(0) + m[5]*u(1) + m[9]*u(2) + u.position ? m[13] : 0.0,
				 m[2]*u(0) + m[6]*u(1) + m[10]*u(2)+ u.position ? m[14] : 0.0 );
}

Vec4 Mat4::operator *( const Vec4 &u ) const
{
	return Vec4( m[0]*u(0) + m[4]*u(1) + m[8]*u(2) + m[12]*u(3),
				 m[1]*u(0) + m[5]*u(1) + m[9]*u(2) + m[13]*u(3),
				 m[2]*u(0) + m[6]*u(1) + m[10]*u(2) + m[14]*u(3),
				 m[3]*u(0) + m[7]*u(1) + m[11]*u(2) + m[15]*u(3) );
}

Mat4 Mat4::operator *( float c ) const
{
	Mat4 A;
	for( int i = 0; i < 16; ++i )
	{
		A(i) = c * m[i];
	}
	return A;
}


// static
Mat4 Mat4::inv( const Mat4 &A )
{
	float invDet = 1.0 / det( A );
	Mat4 B;
	// temporarily keep for debugging purposes
//	B( 0, 0 ) = A(1,1)*A(2,2)*A(3,3) + A(1,2)*A(2,3)*A(3,1) + A(1,3)*A(2,1)*A(3,2) - A(1,1)*A(2,3)*A(3,2) - A(1,2)*A(2,1)*A(3,3) - A(1,3)*A(2,2)*A(3,1);
//	B( 0, 1 ) = A(0,1)*A(2,3)*A(3,2) + A(0,2)*A(2,1)*A(3,3) + A(0,3)*A(2,2)*A(3,1) - A(0,1)*A(2,2)*A(3,3) - A(0,2)*A(2,3)*A(3,1) - A(0,3)*A(2,1)*A(3,2);
//	B( 0, 2 ) = A(0,1)*A(1,2)*A(3,3) + A(0,2)*A(1,3)*A(3,1) + A(0,3)*A(1,1)*A(3,2) - A(0,1)*A(1,3)*A(3,2) - A(0,2)*A(1,1)*A(3,3) - A(0,3)*A(1,2)*A(3,1);
//	B( 0, 3 ) = A(0,1)*A(1,3)*A(2,2) + A(0,2)*A(1,1)*A(2,3) + A(0,3)*A(1,2)*A(2,1) - A(0,1)*A(1,2)*A(2,3) - A(0,2)*A(1,3)*A(2,1) - A(0,3)*A(1,1)*A(2,2);
//	
//	B( 1, 0 ) = A(1,0)*A(2,3)*A(3,2) + A(1,2)*A(2,0)*A(3,3) + A(1,3)*A(2,2)*A(3,0) - A(1,0)*A(2,2)*A(3,3) - A(1,2)*A(2,3)*A(3,0) - A(1,3)*A(2,0)*A(3,2);
//	B( 1, 1 ) = A(0,0)*A(2,2)*A(3,3) + A(0,2)*A(2,3)*A(3,0) + A(0,3)*A(2,0)*A(3,2) - A(0,0)*A(2,3)*A(3,2) - A(0,2)*A(2,0)*A(3,3) - A(0,3)*A(2,2)*A(3,0);
//	B( 1, 2 ) = A(0,0)*A(1,3)*A(3,2) + A(0,2)*A(1,0)*A(3,3) + A(0,3)*A(1,2)*A(3,0) - A(0,0)*A(1,2)*A(3,3) - A(0,2)*A(1,3)*A(3,0) - A(0,3)*A(1,0)*A(3,2);
//	B( 1, 3 ) = A(0,0)*A(1,2)*A(2,3) + A(0,2)*A(1,3)*A(2,0) + A(0,3)*A(1,0)*A(2,2) - A(0,0)*A(1,3)*A(2,2) - A(0,2)*A(1,0)*A(2,3) - A(0,3)*A(1,2)*A(2,0);
//	
//	B( 2, 0 ) = A(1,0)*A(2,1)*A(3,3) + A(1,1)*A(2,3)*A(3,0) + A(1,3)*A(2,0)*A(3,1) - A(1,0)*A(2,3)*A(3,1) - A(1,1)*A(2,0)*A(3,3) - A(1,3)*A(2,1)*A(3,0);
//	B( 2, 1 ) = A(0,0)*A(2,3)*A(3,1) + A(0,1)*A(2,0)*A(3,3) + A(0,3)*A(2,1)*A(3,0) - A(0,0)*A(2,1)*A(3,3) - A(0,1)*A(2,3)*A(3,0) - A(0,3)*A(2,0)*A(3,1);
//	B( 2, 2 ) = A(0,0)*A(1,1)*A(3,3) + A(0,1)*A(1,3)*A(3,0) + A(0,3)*A(1,0)*A(3,1) - A(0,0)*A(1,3)*A(3,1) - A(0,1)*A(1,0)*A(3,3) - A(0,3)*A(1,1)*A(3,0);
//	B( 2, 3 ) = A(0,0)*A(1,3)*A(2,1) + A(0,1)*A(1,0)*A(2,3) + A(0,3)*A(1,1)*A(2,0) - A(0,0)*A(1,1)*A(2,3) - A(0,1)*A(1,3)*A(2,0) - A(0,3)*A(1,0)*A(2,1);
//	
//	B( 3, 0 ) = A(1,0)*A(2,2)*A(3,1) + A(1,1)*A(2,0)*A(3,2) + A(1,2)*A(2,1)*A(3,0) - A(1,0)*A(2,1)*A(3,2) - A(1,1)*A(2,2)*A(3,0) - A(1,2)*A(2,0)*A(3,1);
//	B( 3, 1 ) = A(0,0)*A(2,1)*A(3,2) + A(0,1)*A(2,2)*A(3,0) + A(0,2)*A(2,0)*A(3,1) - A(0,0)*A(2,2)*A(3,1) - A(0,1)*A(2,0)*A(3,2) - A(0,2)*A(2,1)*A(3,0);
//	B( 3, 2 ) = A(0,0)*A(1,2)*A(3,1) + A(0,1)*A(1,0)*A(3,2) + A(0,2)*A(1,1)*A(3,0) - A(0,0)*A(1,1)*A(3,2) - A(0,1)*A(1,2)*A(3,0) - A(0,2)*A(1,0)*A(3,1);
//	B( 3, 3 ) = A(0,0)*A(1,1)*A(2,2) + A(0,1)*A(1,2)*A(2,0) + A(0,2)*A(1,0)*A(2,1) - A(0,0)*A(1,2)*A(2,1) - A(0,1)*A(1,0)*A(2,2) - A(0,2)*A(1,1)*A(2,0);
	
	B( 0, 0 ) = A(5)*A(10)*A(15) + A(9)*A(14)*A(7) + A(13)*A(6)*A(11) - A(5)*A(14)*A(11) - A(9)*A(6)*A(15) - A(13)*A(10)*A(7);
	B( 0, 1 ) = A(4)*A(14)*A(11) + A(8)*A(6)*A(15) + A(12)*A(10)*A(7) - A(4)*A(10)*A(15) - A(8)*A(14)*A(7) - A(12)*A(6)*A(11);
	B( 0, 2 ) = A(4)*A(9)*A(15) + A(8)*A(13)*A(7) + A(12)*A(5)*A(11) - A(4)*A(13)*A(11) - A(8)*A(5)*A(15) - A(12)*A(9)*A(7);
	B( 0, 3 ) = A(4)*A(13)*A(10) + A(8)*A(5)*A(14) + A(12)*A(9)*A(6) - A(4)*A(9)*A(14) - A(8)*A(3)*A(6) - A(12)*A(5)*A(10);
	
	B( 1, 0 ) = A(1)*A(14)*A(11) + A(9)*A(2)*A(15) + A(13)*A(10)*A(3) - A(1)*A(10)*A(15) - A(9)*A(14)*A(3) - A(13)*A(2)*A(11);
	B( 1, 1 ) = A(0)*A(10)*A(15) + A(8)*A(14)*A(3) + A(12)*A(2)*A(11) - A(0)*A(14)*A(11) - A(8)*A(2)*A(15) - A(12)*A(10)*A(3);
	B( 1, 2 ) = A(0)*A(13)*A(11) + A(8)*A(1)*A(15) + A(12)*A(9)*A(3) - A(0)*A(9)*A(15) - A(8)*A(13)*A(3) - A(12)*A(1)*A(11);
	B( 1, 3 ) = A(0)*A(9)*A(14) + A(8)*A(13)*A(2) + A(12)*A(1)*A(10) - A(0)*A(13)*A(10) - A(8)*A(1)*A(14) - A(12)*A(9)*A(2);
	
	B( 2, 0 ) = A(1)*A(6)*A(15) + A(5)*A(14)*A(3) + A(13)*A(2)*A(7) - A(1)*A(14)*A(7) - A(5)*A(2)*A(15) - A(13)*A(6)*A(3);
	B( 2, 1 ) = A(0)*A(14)*A(7) + A(4)*A(2)*A(15) + A(12)*A(6)*A(3) - A(0)*A(6)*A(15) - A(4)*A(14)*A(3) - A(12)*A(2)*A(7);
	B( 2, 2 ) = A(0)*A(5)*A(15) + A(4)*A(1,3)*A(3) + A(12)*A(1)*A(7) - A(0)*A(13)*A(7) - A(4)*A(1)*A(15) - A(12)*A(5)*A(3);
	B( 2, 3 ) = A(0)*A(13)*A(6) + A(4)*A(1)*A(14) + A(12)*A(5)*A(2) - A(0)*A(5)*A(14) - A(4)*A(13)*A(2) - A(12)*A(1)*A(6);
	
	B( 3, 0 ) = A(1)*A(10)*A(7) + A(5)*A(2)*A(11) + A(9)*A(6)*A(3) - A(1)*A(6)*A(11) - A(5)*A(10)*A(3) - A(9)*A(2)*A(7);
	B( 3, 1 ) = A(0)*A(6)*A(11) + A(4)*A(10)*A(3) + A(8)*A(2)*A(7) - A(0)*A(10)*A(7) - A(4)*A(2)*A(11) - A(8)*A(6)*A(3);
	B( 3, 2 ) = A(0)*A(9)*A(7) + A(4)*A(1)*A(11) + A(8)*A(5)*A(3) - A(0)*A(5)*A(11) - A(4)*A(9)*A(3) - A(8)*A(1)*A(7);
	B( 3, 3 ) = A(0)*A(5)*A(10) + A(4)*A(9)*A(2) + A(8)*A(1)*A(6) - A(0)*A(9)*A(6) - A(4)*A(1)*A(10) - A(8)*A(5)*A(2);
	
	return B * invDet;
}

/**
 * LookAt function lifted from glm. Assumes a right-handed coordinate system.
 */
Mat4 Mat4::lookAt( const Vec3 &eye, const Vec3 &center, const Vec3 &up )
{
	Vec3 const f( normalize( center - eye ) );
	Vec3 const s( normalize( cross( f, up ) ) );
	Vec3 const u( cross( s, f ) );

	Mat4 Result = Mat4();
	Result( 0, 0 ) = s.x();
	Result( 1, 0 ) = s.y();
	Result( 2, 0 ) = s.z();
	Result( 0, 1 ) = u.x();
	Result( 1, 1 ) = u.y();
	Result( 2, 1 ) = u.z();
	Result( 0, 2 ) =-f.x();
	Result( 1, 2 ) =-f.y();
	Result( 2, 2 ) =-f.z();
	Result( 3, 0 ) =-dot(s, eye);
	Result( 3, 1 ) =-dot(u, eye);
	Result( 3, 2 ) = dot(f, eye);
	return Result;
}

/**
 * Perspective projection function lifted from glm. Assumes a right-handed coordinate system.
 */
Mat4 Mat4::perspective( float fov, float aspect, float zNear, float zFar )
{
	assert( abs( aspect - EPS ) > 0 );
	float const tanHalfFov = tan( 0.5*fov );
	
	Mat4 Result = Mat4();
	Result( 0, 0 ) = 1.0 / (aspect * tanHalfFov);
	Result( 1, 1 ) = 1.0 / tanHalfFov;
	Result( 2, 2 ) = -(zFar + zNear) / (zFar - zNear);
	Result( 2, 3 ) = -1.0;
	Result( 3, 2 ) = -2.0 * zFar * zNear / (zFar - zNear);
	return Result;
}

/**
 * Orthographic projection function lifted from glm.
 */
Mat4 Mat4::ortho( float left, float right, float bottom, float top, float zNear, float zFar )
{
	Mat4 Result = Mat4();
	Result( 0, 0 ) = 2.0 / (right - left);
	Result( 1, 1 ) = 2.0 / (top - bottom);
	Result( 2, 2 ) = 2.0 / (zNear - zFar);
	Result( 3, 0 ) = (left + right) / (left - right);
	Result( 3, 1 ) = (bottom + top) / (bottom - top);
	Result( 3, 2 ) = (zNear + zFar) / (zNear - zFar);
	
	return Result;
}

float Mat4::det( const Mat4 &A )
{
	float val = A(0)*A(5)*A(10)*A(15) + A(0)*A(9)*A(14)*A(7) + A(0)*A(13)*A(6)*A(11);
	val += A(4)*A(1)*A(14)*A(11) + A(4)*A(9)*A(2)*A(15) + A(4)*A(13)*A(10)*A(3);
	val += A(8)*A(1)*A(6)*A(15) + A(8)*A(5)*A(14)*A(3) + A(8)*A(13)*A(2)*A(7);
	val += A(12)*A(1)*A(10)*A(7) + A(12)*A(5)*A(2)*A(11) + A(12)*A(9)*A(6)*A(3);
	val -= A(0)*A(5)*(14)*A(11) + A(0)*A(9)*A(6)*A(15) + A(0)*A(13)*A(10)*A(7);
	val -= A(4)*A(1)*A(10)*A(15) + A(4)*A(9)*A(14)*A(3) + A(4)*A(13)*A(2)*A(11);
	val -= A(8)*A(1)*A(14)*A(7) + A(8)*A(5)*A(2)*A(15) + A(8)*A(13)*A(6)*A(3);
	val -= A(12)*A(1)*A(6)*A(11) + A(12)*A(5)*A(10)*A(3) + A(12)*A(9)*A(2)*A(7);
	return val;
}


// local
Mat4& Mat4::operator +=( const Mat4 &A )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] += A(i);
	}
	return *this;
}

Mat4& Mat4::operator -=( const Mat4 &A )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] -= A(i);
	}
	return *this;
}

Mat4& Mat4::operator *=( const Mat4 &A )
{
	Mat4 B = *this * A;
	*this = B;			// should call the copy constructor
	return *this;
}

Mat4& Mat4::operator *=( float c )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] *= c;
	}
	return *this;
}

void Mat4::set( const Mat4 &A )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] = A(i);
	}
}

void Mat4::set( const float *data )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] = data[i];
	}
}

void Mat4::set( float c )
{
	for( int i = 0; i < 16; ++i )
	{
		m[i] = 0.0;
	}
	m[0] = m[5] = m[10] = m[15] = 1.0;
}

void Mat4::setLookAt( const Vec3 &eye, const Vec3 &center, const Vec3 &up )
{
	Vec3 const f( normalize( center - eye ) );
	Vec3 const s( normalize( cross( f, up ) ) );
	Vec3 const u( cross( s, f ) );
	
	Mat4 &Result = *this;
	Result.set( 1.0 );
	Result( 0, 0 ) = s.x();
	Result( 1, 0 ) = s.y();
	Result( 2, 0 ) = s.z();
	Result( 0, 1 ) = u.x();
	Result( 1, 1 ) = u.y();
	Result( 2, 1 ) = u.z();
	Result( 0, 2 ) =-f.x();
	Result( 1, 2 ) =-f.y();
	Result( 2, 2 ) =-f.z();
	Result( 3, 0 ) =-dot(s, eye);
	Result( 3, 1 ) =-dot(u, eye);
	Result( 3, 2 ) = dot(f, eye);
}

void Mat4::setPerspective( float fov, float aspect, float zNear, float zFar )
{
	assert( abs( aspect - EPS ) > 0 );
	float const tanHalfFov = tan( 0.5*fov );
	
	Mat4 &Result = *this; 
	Result.set( 1.0 );
	Result( 0, 0 ) = 1.0 / (aspect * tanHalfFov);
	Result( 1, 1 ) = 1.0 / tanHalfFov;
	Result( 2, 2 ) = -(zFar + zNear) / (zFar - zNear);
	Result( 2, 3 ) = -1.0;
	Result( 3, 2 ) = -2.0 * zFar * zNear / (zFar - zNear);
}

void Mat4::setOrtho( float left, float right, float bottom, float top, float zNear, float zFar )
{
	Mat4 &Result = *this; 
	Result.set( 1.0 );
	Result( 0, 0 ) = 2.0 / (right - left);
	Result( 1, 1 ) = 2.0 / (top - bottom);
	Result( 2, 2 ) = 2.0 / (zNear - zFar);
	Result( 3, 0 ) = (left + right) / (left - right);
	Result( 3, 1 ) = (bottom + top) / (bottom - top);
	Result( 3, 2 ) = (zNear + zFar) / (zNear - zFar);
}
