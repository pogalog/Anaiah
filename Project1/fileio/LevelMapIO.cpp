/*
 * LevelMapIO.cpp
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#include "LevelMapIO.h"
#include "FileIOUtil.h"
#include "game/Unit.h"
#include "math/Vec3.h"
#include "model/Node.h"


#include <glm/glm.hpp>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cmath>


namespace lmio
{
std::ifstream infile;
char *buffer;
int marker = 0;
}

using namespace std;
using namespace glm;
using namespace fio;
using namespace lmio;


LevelMap* readMapVersion1_4( char *buffer, string &filename );
LevelMap* readMapVersion1_5( char *buffer, string &filename );


LevelMap* LevelMapIO::readLevelMap( std::string &filename, lua_State *L )
{
	infile.open( filename.c_str(), ios::in | ios::binary );
	if (!infile.is_open())
	{
		// push the empty byte buffer onto the Lua stack
		lua_pushlstring( L, buffer, 0 );
		return NULL;
	}


	ifstream in( filename.c_str(), std::ifstream::binary | std::ifstream::ate );
	long fileSize = (long)in.tellg();
	buffer = new char[fileSize];
	infile.seekg( 0 );
	if( !infile.read( buffer, fileSize ) )
	{
		cout << "something done bork (LevelMapIO)" << endl;
		return NULL;
	}

	// push the byte buffer onto the Lua stack
	lua_pushlstring( L, buffer + 2, fileSize - 2 );

	// init the fileio
	fio::init( buffer, &marker );

	// read header
	int majorVersion = (int)readByte();
	int minorVersion = (int)readByte();
	cout << "file version " << majorVersion << "." << minorVersion << endl;

	switch( minorVersion )
	{
		case 4:
		{
			return readMapVersion1_4( buffer, filename );
		}
		case 5:
		{
			return readMapVersion1_5( buffer, filename );
		}
	}

	return NULL;
}

LevelMap* readMapVersion1_5( char *buffer, string &filename )
{
	LevelMap *map = new LevelMap();

	string mapName = readString();
	mapName = filename.substr( 0, filename.find( '.' ) );
	map->name = mapName;

	// main Lua script
	string mainScriptFilename = readString();
	map->lua_MainName = mainScriptFilename;

	// other Lua scripts
	int len = readInt();
	for( int i = 0; i < len; ++i )
	{
		string scriptFilename = readString();
		//cout << "lua main: " << scriptFilename << endl;
		// read these in too
	}

	// GRID
	// dimension
	Vec2i dim = readVec2i();
	map->grid = MapGrid( dim );
	MapGrid &grid = map->grid;

	// UNITS
	int numUnits = readInt();
	for( int i = 0; i < numUnits; ++i )
	{
		string fn = readString();
		// read unit file
	}

	// TEAMS
	int numTeams = readInt();
	for( int i = 0; i < numTeams; ++i )
	{
		// name
		string teamName = readString();

		// load from disk

		// starting tiles
		int numTiles = readInt();
		for( int j = 0; j < numTiles; ++j )
		{
			// create tile, and add starting tile to team
			Vec2i addy = readVec2i();
		}

		// required units
		int minUnits = readInt();
		int maxUnits = readInt();
		int numReqd = readInt();
		for( int j = 0; j < numReqd; ++j )
		{
			// read unit ID, rather than name
			int unitID = readInt();
		}

		// unit instancing
		int numInst = readInt();
		for( int j = 0; j < numInst; ++j )
		{
			int origID = readInt();
			int instID = readInt();
			//			CharacterUnit original = GlobalAssetManager.GetUnitByID( origID );
			//			if( original != null )
			//			{
			//				CharacterUnit instance = original.addInstance( team );
			//				GlobalAssetManager.Unit_List.add( instance );
			//				instance.setUnitID( instID );
			//			}
		}
		// static positions
		int numStatic = readInt();
		for( int j = 0; j < numStatic; ++j )
		{
			// read unit ID
			int unitID = readInt();
		}

		// conditions
		string successDesc = readString();
		bool ssExists = readBool();

		if( ssExists )
		{
			string ssfn = readString();
			string ssfunc = readString();
		}

		// failure
		string failDesc = readString();
		bool fsExists = readBool();
		if( fsExists )
		{
			string fsfn = readString();
			string fsfunc = readString();
		}

		// ai controlled?
		int aiEnum = readInt();

		// team strategy
		int goal = readInt();
		int cluster = readInt();
		int violence = readInt();
		int healing = readInt();
		int protect = readInt();
		int buff = readInt();
		int debuff = readInt();
		int explore = readInt();

		// map.addTeam( team );
	}

	// unit strategy
	int nu = readInt();
	for( int i = 0; i < nu; ++i )
	{
		int id = readInt();
		int synergy = readInt();
		int violence = readInt();

		if( readBool() )
		{
			string msfn = readString();
			bool haveCAFunc = readBool();
			if( haveCAFunc ) readString();
			bool haveSAFunc = readBool();
			if( haveSAFunc ) readString();

		}
	}

	// TILES
	for( int i = 0; i < dim.y; ++i )
	{
		for( int j = 0; j < dim.x; ++j )
		{
			MapTile *tile = grid.getTileAtAddress( j, i );
			tile->name = readString();
			tile->description = readString();
			tile->height = readFloat();
			tile->visible = readBool();
			tile->exists = readBool();
			bool hasUnit = readBool();
			if( hasUnit )
			{
				int unitID = readInt();
				// fetch the unit from someplace amazing
				Unit *unit = NULL;
				if( unit )
				{
					if( unit->staticPosition )
					{
						unit->setLocation( tile );
						tile->occupant = unit;
						//						map->units.push_back( unit );
					}
				}
				else
				{
					// error
				}
			}
			tile->lockToTerrain = readBool();
			tile->wall = readBool();
			tile->mapFlowIndex = readInt();
			tile->defenseMod = readInt();
			tile->attackMod = readInt();
			tile->movePenalty = readInt();
			tile->fireMod = readInt();
			tile->iceMod = readInt();
			tile->lightningMod = readInt();
			tile->visMod = readFloat();
			tile->ambOverride = readFloat();
		}
	}

	grid.buildMesh();
	map->ambientBrightness = readFloat();

	//// PORTS
	//int numMapPorts = readInt();
	//for( int i = 0; i < numMapPorts; ++i )
	//{
	//	// islands
	//	int numIslands = readInt();
	//	for( int j = 0; j < numIslands; ++j )
	//	{
	//		int numTiles = readInt();
	//		for( int k = 0; k < numTiles; ++k )
	//		{
	//			Vec2i address = readVec2i();
	//		}

	//		// connections
	//		int numConnections = readInt();
	//		for( int k = 0; k < numConnections; ++k )
	//		{
	//			bool local = readBool();
	//			if( !local ) readString();
	//			int rotation = readInt();
	//			bool embed = readBool();
	//			if( embed ) readVec2i();

	//			// remote tiles
	//			int numRemoteTiles = readInt();
	//			for( int h = 0; h < numRemoteTiles; ++h )
	//			{
	//				Vec2i address = readVec2i();
	//			}
	//		}
	//	}
	//}

	//// HINTS
	//int numHints = readInt();
	//for( int i = 0; i < numHints; ++i )
	//{
	//	int type = readInt();
	//	switch( type )
	//	{
	//		case 0:
	//		{
	//			int unitID = readInt();
	//			break;
	//		}
	//		case 1:
	//		{
	//			Vec2i address = readVec2i();
	//			break;
	//		}
	//	}
	//	string hintName = readString();
	//	int maxActivation = readInt();
	//	float priorityRating = readFloat();

	//	// excluded teams
	//	int numExTeams = readInt();
	//	for( int j = 0; j < numExTeams; ++j )
	//	{
	//		string teamName = readString();

	//	}

	//	// excluded units
	//	int numExUnits = readInt();
	//	for( int j = 0; j < numExUnits; ++j )
	//	{
	//		int unitID = readInt();
	//	}

	//	// activation tiles
	//	int numActTiles = readInt();
	//	if( numActTiles > 0 )
	//	{
	//		bool relative = readBool();
	//		if( relative )
	//		{
	//			for( int j = 0; j < numActTiles; ++j )
	//			{
	//				Vec2i addy = readVec2i();

	//			}
	//			int targetID = readInt();

	//		}
	//		else
	//		{
	//			for( int j = 0; j < numActTiles; ++j )
	//			{
	//				Vec2i addy = readVec2i();

	//			}
	//		}
	//	}

	//	// activation script/func
	//	bool hasScript = readBool();
	//	if( hasScript )
	//	{
	//		string asfn = readString();
	//		string asfunc = readString();
	//	}

	//}

	//// LIGHTS
	//int numLights = readInt();
	//for( int i = 0; i < numLights; ++i )
	//{
	//	Color color = readColor();
	//	int lightType = readInt();
	//	vec3 position = readVec3();
	//	vec3 direction = readVec3();
	//	float intensity = readFloat();
	//	bool attenuate = readBool();
	//	float constTerm = readFloat();
	//	float linearTerm = readFloat();
	//	float quadraticTerm = readFloat();
	//	bool useSpotLight = readBool();
	//	float innerAngle = readFloat();
	//	float outerAngle = readFloat();
	//}

	//// MODELS
	//int numModels = readInt();
	//vector<Node*> models = vector<Node*>();
	//for( int i = 0; i < numModels; ++i )
	//{
	//	string filename = readString();
	//	// read the model
	//}

	//// ANIMATIONS
	//int numAnimations = readInt();
	//for( int i = 0; i < numAnimations; ++i )
	//{
	//	string filename = readString();

	//}

	//// PROPS
	//int numProps = readInt();
	//for( int i = 0; i < numProps; ++i )
	//{
	//	int modelIndex = readInt();
	//	Transform transform = readTransform();
	//	Node *model = models.at( modelIndex );
	//	vector<Mesh> &meshes = model->getMeshes();

	//	for( vector<Mesh>::iterator it = meshes.begin(); it != meshes.end(); ++it )
	//	{
	//		Mesh &mesh = *it;
	//		bool hasShader = readBool();
	//		if( hasShader )
	//		{
	//			string shaderFile = readString();

	//		}

	//		Material *mat = mesh.material;
	//		mat->name = readString();
	//		bool hasCM = readBool();
	//		if( hasCM )
	//		{
	//			string cmfn = readString();
	//			// read color map
	//		}
	//		bool hasSM = readBool();
	//		if( hasSM )
	//		{
	//			string smfn = readString();
	//			// read specular map
	//		}

	//		mat->ambientColor = readColor3();
	//		mat->diffuseColor = readColor3();
	//		mat->specularColor = readColor3();
	//		mat->specularCoeff = readFloat();
	//		mat->alpha = readFloat();
	//	}

	//	// Animations for Props
	//	bool hasDefault = readBool();
	//	if( hasDefault )
	//	{
	//		int defaultIndex = readInt();
	//		if( defaultIndex < 0 )
	//		{
	//			readBool();
	//		}
	//		else
	//		{
	//			bool loops = readBool();
	//		}
	//	}
	//	bool hasActivated = readBool();
	//	if( hasActivated )
	//	{
	//		int activatedIndex = readInt();
	//		if( activatedIndex < 0 )
	//		{
	//			readBool();
	//		}
	//		else
	//		{
	//			bool loops = readBool();
	//		}
	//	}

	//	int numOther = readInt();
	//	for( int j = 0; j < numOther; ++j )
	//	{
	//		int index = readInt();
	//		if( index < 0 )
	//		{
	//			readBool();
	//		}
	//		else
	//		{
	//			bool loops = readBool();
	//		}
	//	}
	//}

	//// PARTICLE SYSTEMS
	//int numParticleSystems = readInt();
	//for( int i = 0; i < numParticleSystems; ++i )
	//{
	//	int type = readInt();
	//	Transform transform = readTransform();

	//	float lifetime = readFloat();
	//	if( type == 0 ) // Emitter
	//	{
	//		int maxParticles = readInt();
	//		int maxActive = readInt();

	//		int numMaterials = readInt();
	//		for( int j = 0; j < numMaterials; ++j )
	//		{
	//			// make a ParticleMaterial
	//			float probability = readFloat();
	//			Color avgColor = readColor();
	//			vec4 colorVar = readVec4();
	//			string colorMapFilename = readString();

	//		}

	//		// ports
	//		int numPorts = readInt();
	//		for( int j = 0; j < numPorts; ++j )
	//		{
	//			Transform portTransform = readTransform();
	//			vec3 emissionDirection = readVec3();
	//			float decayTime = readFloat();
	//			float decayTimeVar = readFloat();
	//			int emissionSize = readInt();
	//			int emissionSizeVar = readInt();
	//			float emissionSpeed = readFloat();
	//			float emissionSpeedVar = readFloat();
	//			float emissionAngle = readFloat();
	//			float emissionAngleVar = readFloat();
	//			float emissionFrequency = readFloat();
	//			float emissionFrequencyVar = readFloat();
	//			float emissionPhase = readFloat();
	//			bool useEField = readBool();
	//			bool useBField = readBool();
	//			bool usePointSource = readBool();
	//			vec3 Efield = readVec3();
	//			vec3 Bfield = readVec3();
	//			vec3 pointSourcePosition = readVec3();
	//			float centralForceConst = readFloat();
	//			vec3 uniformAcceleration = readVec3();
	//			float viscousDamping = readFloat();
	//			int blendSourceOption = readInt();
	//			int blendDestOption = readInt();
	//			bool depthMask = readBool();

	//			// instances
	//			int numInstances = readInt();
	//			for( int k = 0; k < numInstances; ++k )
	//			{
	//				Transform instTransform = readTransform();
	//			}
	//		}
	//	}
	//	else // particle fields
	//	{

	//		int numParticles = readInt();
	//		vec3 floatDir = readVec3();
	//		float flowSpeed = readFloat();
	//		float lifetime = readFloat();
	//		vec3 fieldSize = readVec3();
	//		int blendSource = readInt();
	//		int blendDest = readInt();
	//		bool depthMask = readBool();

	//		// materials
	//		int numMaterials = readInt();
	//		for( int j = 0; j < numMaterials; ++j )
	//		{
	//			float probability = readFloat();
	//			Color avgColor = readColor();
	//			vec4 colorVar = readVec4();
	//			string colorMapFilename = readString();
	//		}

	//		// instances
	//		int numInstances = readInt();
	//		for( int j = 0; j < numInstances; ++j )
	//		{
	//			Transform instTransform = readTransform();
	//		}
	//	}
	//}

	return map;
}



LevelMap* readMapVersion1_4( char *buffer, string &filename )
{
	LevelMap *map = new LevelMap();
	
	string mapName = readString();
	mapName = filename.substr( 0, filename.find( '.' ) );
	map->name = mapName;
	
	// main Lua script
	string mainScriptFilename = readString();
	map->lua_MainName = mainScriptFilename;
	
	// other Lua scripts
	int len = readInt();
	for( int i = 0; i < len; ++i )
	{
		string scriptFilename = readString();
		//cout << "lua main: " << scriptFilename << endl;
		// read these in too
	}
		
	// GRID
	// dimension
	Vec2i dim = readVec2i();
	map->grid = MapGrid( dim );
	MapGrid &grid = map->grid;
	
	// UNITS
	int numUnits = readInt();
	for( int i = 0; i < numUnits; ++i )
	{
		string fn = readString();
		// read unit file
	}
	
	// TEAMS
	int numTeams = readInt();
	for( int i = 0; i < numTeams; ++i )
	{
		// name
		string teamName = readString();
		
		// load from disk
		
		// starting tiles
		int numTiles = readInt();
		for( int j = 0; j < numTiles; ++j )
		{
			// create tile, and add starting tile to team
			Vec2i addy = readVec2i();
		}
		
		// required units
		int minUnits = readInt();
		int maxUnits = readInt();
		int numReqd = readInt();
		for( int j = 0; j < numReqd; ++j )
		{
			// read unit ID, rather than name
			int unitID = readInt();
		}
		
		// unit instancing
		int numInst = readInt();
		for( int j = 0; j < numInst; ++j )
		{
			int origID = readInt();
			int instID = readInt();
//			CharacterUnit original = GlobalAssetManager.GetUnitByID( origID );
//			if( original != null )
//			{
//				CharacterUnit instance = original.addInstance( team );
//				GlobalAssetManager.Unit_List.add( instance );
//				instance.setUnitID( instID );
//			}
		}
		// static positions
		int numStatic = readInt();
		for( int j = 0; j < numStatic; ++j )
		{
			// read unit ID
			int unitID = readInt();
		}
		
		// conditions
		string successDesc = readString();
		bool ssExists = readBool();
		
		if( ssExists )
		{
			string ssfn = readString();
			string ssfunc = readString();
		}
		
		// failure
		string failDesc = readString();
		bool fsExists = readBool();
		if( fsExists )
		{
			string fsfn = readString();
			string fsfunc = readString();
		}
		
		// ai controlled?
		int aiEnum = readInt();
		
		// team strategy
		int goal = readInt();
		int cluster = readInt();
		int violence = readInt();
		int healing = readInt();
		int protect = readInt();
		int buff = readInt();
		int debuff = readInt();
		int explore = readInt();
		
		// map.addTeam( team );
	}
	
	// unit strategy
	int nu = readInt();
	for( int i = 0; i < nu; ++i )
	{
		int id = readInt();
		int synergy = readInt();
		int violence = readInt();
		
		if( readBool() )
		{
			string msfn = readString();
			bool haveCAFunc = readBool();
			if( haveCAFunc ) readString();
			bool haveSAFunc = readBool();
			if( haveSAFunc ) readString();
			
		}
	}
	
	// TILES
	for( int i = 0; i < dim.y; ++i )
	{
		for( int j = 0; j < dim.x; ++j )
		{
			MapTile *tile = grid.getTileAtAddress( j, i );
			tile->name = readString();
			tile->description = readString();
			tile->height = readFloat();
			tile->visible = readBool();
			tile->exists = readBool();
			bool hasUnit = readBool();
			if( hasUnit )
			{
				int unitID = readInt();
				// fetch the unit from someplace amazing
				Unit *unit = NULL;
				if( unit )
				{
					if( unit->staticPosition )
					{
						unit->setLocation( tile );
						tile->occupant = unit;
//						map->units.push_back( unit );
					}
				}
				else
				{
					// error
				}
			}
			tile->lockToTerrain = readBool();
			tile->wall = readBool();
			tile->mapFlowIndex = readInt();
			tile->defenseMod = readInt();
			tile->attackMod = readInt();
			tile->movePenalty = readInt();
			tile->fireMod = readInt();
			tile->iceMod = readInt();
			tile->lightningMod = readInt();
			tile->visMod = readFloat();
			tile->ambOverride = readFloat();
		}
	}
	
	grid.buildMesh();
	
	map->ambientBrightness = readFloat();

	// HINTS
	int numHints = readInt();
	for( int i = 0; i < numHints; ++i )
	{
		int type = readInt();
		switch( type )
		{
			case 0:
			{
				int unitID = readInt();
				break;
			}
			case 1:
			{
				Vec2i address = readVec2i();
				break;
			}
		}
		string hintName = readString();
		int maxActivation = readInt();
		float priorityRating = readFloat();

		// excluded teams
		int numExTeams = readInt();
		for( int j = 0; j < numExTeams; ++j )
		{
			string teamName = readString();

		}

		// excluded units
		int numExUnits = readInt();
		for( int j = 0; j < numExUnits; ++j )
		{
			int unitID = readInt();
		}

		// activation tiles
		int numActTiles = readInt();
		if( numActTiles > 0 )
		{
			bool relative = readBool();
			if( relative )
			{
				for( int j = 0; j < numActTiles; ++j )
				{
					Vec2i addy = readVec2i();

				}
				int targetID = readInt();

			}
			else
			{
				for( int j = 0; j < numActTiles; ++j )
				{
					Vec2i addy = readVec2i();

				}
			}
		}

		// activation script/func
		bool hasScript = readBool();
		if( hasScript )
		{
			string asfn = readString();
			string asfunc = readString();
		}

	}

	// LIGHTS
	int numLights = readInt();
	for( int i = 0; i < numLights; ++i )
	{
		Color color = readColor();
		int lightType = readInt();
		vec3 position = readVec3();
		vec3 direction = readVec3();
		float intensity = readFloat();
		bool attenuate = readBool();
		float constTerm = readFloat();
		float linearTerm = readFloat();
		float quadraticTerm = readFloat();
		bool useSpotLight = readBool();
		float innerAngle = readFloat();
		float outerAngle = readFloat();
	}

	// MODELS
	int numModels = readInt();
	vector<Node*> models = vector<Node*>();
	for( int i = 0; i < numModels; ++i )
	{
		string filename = readString();
		// read the model
	}

	// ANIMATIONS
	int numAnimations = readInt();
	for( int i = 0; i < numAnimations; ++i )
	{
		string filename = readString();

	}

	// PROPS
	int numProps = readInt();
	for( int i = 0; i < numProps; ++i )
	{
		int modelIndex = readInt();
		Transform transform = readTransform();
		Node *model = models.at( modelIndex );
		vector<Mesh> &meshes = model->getMeshes();

		for( vector<Mesh>::iterator it = meshes.begin(); it != meshes.end(); ++it )
		{
			Mesh &mesh = *it;
			bool hasShader = readBool();
			if( hasShader )
			{
				string shaderFile = readString();

			}

			Material *mat = mesh.material;
			mat->name = readString();
			bool hasCM = readBool();
			if( hasCM )
			{
				string cmfn = readString();
				// read color map
			}
			bool hasSM = readBool();
			if( hasSM )
			{
				string smfn = readString();
				// read specular map
			}

			mat->ambientColor = readColor3();
			mat->diffuseColor = readColor3();
			mat->specularColor = readColor3();
			mat->specularCoeff = readFloat();
			mat->alpha = readFloat();
		}

		// Animations for Props
		bool hasDefault = readBool();
		if( hasDefault )
		{
			int defaultIndex = readInt();
			if( defaultIndex < 0 )
			{
				readBool();
			}
			else
			{
				bool loops = readBool();
			}
		}
		bool hasActivated = readBool();
		if( hasActivated )
		{
			int activatedIndex = readInt();
			if( activatedIndex < 0 )
			{
				readBool();
			}
			else
			{
				bool loops = readBool();
			}
		}

		int numOther = readInt();
		for( int j = 0; j < numOther; ++j )
		{
			int index = readInt();
			if( index < 0 )
			{
				readBool();
			}
			else
			{
				bool loops = readBool();
			}
		}
	}

	// PARTICLE SYSTEMS
	int numParticleSystems = readInt();
	for( int i = 0; i < numParticleSystems; ++i )
	{
		int type = readInt();
		Transform transform = readTransform();

		float lifetime = readFloat();
		if( type == 0 ) // Emitter
		{
			int maxParticles = readInt();
			int maxActive = readInt();

			int numMaterials = readInt();
			for( int j = 0; j < numMaterials; ++j )
			{
				// make a ParticleMaterial
				float probability = readFloat();
				Color avgColor = readColor();
				vec4 colorVar = readVec4();
				string colorMapFilename = readString();

			}

			// ports
			int numPorts = readInt();
			for( int j = 0; j < numPorts; ++j )
			{
				Transform portTransform = readTransform();
				vec3 emissionDirection = readVec3();
				float decayTime = readFloat();
				float decayTimeVar = readFloat();
				int emissionSize = readInt();
				int emissionSizeVar = readInt();
				float emissionSpeed = readFloat();
				float emissionSpeedVar = readFloat();
				float emissionAngle = readFloat();
				float emissionAngleVar = readFloat();
				float emissionFrequency = readFloat();
				float emissionFrequencyVar = readFloat();
				float emissionPhase = readFloat();
				bool useEField = readBool();
				bool useBField = readBool();
				bool usePointSource = readBool();
				vec3 Efield = readVec3();
				vec3 Bfield = readVec3();
				vec3 pointSourcePosition = readVec3();
				float centralForceConst = readFloat();
				vec3 uniformAcceleration = readVec3();
				float viscousDamping = readFloat();
				int blendSourceOption = readInt();
				int blendDestOption = readInt();
				bool depthMask = readBool();

				// instances
				int numInstances = readInt();
				for( int k = 0; k < numInstances; ++k )
				{
					Transform instTransform = readTransform();
				}
			}
		}
		else // particle fields
		{
			
			int numParticles = readInt();
			vec3 floatDir = readVec3();
			float flowSpeed = readFloat();
			float lifetime = readFloat();
			vec3 fieldSize = readVec3();
			int blendSource = readInt();
			int blendDest = readInt();
			bool depthMask = readBool();

			// materials
			int numMaterials = readInt();
			for( int j = 0; j < numMaterials; ++j )
			{
				float probability = readFloat();
				Color avgColor = readColor();
				vec4 colorVar = readVec4();
				string colorMapFilename = readString();
			}
			
			// instances
			int numInstances = readInt();
			for( int j = 0; j < numInstances; ++j )
			{
				Transform instTransform = readTransform();
			}
		}
	}

	return map;
}

