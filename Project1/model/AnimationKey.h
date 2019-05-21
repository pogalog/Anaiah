#pragma once


template<class Value>
class AnimationKey
{

public:
	AnimationKey( float time, Value value )
		:time(time), value(value)
	{

	}


	~AnimationKey()
	{

	}

	float time;
	Value value;
};