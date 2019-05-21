/*
 * Animation.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#pragma once

#include <string>
#include <vector>

#include "model/AnimationChannel.h"


enum AnimationState
{
	ANIMATE_UNIT_IDLE = 0,
	ANIMATE_UNIT_MOVE = 1,
	ANIMATE_UNIT_ATTACK = 2,
	ANIMATE_UNIT_USE_ITEM = 3,
	ANIMATE_UNIT_TAKE_DAMAGE = 4,
	
	ANIMATE_DEFAULT_STATE = 5,
	ANIMATE_ACTIVE_STATE = 6,
	ANIMATE_OTHER_STATE = 7
};

class Animation
{
public:
	Animation( AnimationState state );
	~Animation();

	// accessors
	std::string& getName() { return name; }
	float getElapsedTime() { return elapsedTime; }
	float getEndTime() { return endTime; }
	bool loops() { return loop; }
	std::vector<AnimationChannel>& getChannels() { return channels; }
	AnimationChannel* getChannel( Node *node );
	void fixTimeShift();
	AnimationState getState() { return state; }


	// mutators
	void setName( std::string name ) { this->name = name; }
	void setEndTime( float endTime ) { this->endTime = endTime; }
	void setLoops( bool loop ) { this->loop = loop; }
	void addChannel( AnimationChannel &channel ) { channels.push_back( channel ); }
	void setState( AnimationState state ) { this->state = state; }
	void advance( float dt );


private:
	std::string name;
	float elapsedTime, endTime;
	bool loop;
	AnimationState state;
	std::vector<AnimationChannel> channels;
};

