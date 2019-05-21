#pragma once


struct Range
{
	Range() :low( 0 ), high( 0 ) {}
	Range( int low, int high ) :low( low ), high( high ) {}

	~Range() {}

	int size() { return high - low; }
	bool isRangeInclusive( int x ) { return x >= low && x <= high; }
	bool isRangeExclusive( int x ) { return x > low && x < high; }

	int low, high;

};