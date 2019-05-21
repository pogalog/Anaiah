#pragma once
#include <glm/glm.hpp>

class Color
{
public:
	Color();
	Color( float r, float g, float b );
	Color( float r, float g, float b, float a );
	Color( const Color& c );
	Color( const glm::vec4 &v );
	~Color();
	
	// operators
	float& operator() ( int i );
	Color operator+ ( const Color &c ) const;
	Color operator- ( const Color &c ) const;
	Color operator* ( const Color &c ) const;
	Color operator* ( float s ) const;
	Color& operator+= ( const Color &c );
	Color& operator-= ( const Color &c );
	Color& operator*= ( const Color &c );
	Color& operator*= ( float s );
	
	// accessors
	float r() const;
	float g() const;
	float b() const;
	float a() const;
	
	// mutators
	void r( float r );
	void g( float g );
	void b( float b );
	void a( float a );
	void blendLocal( const Color &c );
	
	Color blend( const Color &c ) const;
	
	
	float dat[4];
};

