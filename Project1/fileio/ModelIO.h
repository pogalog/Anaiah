/*
 * ModelIO.h
 *
 *  Created on: Mar 17, 2016
 *      Author: pogal
 */

#ifndef FILEIO_MODELIO_H_
#define FILEIO_MODELIO_H_

#include <vector>
#include <string>



class Node;
class Animation;
class ModelIO
{
public:
	
	static std::vector<Node*>* readModelFromDisk( std::string filename );
	static Animation* readAnimationFromFile( std::string filename );

private:
	ModelIO() {}
	~ModelIO() {}
};

#endif /* FILEIO_MODELIO_H_ */
