/*
 * Util.h
 *
 *  Created on: Apr 21, 2016
 *      Author: pogal
 */

#ifndef UTIL_UTIL_H_
#define UTIL_UTIL_H_

#include <vector>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <algorithm>

namespace util
{

// find if vector &v contains an element A &a
template <class A>
inline bool contains( const std::vector<A> &v, const A &a )
{
	typename std::vector<A>::iterator it;
	it = std::find( v.begin(), v.end(), a );
	return it != v.end();
}

template <class A>
inline bool containsPointer( const std::vector<A*> &v, const A *a )
{
	for( typename vector<A*>::const_iterator it = v.begin(); it != v.end(); ++it )
	{
		A* item = *it;
		if( item == a ) return true;
	}

	return false;
}

template <class A>
inline int indexOf( const std::vector<A> &v, const A &a )
{
	typename std::vector<A>::iterator it;
	it = std::find( v.begin(), v.end(), a );
	if( it != v.end() )
	{
		return it - v.begin();
	}
	return -1;
}


// remove A &a from vector &v
template <class A>
inline void operator< ( std::vector<A> &v, A &a )
{
	typename std::vector<A>::iterator it;
	it = std::find( v.begin(), v.end(), a );
	if( it != v.end() )
	{
		v.erase( it );
	}
}


} /* namespace util */

#endif /* UTIL_UTIL_H_ */
