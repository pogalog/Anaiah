#include "AudioManager.h"
#include "fileio/AudioIO.h"

#include <cstdlib>
#include <iostream>

using namespace std;

AudioManager::AudioManager()
{
	
}

AudioManager::~AudioManager()
{

}

int AudioManager::loadSound( const char *filename )
{
	ALSound sound = readFile( filename );
	sounds.push_back( sound );
	return sound.sourceID;
}

int AudioManager::initOpenAL()
{
	device = alcOpenDevice( NULL );
	if( !device )
	{
		cout << "OpenAL Error. Could not open device!" << endl;
		return -1;
	}
	context = alcCreateContext( device, NULL );
	alcMakeContextCurrent( context );
	if( !context )
	{
		cout << "OpenAL Error. Could not get context!" << endl;
		return -1;
	}

	return 0;
}


static void list_audio_devices( const ALCchar *devices )
{
	const ALCchar *device = devices, *next = devices + 1;
	size_t len = 0;

	fprintf( stdout, "Devices list:\n" );
	fprintf( stdout, "----------\n" );
	while( device && *device != '\0' && next && *next != '\0' )
	{
		fprintf( stdout, "%s\n", device );
		len = strlen( device );
		device += (len + 1);
		next += (len + 2);
	}
	fprintf( stdout, "----------\n" );
}

#define TEST_ERROR(_msg)				\
	error = alGetError();				\
	if( error != AL_NO_ERROR )			\
	{									\
		fprintf( stderr, _msg "\n" );	\
		return -1;						\
	}

static inline ALenum to_al_format( short channels, short samples )
{
	bool stereo = (channels > 1);

	switch( samples )
	{
		case 16:
			if( stereo )
				return AL_FORMAT_STEREO16;
			else
				return AL_FORMAT_MONO16;
		case 8:
			if( stereo )
				return AL_FORMAT_STEREO8;
			else
				return AL_FORMAT_MONO8;
		default:
			return -1;
	}
}