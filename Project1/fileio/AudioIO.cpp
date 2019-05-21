#include "AudioIO.h"

#include <vector>
#include <sys/types.h>
#include <sys/stat.h>
#include <sndfile.hh>
#include <boost/bind.hpp>
#include <boost/array.hpp>
#include <cstdlib>
#include <iostream>
#include <cstdio>
#include <cstring>

using namespace std;

ALSound readFile( const char * fname )
{
	const int BUFFER_LEN = 1024;
	static short bufferData[BUFFER_LEN];

	SF_INFO info;
	SNDFILE* file = sf_open( fname, SFM_READ, &info );
	std::vector<uint16_t> data;

	boost::array<int16_t, 4096> read_buf;
	size_t read_size = 0;
	while( (read_size = sf_read_short( file, read_buf.data(), read_buf.size() )) != 0 )
	{
		data.insert( data.end(), read_buf.begin(), read_buf.begin() + read_size );
	}

	ALuint source, buffer;
	alGenSources( (ALuint)1, &source );

	alSourcei( source, AL_LOOPING, AL_FALSE );
	alSourcef( source, AL_PITCH, 1 );
	alSourcef( source, AL_GAIN, 1 );
	alSource3f( source, AL_POSITION, 0, 0, 0 );
	alSource3f( source, AL_VELOCITY, 0, 0, 0 );

	alGenBuffers( 1, &buffer );
	ALuint chan = info.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
	alBufferData( buffer, chan, &data.front(), data.size() * sizeof( uint16_t ), info.samplerate );
	alSourcei( source, AL_BUFFER, buffer );

	ALSound sound = ALSound( source, buffer );

	return sound;
}