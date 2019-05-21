#pragma once

#include "math/Range.h"

class Weapon
{
public:
	Weapon();
	Weapon( Range range );
	~Weapon();

	// accessor
	Range getRange() { return range; }


	Range range;
};