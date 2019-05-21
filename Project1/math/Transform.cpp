/*
 * Transform.cpp
 *
 *  Created on: Mar 12, 2016
 *      Author: pogal
 */

#include "Transform.h"

#include <iostream>
#include <cstdlib>

using namespace std;
using namespace glm;

namespace math_util
{
	float PI = 3.141592654f;
}

Transform::Transform()
{
	localX = vec3( 1, 0, 0 );
	localY = vec3( 0, 1, 0 );
	localZ = vec3( 0, 0, 1 );
	position = vec3( 0, 0, 1 );
	scale = vec3( 1, 1, 1 );

	matrix = glm::mat4( 1.0 );
}

Transform::~Transform()
{
	
}

void Transform::reset()
{
	localX = vec3( 1, 0, 0 );
	localY = vec3( 0, 1, 0 );
	localZ = vec3( 0, 0, 1 );
	position = vec3( 0, 0, 0 );
	scale = vec3( 1, 1, 1 );

	matrix = glm::mat4( 1.0 );
}


void Transform::setPosition( const vec3 &position )
{
	this->position = vec3( position );
	matrix[3][0] = position.x;
	matrix[3][1] = position.y;
	matrix[3][2] = position.z;
	//setMatrix();
}


void Transform::setScale( const vec3 &scale )
{
	this->scale = scale;
	setMatrix();
}

void Transform::setRotation( const vec4 &rotation )
{
}

void Transform::rotateX( float angle )
{
	mat4 rotX = getRotationX( angle );
	mat4 result = matrix * rotX;
	setMatrix( result );
}

void Transform::rotateY( float angle )
{
	mat4 rotY = getRotationY( angle );
	mat4 result = matrix * rotY;
	setMatrix( result );
}

void Transform::rotateZ( float angle )
{
	mat4 rotZ = getRotationZ( angle );
	mat4 result = matrix * rotZ;
	setMatrix( result );
}

Transform Transform::extractRotation() const
{
	Transform result( *this );
	mat4 tx = Transform::getTranslate( -position );
	result.setMatrix( result.matrix * tx );

	return result;
}

void Transform::mul( const mat4 &matrix )
{
	setMatrix( matrix * this->matrix );
}

void Transform::setMatrix( const mat4 &matrix )
{
	this->matrix = mat4( matrix );

	position.x = matrix[3][0];
	position.y = matrix[3][1];
	position.z = matrix[3][2];

	vec3 Sx = vec3( matrix[0] );
	vec3 Sy = vec3( matrix[1] );
	vec3 Sz = vec3( matrix[2] );
	float sx = glm::length( Sx );
	float sy = glm::length( Sy );
	float sz = glm::length( Sz );

	scale = vec3( sx, sy, sz );
	localX = vec3( matrix[0][0] / sx, matrix[0][1] / sy, matrix[0][2] / sz );
	localY = vec3( matrix[1][0] / sx, matrix[1][1] / sy, matrix[1][2] / sz );
	localZ = vec3( matrix[2][0] / sx, matrix[2][1] / sy, matrix[2][2] / sz );
}

void Transform::setMatrix()
{
	matrix[0][0] = localX.x * scale.x;
	matrix[1][0] = localY.x * scale.y;
	matrix[2][0] = localZ.x * scale.z;
	matrix[3][0] = 0.0;
	matrix[0][1] = localX.y * scale.x;
	matrix[1][1] = localY.y * scale.y;
	matrix[2][1] = localZ.y * scale.z;
	matrix[3][1] = 0.0;
	matrix[0][2] = localX.z * scale.x;
	matrix[1][2] = localY.z * scale.y;
	matrix[2][2] = localZ.z * scale.z;
	matrix[3][2] = 0.0;
	matrix[3][0] = matrix[0][0] * position.x + matrix[1][0] * position.y + matrix[2][0] * position.z;
	matrix[3][1] = matrix[0][1] * position.x + matrix[1][1] * position.y + matrix[2][1] * position.z;
	matrix[3][2] = matrix[0][2] * position.x + matrix[1][2] * position.y + matrix[2][2] * position.z;
	matrix[3][3] = 1.0;
}

void Transform::resetScale()
{
	vec3 Sx = vec3( matrix[0] );
	vec3 Sy = vec3( matrix[1] );
	vec3 Sz = vec3( matrix[2] );
	float sx = glm::length( Sx );
	float sy = glm::length( Sy );
	float sz = glm::length( Sz );

	matrix[0] /= sx;
	matrix[1] /= sy;
	matrix[2] /= sz;
	//matrix[0][0] /= sx;
	//matrix[0][1] /= sx;
	//matrix[0][2] /= sx;
	//matrix[1][0] /= sy;
	//matrix[1][1] /= sy;
	//matrix[1][2] /= sy;
	//matrix[2][0] /= sz;
	//matrix[2][1] /= sz;
	//matrix[2][2] /= sz;

	scale = vec3( 1.0, 1.0, 1.0 );
}


void Transform::print() const
{
	const mat4 &m = matrix;
	printf( "[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n\n",
		m[0][0], m[1][0], m[2][0], m[3][0], m[0][1], m[1][1], m[2][1], m[3][1], m[0][2], m[1][2], m[2][2], m[3][2], m[0][3], m[1][3], m[2][3], m[3][3] );
	cout.flush();
}

void Transform::print( const mat4 &m )
{
	printf( "[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n[%.3f %.3f %.3f %.3f]\n\n",
		m[0][0], m[1][0], m[2][0], m[3][0], m[0][1], m[1][1], m[2][1], m[3][1], m[0][2], m[1][2], m[2][2], m[3][2], m[0][3], m[1][3], m[2][3], m[3][3] );
	cout.flush();
}

void Transform::print( const vec3 &v )
{
	printf( "<%.3f, %.3f, %.3f>\n", v.x, v.y, v.z );
	cout.flush();
}

void Transform::print( const vec4 &v )
{
	printf( "<%.3f, %.3f, %.3f, %.3f>\n", v.x, v.y, v.z, v.w );
	cout.flush();
}

void Transform::print( const std::string &label, const vec4 &v )
{
	printf( "%s<%.3f, %.3f, %.3f, %.3f>\n", label.c_str(), v.x, v.y, v.z, v.w );
	cout.flush();
}

void Transform::printOrientation() const
{
	printf( "X<%.3f %.3f %.3f>\nY<%.3f %.3f %.3f>\nZ<%.3f %.3f %.3f>\n\n", localX.x, localX.y, localX.z, localY.x, localY.y, localY.z, localZ.x, localZ.y, localZ.z );
	cout.flush();
}


// static
mat4 Transform::getRotationX( float angle )
{
	float c = cos( angle );
	float s = sin( angle );
	mat4 m = mat4();
	m[0][0] = 1.0;
	m[0][1] = 0.0;
	m[0][2] = 0.0;
	m[0][3] = 0.0;
	m[1][0] = 0.0;
	m[1][1] = c;
	m[1][2] = s;
	m[1][3] = 0.0;
	m[2][0] = 0.0;
	m[2][1] = -s;
	m[2][2] = c;
	m[2][3] = 0.0;
	m[3][0] = 0.0;
	m[3][1] = 0.0;
	m[3][2] = 0.0;
	m[3][3] = 1.0;

	return m;
}

mat4 Transform::getRotationY( float angle )
{
	float c = cos( angle );
	float s = sin( angle );
	mat4 m = mat4();
	m[0][0] = c;
	m[0][1] = 0.0;
	m[0][2] = -s;
	m[0][3] = 0.0;
	m[1][0] = 0.0;
	m[1][1] = 1.0;
	m[1][2] = 0.0;
	m[1][3] = 0.0;
	m[2][0] = s;
	m[2][1] = 0.0;
	m[2][2] = c;
	m[2][3] = 0.0;
	m[3][0] = 0.0;
	m[3][1] = 0.0;
	m[3][2] = 0.0;
	m[3][3] = 1.0;

	return m;
}


mat4 Transform::getRotationZ( float angle )
{
	float c = cos( angle );
	float s = sin( angle );
	mat4 m = mat4();
	m[0][0] = c;
	m[0][1] = s;
	m[0][2] = 0.0;
	m[0][3] = 0.0;
	m[1][0] = -s;
	m[1][1] = c;
	m[1][2] = 0.0;
	m[1][3] = 0.0;
	m[2][0] = 0.0;
	m[2][1] = 0.0;
	m[2][2] = 0.0;
	m[2][3] = 1.0;
	m[3][0] = 0.0;
	m[3][1] = 0.0;
	m[3][2] = 0.0;
	m[3][3] = 1.0;

	return m;
}

mat4 Transform::getRotation( const vec3 &axis, float angle )
{
	float c = cos( angle );
	float s = sin( angle );
	float t = 1.0 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	mat4 m = mat4();
	m[0][0] = c + x*x*t;
	m[0][1] = x*y*t + s*z;
	m[0][2] = x*z*t - s*y;
	m[1][0] = x*y*t - s*z;
	m[1][1] = c + y*y*t;
	m[1][2] = y*z*t + s*x;
	m[2][0] = x*z*t + s*y;
	m[2][1] = y*z*t - s*x;
	m[2][2] = c + z*z*t;

	return m;
}

mat4 Transform::getTranslate( const vec3 &trans )
{
	mat4 m;
	m[3][0] = trans.x;
	m[3][1] = trans.y;
	m[3][2] = trans.z;
	return m;
}

mat4 Transform::getScale( const vec3 &scale )
{
	mat4 m;
	m[0][0] = scale.x;
	m[1][1] = scale.y;
	m[2][2] = scale.z;
	m[3][3] = 1.0f;
	return m;
}

vec4& Transform::quatNormalize( vec4 &q )
{
	float mag = sqrt( glm::dot( q, q ) );
	if( mag > 0 )
	{
		float invMag = 1.0f / mag;
		q *= invMag;
	}
	return q;
}

vec4 Transform::quatInterpolate( const vec4 &a, const vec4 &b, float factor )
{
	float cosine = glm::dot( a, b );

	vec4 B( b );
	if( cosine < 0.0f )
	{
		cosine *= -1.0f;
		B *= -1.0f;
	}

	// calc coeff
	float sclp, sclq;
	if( 1.0f - cosine > 0.0001f )
	{
		float omega, sine;
		omega = acos( cosine );
		sine = sin( omega );
		sclp = sin( (1.0f - factor) * omega ) / sine;
		sclq = sin( factor * omega ) / sine;
	}
	else
	{
		// very close, do linear interp for speed
		sclp = 1.0f - factor;
		sclq = factor;
	}

	vec4 out;
	out.x = sclp * a.x + sclq * B.x;
	out.y = sclp * a.y + sclq * B.y;
	out.z = sclp * a.z + sclq * B.z;
	out.w = sclp * a.w + sclq * B.w;

	return out;
}

mat4 Transform::getRotation( const vec4 &q )
{
	mat4 m;
	m[0][0] = 1.0f - 2.0f * (q.y * q.y + q.z * q.z);
	m[0][1] = 2.0f * (q.x * q.y + q.z * q.w);
	m[0][2] = 2.0f * (q.x * q.z - q.y * q.w);
	m[0][3] = 0.0f;

	m[1][0] = 2.0f * (q.x * q.y - q.z * q.w);
	m[1][1] = 1.0f - 2.0f * (q.x * q.x + q.z * q.z);
	m[1][2] = 2.0f * (q.y * q.z + q.x * q.w);
	m[1][3] = 0.0f;

	m[2][0] = 2.0f * (q.x * q.z + q.y * q.w);
	m[2][1] = 2.0f * (q.y * q.z - q.x * q.w);
	m[2][2] = 1.0f - 2.0f * (q.x * q.x + q.y * q.y);
	m[2][3] = 0.0f;

	m[3][0] = 0.0f;
	m[3][1] = 0.0f;
	m[3][2] = 0.0f;
	m[3][3] = 1.0f;

	return m;
}
