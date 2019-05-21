#pragma once


#include <string>
#include <glm/glm.hpp>
#include <iostream>	
#include <fstream>

#include "math/Vec2i.h"
#include "math/Vec3i.h"
#include "math/Transform.h"
#include "render/Color.h"

namespace fmfio
{
	union CharArrayToInt
	{
		int i;
		char c[4];
	};

	union CharArrayToFloat
	{
		float f;
		char c[4];
	};


	// pass in the buffer and marker for fio to use
	void init( char *buf, int *mark );
	void reset();

	// we can't know what the byte order is, but we can tell if it needs to be switched
	void changeByteOrder();

	bool readBool();
	char readByte();
	int readInt();
	float readFloat();
	std::string readString();
	glm::vec2 readVec2();
	Vec2i readVec2i();
	glm::vec3 readVec3();
	glm::vec4 readVec4();
	glm::mat4 readMat4();
	Transform readTransform();
	Vec3i readVec3i();
	Color readColor();
	Color readColor3();
}