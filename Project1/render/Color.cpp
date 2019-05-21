/*
 * Color.cpp
 *
 *  Created on: Mar 23, 2016
 *      Author: pogal
 */

#include "render/Color.h"

#include <algorithm>


using namespace std;
using namespace glm;

//OOLUA_PROXY( Color )
//OOLUA_MEM_FUNC( void, r, float )
//OOLUA_PROXY_END

Color::Color()
: dat{1, 1, 1, 1}
{
}

Color::Color( float r, float g, float b )
: dat{r, g, b, 1}
{
}

Color::Color( float r, float g, float b, float a )
: dat{r, g, b, a}
{
}

Color::Color( const Color &c )
: dat{c.dat[0], c.dat[1], c.dat[2], c.dat[3]}
{
	
}

Color::Color( const vec4 &v )
{

}

Color::~Color()
{
}


// operators
float& Color::operator() ( int i )
{
	return dat[i];
}

/**
 * Simple color addition, clamped between 0 and 1.
 * Average the alpha channels.
 */
Color Color::operator+ ( const Color& c ) const
{
	Color res = Color( std::min( dat[0]+c.dat[0], 1.0f ), std::min( dat[1]+c.dat[1], 1.0f ), std::min( dat[2]+c.dat[2], 1.0f ), 0.5f*(dat[3]+c.dat[3]) );
	return res;
}

Color Color::operator- ( const Color& c ) const
{
	Color res = Color( std::max( dat[0]-c.dat[0], 0.0f ), std::min( dat[1]-c.dat[1], 0.0f ), std::min( dat[2]-c.dat[2], 0.0f ), 0.5f*(dat[3]+c.dat[3]) );
	return res;
}

Color Color::operator* ( const Color &c ) const
{
	Color res = Color( dat[0]*c.dat[0], dat[1]*c.dat[1], dat[2]*c.dat[2], dat[3]*c.dat[3] );
	return res;
}

/**
 * Simple color addition for RGB, clamped between 0 and 1.
 * Ignore the input alpha channel.
 */
Color& Color::operator+= ( const Color &c )
{
	dat[0] = std::min( dat[0] + c.dat[0], 1.0f );
	dat[1] = std::min( dat[1] + c.dat[1], 1.0f );
	dat[2] = std::min( dat[2] + c.dat[2], 1.0f );
	return *this;
}

Color& Color::operator-= ( const Color &c )
{
	dat[0] = std::max( dat[0] - c.dat[0], 0.0f );
	dat[1] = std::max( dat[1] - c.dat[1], 0.0f );
	dat[2] = std::max( dat[2] - c.dat[2], 0.0f );
	return *this;
}

Color& Color::operator*= ( const Color &c )
{
	dat[0] *= c.dat[0];
	dat[1] *= c.dat[1];
	dat[2] *= c.dat[2];
	return *this;
}

Color& Color::operator*= ( float s )
{
	dat[0] *= s;
	dat[1] *= s;
	dat[2] *= s;
	return *this;
}
		

// accessors
float Color::r() const { return dat[0]; }
float Color::g() const { return dat[1]; }
float Color::b() const { return dat[2]; }
float Color::a() const { return dat[3]; }

// mutators
void Color::r( float r ) { dat[0] = r; }
void Color::g( float g ) { dat[1] = g; }
void Color::b( float b ) { dat[2] = b; }
void Color::a( float a ) { dat[3] = a; }
void Color::blendLocal( const Color &c )
{
	float R = sqrt( dat[0]*dat[0] + c.dat[0]*c.dat[0] );
	float G = sqrt( dat[1]*dat[1] + c.dat[1]*c.dat[1] );
	float B = sqrt( dat[2]*dat[2] + c.dat[2]*c.dat[2] );
	dat[0] = std::min( R, 1.0f );
	dat[1] = std::min( G, 1.0f );
	dat[2] = std::min( B, 1.0f );
}

Color Color::blend( const Color &c ) const
{
	float R = sqrt( dat[0]*dat[0] + c.dat[0]*c.dat[0] );
	float G = sqrt( dat[1]*dat[1] + c.dat[1]*c.dat[1] );
	float B = sqrt( dat[2]*dat[2] + c.dat[2]*c.dat[2] );
	Color res = Color( std::min( R, 1.0f ), std::min( G, 1.0f ), std::min( B, 1.0f ), 0.5f*(dat[3]+c.dat[3]) );
	return res;
}
