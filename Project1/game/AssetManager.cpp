#include "AssetManager.h"
#include "fileio/AudioIO.h"
#include "game/Unit.h"
#include "prop/Prop.h"
#include "render/Shader.h"

#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <string>


using namespace std;

AssetManager::AssetManager()
{

}


AssetManager::~AssetManager()
{
}

// load functions, spawn worker threads
void AssetManager::loadUnit( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadUnit, this, filename ) );
}

void AssetManager::loadProp( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadProp, this, filename ) );
}

void AssetManager::loadAudio( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadAudio, this, filename ) );
}

void AssetManager::loadAnimation( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadAnimation, this, filename ) );
}

void AssetManager::loadModel( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadModel, this, filename ) );
}

void AssetManager::loadTexture( const char *filename )
{
	boost::thread( boost::bind( &AssetManager::worker_loadTexture, this, filename ) );
}


// worker thread functions
void AssetManager::worker_loadUnit( const char *filename )
{
	// load all assets needed for the given Unit

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}

void AssetManager::worker_loadProp( const char *filename )
{
	// load all assets needed for the given Prop

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}

void AssetManager::worker_loadAudio( const char *filename )
{
	// load all assets needed for the given audio

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}

void AssetManager::worker_loadTexture( const char *filename )
{
	// load all assets needed for the given Texture

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}

void AssetManager::worker_loadModel( const char *filename )
{
	// load all assets needed for the given Model

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}

void AssetManager::worker_loadAnimation( const char *filename )
{
	// load all assets needed for the given Animation

	boost::try_mutex::scoped_lock lock( mutex );
	{
		// all done, now hand the loaded assets back to the main thread for retrieval
	}
}


// Reads assets from temporary buffers. Always called from the main
// thread, and should never block if the mutex is already locked.
bool AssetManager::migrateAssets()
{
	boost::try_mutex::scoped_lock lock( mutex );
	if( lock )
	{
		// mutex successfully locked
		return true;
	}

	// failed to lock mutex, try again later.
	return false;
}


AssetType AssetManager::getAssetType( const char *filename )
{
	string fn( filename );
	int ext_start = fn.find_last_of( "." ) + 1;
	string extension = fn.substr( ext_start );
	
	return TEXTURE_TYPE;
}
