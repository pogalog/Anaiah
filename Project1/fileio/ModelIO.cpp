/*
* ModelIO.cpp
*
*  Created on: Mar 17, 2016
*      Author: pogal
*/

#include "ModelIO.h"
#include "FileIOUtil.h"
#include "math/Vec3i.h"
#include "render/Color.h"
#include "model/Material.h"
#include "model/Mesh.h"
#include "model/Node.h"
#include "model/Bone.h"
#include "model/Animation.h"

#include <glm/glm.hpp>
#include <cstdio>
#include <cstdlib>
#include <cmath>


namespace mio
{
	std::ifstream infile;
	char *buffer;
	int marker = 0;
}

using namespace std;
using namespace glm;
using namespace fio;
using namespace mio;

// prototypes
vector<Node*>* readModelVersion1_1();

Animation* readAnimationVersion1_0();


vector<Node*>* ModelIO::readModelFromDisk( string filename )
{
	infile = ifstream();
	infile.open( filename.c_str(), ios::in | ios::binary );
	if( !infile.is_open() )
	{
		cout << "File not found: " << filename.c_str() << endl;
		return NULL;
	}


	ifstream in( filename.c_str(), std::ifstream::binary | std::ifstream::ate );
	unsigned long fileSize = (unsigned long)in.tellg();
	buffer = new char[fileSize];
	infile.seekg( 0 );
	if( !infile.read( buffer, fileSize ) )
	{
		cout << "Unable to open file: " << filename << endl;
		return NULL;
	}

	// init the fileio
	fio::init( buffer, &marker );

	// read header
	int majorVersion = (int)readByte();
	int minorVersion = (int)readByte();
	cout << "Model version " << majorVersion << "." << minorVersion << endl;

	vector<Node*> *nodes = NULL;
	switch( minorVersion )
	{
		case 1:
		{
			nodes = readModelVersion1_1();
			break;
		}
		default:
		{
			nodes = NULL;
			break;
		}
	}

	infile.close();
	delete buffer;
	buffer = NULL;
	marker = 0;

	return nodes;
}



vector<Node*>* readModelVersion1_1()
{
	vector<Node*>* nodes = new vector<Node*>();

	// byte order identification
	int boid = readInt();
	if( boid != 13 )
	{
		fio::changeByteOrder();
	}

	mat4 globalInverseTransform = readMat4();
	mat4 sceneTransform = Transform::getRotationX( -0.5f * math_util::PI );

	// materials
	vector<Material> materials = vector<Material>();
	int numMat = readInt();
	for( int i = 0; i < numMat; ++i )
	{
		Material temp = Material();
		materials.push_back( temp );
		Material &mat = materials.back();

		bool hasTexture = readBool();
		if( hasTexture )
		{
			bool hasDiffuse = readBool();
			if( hasDiffuse )
			{
				string path = readString();
				mat.diffuseTexture = path;
				mat.loadMap( MapType::MAP_TYPE_DIFFUSE );
			}
			bool hasAmbient = readBool();
			if( hasAmbient )
			{
				string path = readString();
				mat.ambientTexture = path;
				mat.loadMap( MapType::MAP_TYPE_AMBIENT );
			}
		}
	}

	// nodes
	int numNodes = readInt();
	for( int i = 0; i < numNodes; ++i )
	{
		Node* node = new Node();
		nodes->push_back( node );
		node->setName( readString() );
		int parentIndex = readInt();
		bool isScene = parentIndex < 0;
		Node* parent = isScene ? NULL : nodes->at( parentIndex );
		if( isScene )
		{
			node->getTransform().setMatrix( node->getTransform().matrix );
		}
		node->setParent( parent );
		
		int numChildren = readInt();
		mat4 nodeTransform = readMat4();
		node->getTransform().setMatrix( nodeTransform );

		// meshes
		int numMeshes = readInt();
		for( int j = 0; j < numMeshes; ++j )
		{
			string meshName = readString();
			int materialIndex = readInt();
			// possible problem here, with copying the Material
			Material &mat = materials.at( materialIndex );

			int numVertices = readInt();
			Mesh temp( numVertices );
			node->addMesh( temp );
			Mesh &mesh = node->getMeshes().back();
			Material *m = new Material( mat );
			mesh.material = m;
			mesh.transform.setMatrix( mesh.transform.matrix );

			for( int k = 0; k < numVertices; ++k )
			{
				vec3 v = readVec3();
				vec2 vt = readVec2();
				vec3 vn = readVec3();

				mesh.positionBuffer.push_back( v.x );
				mesh.positionBuffer.push_back( v.y );
				mesh.positionBuffer.push_back( v.z );

				mesh.uvBuffer.push_back( vt.x );
				mesh.uvBuffer.push_back( vt.y );

				mesh.normalBuffer.push_back( vn.x );
				mesh.normalBuffer.push_back( vn.y );
				mesh.normalBuffer.push_back( vn.z );
			}

			// faces
			int numFaces = readInt();
			for( int k = 0; k < numFaces; ++k )
			{
				Vec3i face = readVec3i();
				mesh.elementBuffer.push_back( face.x() );
				mesh.elementBuffer.push_back( face.y() );
				mesh.elementBuffer.push_back( face.z() );
			}

			// skeleton
			bool hasBones = readBool();
			if( hasBones )
			{
				mesh.hasBones = true;
				mesh.initializeBoneArrays();

				int numBones = readInt();
				for( int k = 0; k < numBones; ++k )
				{
					string boneName = readString();
					int nodeIndex = readInt();
					Node *bone = nodes->at( nodeIndex );
					bone->setName( boneName );
					bone->setOffset( readMat4() );

					// weights
					int numWeights = readInt();
					for( int m = 0; m < numWeights; ++m )
					{
						int vertexID = readInt();
						float weight = readFloat();
						mesh.insertBoneWeight( vertexID, nodeIndex, weight );
					}
				}
			}

			mesh.buildVAO();
		}
	}


	fio::reset();

	return nodes;
}






Animation* ModelIO::readAnimationFromFile( string filename )
{
	infile.open( filename.c_str(), ios::in | ios::binary );
	if( !infile.is_open() )
	{
		cout << "File not found: " << filename.c_str() << endl;
		return NULL;
	}


	ifstream in( filename.c_str(), std::ifstream::binary | std::ifstream::ate );
	unsigned long fileSize = (unsigned long)in.tellg();
	buffer = new char[fileSize];
	infile.seekg( 0 );
	if( !infile.read( buffer, fileSize ) )
	{
		cout << "something done bork't hard (ModelIO::Animation)" << endl;
		return NULL;
	}

	// init the fileio
	fio::init( buffer, &marker );

	// read header
	int majorVersion = (int)readByte();
	int minorVersion = (int)readByte();
	cout << "Model version " << majorVersion << "." << minorVersion << endl;

	Animation *animation = NULL;
	switch( minorVersion )
	{
		case 0:
		{
			animation = readAnimationVersion1_0();
			break;
		}
		default:
		{
			animation = NULL;
			break;
		}
	}

	infile.close();
	delete buffer;
	buffer = NULL;
	marker = 0;

	return animation;
}


Animation* readAnimationVersion1_0()
{
	Animation *animation = new Animation( ANIMATE_DEFAULT_STATE );

	int byteOrderID = readInt();
	if( byteOrderID != 13 ) fio::changeByteOrder();

	float endTime = 0.0;

	string name = readString();
	animation->setName( name );

	int numChannels = readInt();
	for( int i = 0; i < numChannels; ++i )
	{
		animation->addChannel( AnimationChannel() );
		AnimationChannel &channel = animation->getChannels().back();
		channel.setNodeName( readString() );		

		int numPositionKeys = readInt();
		for( int j = 0; j < numPositionKeys; ++j )
		{
			float time = readFloat();
			vec3 val = readVec3();
			AnimationKey<vec3> key( time, val );
			channel.getPositionKeys().push_back( key );
			if( time > endTime ) endTime = time;
		}

		int numRotationKeys = readInt();
		for( int j = 0; j < numRotationKeys; ++j )
		{
			float time = readFloat();
			vec4 val = readVec4();
			vec4 val_rev( val.w, val.z, val.y, val.x );
			AnimationKey<vec4> key( time, val_rev );
			channel.getRotationKeys().push_back( key );
			if( time > endTime ) endTime = time;
		}

		int numScaleKeys = readInt();
		for( int j = 0; j < numScaleKeys; ++j )
		{
			float time = readFloat();
			vec3 val = readVec3();
			AnimationKey<vec3> key( time, val );
			channel.getScaleKeys().push_back( key );
			if( time > endTime ) endTime = time;
		}

		animation->setEndTime( endTime );
	}

	reset();

	return animation;
}