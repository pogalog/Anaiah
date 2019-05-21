#pragma once

#include <vector>
#include <string>
#include <glm/glm.hpp>

#include "AnimationKey.h"

class Node;
class AnimationChannel
{
public:
	AnimationChannel();
	~AnimationChannel();

	// main
	glm::mat4 computeTransform( float time );


	// accessors
	Node* getNode() { return node; }
	std::string getNodeName() { return nodeName; }
	std::vector<AnimationKey<glm::vec3>>& getPositionKeys() { return positionKeys; }
	std::vector<AnimationKey<glm::vec4>>& getRotationKeys() { return rotationKeys; }
	std::vector<AnimationKey<glm::vec3>>& getScaleKeys() { return scaleKeys; }


	// mutators
	void setNode( Node *node ) { this->node = node; }
	void setNodeName( std::string name ) { this->nodeName = name; }

private:
	std::vector<AnimationKey<glm::vec3>> positionKeys;
	std::vector<AnimationKey<glm::vec4>> rotationKeys;
	std::vector<AnimationKey<glm::vec3>> scaleKeys;

	bool hasKeys();

	// interpolation
	glm::vec3 interpolateTranslation( float time, int index0 );
	glm::vec4 interpolateRotation( float time, int index0 );
	glm::vec3 interpolateScale( float time, int index0 );
	int getTranslation( float time );
	int getRotation( float time );
	int getScale( float time );

	Node *node;
	std::string nodeName;
};