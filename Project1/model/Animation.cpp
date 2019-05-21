#include "Animation.h"

#include <vector>
#include <iostream>

using namespace std;
using namespace glm;

Animation::Animation( AnimationState state )
	:state(state)
{

}

Animation::~Animation()
{
}

AnimationChannel* Animation::getChannel( Node *node )
{
	if( node == NULL ) return NULL;
	for( vector<AnimationChannel>::iterator it = channels.begin(); it != channels.end(); ++it )
	{
		AnimationChannel &ac = *it;
		if( ac.getNode() == node )
		{
			return &ac;
		}
	}

	return NULL;
}

void Animation::fixTimeShift()
{
	for( vector<AnimationChannel>::iterator it = channels.begin(); it != channels.end(); ++it )
	{
		AnimationChannel &ac = *it;
		for( vector<AnimationKey<vec3>>::iterator trit = ac.getPositionKeys().begin(); trit != ac.getPositionKeys().end(); ++trit )
		{
			AnimationKey<vec3> &key = *trit;
			float t0 = ac.getPositionKeys().at( 0 ).time;
			key.time -= t0;
		}

		for( vector<AnimationKey<vec4>>::iterator trit = ac.getRotationKeys().begin(); trit != ac.getRotationKeys().end(); ++trit )
		{
			AnimationKey<vec4> &key = *trit;
			float t0 = ac.getRotationKeys().at( 0 ).time;
			key.time -= t0;
		}

		for( vector<AnimationKey<vec3>>::iterator trit = ac.getScaleKeys().begin(); trit != ac.getScaleKeys().end(); ++trit )
		{
			AnimationKey<vec3> &key = *trit;
			float t0 = ac.getScaleKeys().at( 0 ).time;
			key.time -= t0;
		}
	}
}


void Animation::advance( float dt )
{
	elapsedTime += dt;
	if( loop )
	{
		float over = elapsedTime - endTime;
		elapsedTime = over > 0 ? over : elapsedTime;
	}
}
