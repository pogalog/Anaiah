/*
 * Vertex.cpp
 *
 *  Created on: Mar 11, 2016
 *      Author: pogal
 */

#include "Vertex.h"

using namespace std;

Vertex::Vertex()
{
}

Vertex::Vertex( const Vec3 &p )
{
	attributes = vector<Vec4>();
	attributes.push_back( Vec4(p) );
}

Vertex::Vertex( const Vec3 &p, const Vec2 &t )
{
	attributes = vector<Vec4>();
	attributes.push_back( Vec4(p) );
	attributes.push_back( Vec4(t) );
}

Vertex::Vertex( const Vec3 &p, const Vec3 &n )
{
	attributes = vector<Vec4>();
	attributes.push_back( Vec4(p) );
	attributes.push_back( Vec4(n) );
}

Vertex::Vertex( const Vec3 &p, const Vec2 &t, const Vec3 &n )
{
	attributes = vector<Vec4>();
	attributes.push_back( Vec4(p) );
	attributes.push_back( Vec4(t) );
	attributes.push_back( Vec4(n) );
}

Vertex::~Vertex()
{
}

