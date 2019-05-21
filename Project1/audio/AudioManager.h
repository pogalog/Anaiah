#pragma once
#include "al.h" 
#include "alc.h" 
#include <sndfile.hh>
#include <vector>

#include "ALSound.h"

class AudioManager
{
public:
	AudioManager();
	~AudioManager();

	int loadSound( const char *filename );

	AudioListener listener;

private:
	int initOpenAL();

	ALCdevice *device;
	ALCcontext *context;
	std::vector<ALSound> sounds;
};