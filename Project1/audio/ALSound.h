#pragma once
#include "al.h"
#include <glm/glm.hpp>

struct ALSound
{
	ALSound() {}
	ALSound( ALuint sid, ALuint bid )
	{
		sourceID = sid;
		bufferID = bid;
	}

	

	void play()
	{
		alSourcePlay( sourceID );
	}
	
	void deleteBuffer()
	{
		alDeleteBuffers( 1, &bufferID );
	}

	ALuint sourceID;
	ALuint bufferID;
	glm::vec3 position;
	glm::vec3 velocity;
};



struct AudioListener
{
	glm::vec3 position;
	glm::vec3 velocity;
};