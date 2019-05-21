/*
 * Mat3.cpp
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 *      
 *  A column-major 3x3 matrix.
 *  [0 3 6]
 *  [1 4 7]
 *  [2 5 8]
 */

#include "Mat3.h"
#include "Vec3.h"
#include "Mat4.h"

#include <algorithm>
#include <cmath>

Mat3::Mat3()
: m{1, 0, 0, 0, 1, 0, 0, 0, 1}
{
}

/**
 * This constructor can make no guarantees is the size of data is
 * not at least nine elements.
 */
Mat3::Mat3( const float *data )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] = data[i];
	}
}

Mat3::Mat3( const float *data, int size, int off )
{
	int n = std::min( size, 9-off );
	for( int i = off; i < off+n; ++i )
	{
		m[i-off] = data[i];
	}
}


Mat3::Mat3( const Vec3 &u, const Vec3 &v, const Vec3 &w )
{
	m[0] = u(0);
	m[1] = u(1);
	m[2] = u(2);
	m[3] = v(0);
	m[4] = v(1);
	m[5] = v(2);
	m[6] = w(0);
	m[7] = w(1);
	m[8] = w(2);
}

Mat3::Mat3( const Vec3 &axis, float angle )
{
	double x = axis.x();
	double y = axis.y();
	double z = axis.z();
	double c = cos( angle );
	double s = sin( angle );
	double t = 1 - c;
	
	m[0] = c + x*x*t;
	m[1] = x*y*t + s*z;
	m[2] = x*z*t - s*y;
	m[3] = x*y*t - s*z;
	m[4] = c + y*y*t;
	m[5] = y*z*t + s*x;
	m[6] = x*z*t + s*y;
	m[7] = y*z*t - s*x;
	m[8] = c + z*z*t;
}

Mat3::Mat3( const Mat3 &A )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] = A(i);
	}
}


// primary operators
Mat3::operator float*()
{
	return m;
}
float Mat3::operator() ( int i ) const
{
	return m[i];
}
float& Mat3::operator() ( int i )
{
	return m[i];
}
float Mat3::operator() ( int row, int col ) const
{
	return m[3*col + row];
}
float& Mat3::operator() ( int row, int col )
{
	return m[3*col + row];
}
Vec3 Mat3::operator[] ( int col ) const
{
	return Vec3( m[3*col], m[3*col + 1], m[3*col + 2] );
}

Mat3 Mat3::operator +( const Mat3 &A ) const
{
	float dat[] = {m[0]+A(0), m[1]+A(1), m[2]+A(2),
					m[3]+A(3), m[4]+A(4), m[5]+A(5),
					m[6]+A(6), m[7]+A(7), m[8]+A(8)};
	Mat3 B( dat );
	return B;
}

Mat3 Mat3::operator -( const Mat3 &A ) const
{
	float dat[] = {m[0]-A(0), m[1]-A(1), m[2]-A(2),
					m[3]-A(3), m[4]-A(4), m[5]-A(5),
					m[6]-A(6), m[7]-A(7), m[8]-A(8)};
	Mat3 B( dat );
	return B;
}

Mat3 Mat3::operator *( const Mat3 &A ) const
{
	Mat3 B;
	B( 0, 0 ) = m[0]*A(0) + m[3]*A(1) + m[6]*A(2);
	B( 1, 0 ) = m[1]*A(0) + m[4]*A(1) + m[7]*A(2);
	B( 2, 0 ) = m[2]*A(0) + m[5]*A(1) + m[8]*A(2);
	
	B( 0, 1 ) = m[0]*A(3) + m[3]*A(4) + m[6]*A(5);
	B( 1, 1 ) = m[1]*A(3) + m[4]*A(4) + m[7]*A(5);
	B( 2, 1 ) = m[2]*A(3) + m[5]*A(4) + m[8]*A(5);
	
	B( 0, 2 ) = m[0]*A(6) + m[3]*A(7) + m[6]*A(8);
	B( 1, 2 ) = m[1]*A(6) + m[4]*A(7) + m[7]*A(8);
	B( 2, 2 ) = m[2]*A(6) + m[5]*A(7) + m[8]*A(8);
	
	return B;
}

/**
 * Ignore the last row and column of the Mat4.
 * [m0 m3 m6] [A0 A4 A8 ]
 * [m1 m4 m7]x[A1 A5 A9 ]
 * [m2 m5 m8] [A2 A6 A10]
 */
Mat3 Mat3::operator *( const Mat4 &A ) const
{
	Mat3 B;
	B( 0, 0 ) = m[0]*A(0) + m[3]*A(1) + m[6]*A(2);
	B( 1, 0 ) = m[1]*A(0) + m[4]*A(1) + m[7]*A(2);
	B( 2, 0 ) = m[2]*A(0) + m[5]*A(1) + m[8]*A(2);
	
	B( 0, 1 ) = m[0]*A(4) + m[3]*A(5) + m[6]*A(6);
	B( 1, 1 ) = m[1]*A(4) + m[4]*A(5) + m[7]*A(6);
	B( 2, 1 ) = m[2]*A(4) + m[5]*A(5) + m[8]*A(6);
	
	B( 0, 2 ) = m[0]*A(8) + m[3]*A(9) + m[6]*A(10);
	B( 1, 2 ) = m[1]*A(8) + m[4]*A(9) + m[7]*A(10);
	B( 2, 2 ) = m[2]*A(8) + m[5]*A(9) + m[8]*A(10);
	
	return B;
}

Vec3 Mat3::operator *( const Vec3 &u ) const
{
	return Vec3( m[0]*u(0) + m[3]*u(1) + m[6]*u(2),
				 m[1]*u(0) + m[4]*u(1) + m[7]*u(2),
				 m[2]*u(0) + m[5]*u(1) + m[8]*u(2) );
}

Mat3 Mat3::operator *( float c ) const
{
	float dat[] =	{c*m[0], c*m[1], c*m[2],
					 c*m[3], c*m[4], c*m[5],
					 c*m[6], c*m[7], c*m[8] };
	return Mat3( dat );
}

// static utility
Mat3 Mat3::inv( const Mat3 &A )
{
	double invDet = 1.0 / det( A );
	Mat3 B;
	B( 0, 0 ) = B(4)*B(8) - B(5)*B(7);
	B( 1, 0 ) = B(7)*B(2) - B(8)*B(1);
	B( 2, 0 ) = B(1)*B(5) - B(2)*B(4);
	
	B( 0, 1 ) = B(6)*B(5) - B(8)*B(3);
	B( 1, 1 ) = B(0)*B(8) - B(2)*B(6);
	B( 2, 1 ) = B(6)*B(1) - B(7)*B(0);
	
	B( 0, 2 ) = B(1)*B(5) - B(2)*B(4);
	B( 1, 2 ) = B(3)*B(2) - B(5)*B(0);
	B( 2, 2 ) = B(0)*B(4) - B(1)*B(3);
	return invDet * B;
}

float Mat3::det( const Mat3 &A )
{
	double val = A(0)*(A(4)*A(8) - A(5)*A(7));
	val -= A(3)*(A(1)*A(8) - A(2)*A(7));
	val += A(6)*(A(1)*A(5) - A(2)*A(4));
	return val;
}



// local
Mat3& Mat3::operator +=( const Mat3& A )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] += A(i);
	}
	return *this;
}

Mat3& Mat3::operator -=( const Mat3& A )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] -= A(i);
	}
	return *this;
}

Mat3& Mat3::operator *=( const Mat3 &A )
{
	Mat3 B = *this * A;
	*this = B;			// should call the copy constructor
	return *this;
}

Mat3& Mat3::operator *=( float c )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] *= c;
	}
	return *this;
}

void Mat3::set( const Mat3 &A )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] = A(i);
	}
}

void Mat3::set( const float *data )
{
	for( int i = 0; i < 9; ++i )
	{
		m[i] = data[i];
	}
}






