/*
 * FileIOUtil.cpp
 *
 *  Created on: Apr 20, 2016
 *      Author: pogal
 */

#include "fileio/FileIOUtil.h"

#include <glm/gtc/type_ptr.hpp>

using namespace std;
using namespace glm;



namespace fio
{

	CharArrayToInt cati;
	CharArrayToFloat catf;

	char *buf;
	int *mark;

	int byteOrderDir = 1;
	int byteOrderOffset = 0;

	void init( char *cbuf, int *cmark )
	{
		buf = cbuf;
		mark = cmark;
	}

	bool readBool()
	{
		bool val = (bool)buf[*mark];
		++(*mark);
		return val;
	}

	void reset()
	{
		mark = 0;
		buf = NULL;
	}

	char readByte()
	{
		char val = buf[*mark];
		++(*mark);
		return val;
	}

	int readInt()
	{
		for( int i = 0; i < 4; ++i ) cati.c[i*byteOrderDir + byteOrderOffset] = buf[*mark+i];
		*mark += 4;
		return cati.i;
	}

	float readFloat()
	{
		for( int i = 0; i < 4; ++i ) catf.c[i*byteOrderDir + byteOrderOffset] = buf[*mark+i];
		*mark += 4;
		return catf.f;
	}

	string readString()
	{
		int len = readInt();
		if( !len ) return string();
		int pos = *mark;
		char *cstr = buf + pos;
		*mark += len;
		return string( cstr, len );
	}

	vec2 readVec2()
	{
		float x = readFloat();
		float y = readFloat();
		return vec2( x, y );
	}

	Vec2i readVec2i()
	{
		int x = readInt();
		int y = readInt();
		return Vec2i( x, y );
	}

	vec3 readVec3()
	{
		float x = readFloat();
		float y = readFloat();
		float z = readFloat();
		return vec3( x, y, z );
	}

	Vec3i readVec3i()
	{
		int x = readInt();
		int y = readInt();
		int z = readInt();
		return Vec3i( x, y, z );
	}

	vec4 readVec4()
	{
		return vec4( readFloat(), readFloat(), readFloat(), readFloat() );
	}

	mat4 readMat4()
	{
		float data[16];
		for( int i = 0; i < 16; ++i ) data[i] = readFloat();
		return glm::make_mat4( data );
	}

	Transform readTransform()
	{
		Transform tf = Transform();
		tf.setMatrix( readMat4() );

		return tf;
	}

	Color readColor()
	{
		float r = (float)readInt()/255.0f;
		float g = (float)readInt() / 255.0f;
		float b = (float)readInt() / 255.0f;
		float a = (float)readInt() / 255.0f;
		return Color( r, g, b, a );
	}


	Color readColor3()
	{
		float r = (float)readInt() / 255.0f;
		float g = (float)readInt() / 255.0f;
		float b = (float)readInt() / 255.0f;
		return Color( r, g, b, 1.0 );
	}

	void changeByteOrder()
	{
		byteOrderDir *= -1;
		byteOrderOffset = byteOrderDir > 0 ? 0 : 3;
	}


} /* namespace fio */
