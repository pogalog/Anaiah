#pragma once


#include "model/Model.h"
#include "text/FontMap.h"

namespace geom
{

	Model createWireCircle( int numSides );
	Model createLineHex( std::vector<float> &height );
	Model createFilledHex( std::vector<float> &height, float tileHeight );
	Model createPFArrow();
	Model createQuad( float aspectRatio, Color color );
	Model createQuad( float aspectRatio, Color color, FontMapTexcoord &tc );
	Model createCube();

	Model* createQuad_p( float aspectRatio, Color color );

}