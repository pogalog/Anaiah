#pragma once

#include "audio/ALSound.h"
#include "model/Animation.h"
#include "model/Model.h"
#include "render/Shader.h"

#include <vector>
#include <boost/thread.hpp>


enum AssetType
{
	MODEL_TYPE,
	TEXTURE_TYPE,
	ANIMATION_TYPE,
	AUDIO_TYPE,
	UNIT_TYPE,
	PROP_TYPE
};


class Unit;
class Prop;
class Shader;
class AssetManager
{
public:
	AssetManager();
	~AssetManager();

	void loadUnit( const char *filename );
	void loadProp( const char *filename );
	void loadAudio( const char *filename );
	void loadTexture( const char *filename );
	void loadModel( const char *filename );
	void loadAnimation( const char *filename );
	bool migrateAssets();

	// worker thread functions
	void worker_loadUnit( const char *filename );
	void worker_loadProp( const char *filename );
	void worker_loadAudio( const char *filename );
	void worker_loadTexture( const char *filename );
	void worker_loadModel( const char *filename );
	void worker_loadAnimation( const char *filename );


	// accessors
	std::vector<ALSound*>& getAudio() { return audio; }
	std::vector<Unit*>& getUnits() { return units; }
	std::vector<Prop*>& getProps() { return props; }
	std::vector<Shader*>& getShaders() { return shaders; }

private:
	AssetType getAssetType( const char *filename );


	std::vector<ALSound*> audio, tempAudio;
	std::vector<Unit*> units, tempUnits;
	std::vector<Prop*> props, tempProps;
	std::vector<Shader*> shaders, tempShaders;
	std::vector<Model*> models;
	std::vector<Texture*> textures;
	std::vector<Animation*> animations;

	boost::try_mutex mutex;
	bool assetsPresent;
};