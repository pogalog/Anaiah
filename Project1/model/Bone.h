/*
 * Bone.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#ifndef MODEL_BONE_H_
#define MODEL_BONE_H_

#include <vector>

class Bone
{
public:
	Bone();
	virtual ~Bone();
	
	std::vector<Bone*> *children;
	Bone *parent;
};

#endif /* MODEL_BONE_H_ */
