/*
 * Transform.h
 *
 *  Created on: Mar 12, 2016
 *      Author: pogal
 */

#ifndef MATH_TRANSFORM_H_
#define MATH_TRANSFORM_H_

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <string>

namespace math_util
{
	extern float PI;
}

class Transform
{
public:
	Transform();
	~Transform();

	void reset();
	
	void setPosition( const glm::vec3 &position );
	void setScale( const glm::vec3 &scale );
	void setRotation( const glm::vec4 &rotation );

	void rotateX( float angle );
	void rotateY( float angle );
	void rotateZ( float angle );

	Transform extractRotation() const;

	void mul( const glm::mat4 &matrix );
	void setMatrix( const glm::mat4 &matrix );
	void setMatrix();
	void resetScale();

	// operators
	void print() const;
	void printOrientation() const;
	static void print( const glm::mat4 &m );
	static void print( const glm::vec3 &v );
	static void print( const glm::vec4 &v );
	static void print( const std::string &label, const glm::vec4 &v );

	// static
	static glm::mat4 getRotationX( float angle );
	static glm::mat4 getRotationY( float angle );
	static glm::mat4 getRotationZ( float angle );
	static glm::mat4 getRotation( const glm::vec3 &axis, float angle );
	static glm::mat4 getRotation( const glm::vec4 &quat );
	static glm::mat4 getTranslate( const glm::vec3 &trans );
	static glm::mat4 getScale( const glm::vec3 &trans );
	static glm::vec4& quatNormalize( glm::vec4 &q );
	static glm::vec4 quatInterpolate( const glm::vec4 &a, const glm::vec4 &b, float factor );
	
	
	glm::mat4 matrix;
	glm::vec3 localX;
	glm::vec3 localY;
	glm::vec3 localZ;
	glm::vec3 position;
	glm::vec3 scale;
};

#endif /* MATH_TRANSFORM_H_ */
