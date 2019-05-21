#include "AnimationChannel.h"
#include "model/Node.h"

#include <iostream>

using namespace glm;
using namespace std;

AnimationChannel::AnimationChannel()
{
}

AnimationChannel::~AnimationChannel()
{

}


// main
mat4 AnimationChannel::computeTransform( float time )
{
	if( node == NULL ) return mat4( 1.0 );
	if( !hasKeys() ) return node->getTransform().matrix;

	// interpolate position
	int transIndex = getTranslation( time );
	vec3 interpTrans = interpolateTranslation( time, transIndex );
	mat4 translationMatrix = Transform::getTranslate( interpTrans );

	// interpolate rotation
	int rotIndex = getRotation( time );
	vec4 interpRot = interpolateRotation( time, rotIndex );
	mat4 rotationMatrix = Transform::getRotation( interpRot );

	// interpolate scale
	int scaleIndex = getScale( time );
	vec3 interpScale = interpolateScale( time, scaleIndex );
	mat4 scaleMatrix = Transform::getScale( interpScale );

	return translationMatrix * rotationMatrix * scaleMatrix;
}



// internal
bool AnimationChannel::hasKeys()
{
	if( positionKeys.size() > 0 ) return true;
	if( rotationKeys.size() > 0 ) return true;
	if( scaleKeys.size() > 0 ) return true;
	return false;
}


// interpolation
vec3 AnimationChannel::interpolateTranslation( float time, int index0 )
{
	int index1 = (index0 + 1) % positionKeys.size();
	AnimationKey<vec3> k0 = positionKeys.at( index0 );
	AnimationKey<vec3> k1 = positionKeys.at( index1 );
	if( k1.time < k0.time )
	{
		float effTime = time - k0.time;
		return interpolateTranslation( effTime, 0 );
	}

	float interp = (time - k0.time) / (k1.time - k0.time);
	if( interp < 0.0f && interp > 1.0f ) cout << "Interpolation out of range! (" << interp << ")" << endl;
	//assert( interp >= 0.0f && interp <= 1.0f );

	vec3 dr = k1.value - k0.value;
	return k0.value + dr * interp;
}


vec4 AnimationChannel::interpolateRotation( float time, int index0 )
{
	int index1 = (index0 + 1) % rotationKeys.size();
	AnimationKey<vec4> k0 = rotationKeys.at( index0 );
	AnimationKey<vec4> k1 = rotationKeys.at( index1 );
	if( k1.time < k0.time )
	{
		float effTime = time - k0.time;
		return interpolateRotation( effTime, 0 );
	}

	float interp = (time - k0.time) / (k1.time - k0.time);
	if( interp < 0.0f && interp > 1.0f ) cout << "Interpolation out of range! (" << interp << ")" << endl;
	//assert( interp >= 0.0f && interp <= 1.0f );

	vec4 quat = Transform::quatInterpolate( k0.value, k1.value, interp );
	return Transform::quatNormalize( quat );
}

vec3 AnimationChannel::interpolateScale( float time, int index0 )
{
	int index1 = (index0 + 1) % scaleKeys.size();
	AnimationKey<vec3> k0 = scaleKeys.at( index0 );
	AnimationKey<vec3> k1 = scaleKeys.at( index1 );
	if( k1.time < k0.time )
	{
		float effTime = time - k0.time;
		return interpolateScale( effTime, 0 );
	}

	float interp = (time - k0.time) / (k1.time - k0.time);
	if( interp < 0.0f && interp > 1.0f ) cout << "Interpolation out of range! (" << interp << ")" << endl;
	//assert( interp >= 0.0f && interp <= 1.0f );

	vec3 dr = k1.value - k0.value;
	return k0.value + dr * interp;
}

int AnimationChannel::getTranslation( float time )
{
	for( unsigned int i = 0; i < positionKeys.size(); ++i )
	{
		int j = i < positionKeys.size() - 1 ? i + 1 : 0;
		AnimationKey<vec3> &key = positionKeys.at( i );
		AnimationKey<vec3> &nex = positionKeys.at( j );
		if( time > key.time && time < nex.time )
		{
			return i;
		}
	}
	return 0;
}


int AnimationChannel::getRotation( float time )
{
	for( unsigned int i = 0; i < rotationKeys.size(); ++i )
	{
		int j = i < rotationKeys.size() - 1 ? i + 1 : i;
		AnimationKey<vec4> &key = rotationKeys.at( i );
		AnimationKey<vec4> &nex = rotationKeys.at( j );
		if( time > key.time && time < nex.time )
		{
			return i;
		}
	}
	return 0;
}

int AnimationChannel::getScale( float time )
{
	for( unsigned int i = 0; i < scaleKeys.size(); ++i )
	{
		int j = i < scaleKeys.size() - 1 ? i + 1 : i;
		AnimationKey<vec3> &key = scaleKeys.at( i );
		AnimationKey<vec3> &nex = scaleKeys.at( j );
		if( time > key.time && time < nex.time )
		{
			return i;
		}
	}
	return 0;
}
