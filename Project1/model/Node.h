#pragma once

#include <glm/glm.hpp>
#include <vector>
#include <string>

#include "math/Transform.h"
#include "model/Mesh.h"
#include "model/Animation.h"
#include "game/Camera.h"

class Node
{
public:
	Node();
	~Node();

	// main
	glm::mat4 getFinalTransform() const;
	void draw( const Camera &camera, const std::vector<GLfloat> &boneMatrices, bool shaderOverride = false, glm::mat4 sceneMatrix = glm::mat4( 1.0 ) );
	void traverseHierarchy( Animation *anim, float time, glm::mat4 parentTransform );
	void constrcutGLMatixArray( const std::vector<Node*> &nodes );


	// accessors
	bool isVisible() const { return visible; }
	bool isBone() const { return bone; }
	Node* getParent() const { return parent; }
	std::vector<Node*>& getChildren() { return children; }
	std::vector<Mesh>& getMeshes() { return meshes; }
	Transform& getTransform() { return transform; }
	glm::mat4 getFinalTransform() { return finalTransform; }
	glm::mat4 getOffset() const { return offset; }
	std::string& getName() { return name; }
	std::vector<GLfloat> getGLMatrix() { return glMatrices; }

	// mutators
	void setVisible( bool visible ) { this->visible = visible; }
	void setBone( bool bone ) { this->bone = bone; }
	void addMesh( const Mesh &mesh ) { meshes.push_back( mesh ); }
	void addChild( Node *child ) { children.push_back( child ); }
	void setName( const std::string name ) { this->name = name; }
	void setOffset( const glm::mat4 offset ) { this->offset = offset; }
	void setParent( Node *parent );
	


private:
	Node *parent;
	std::vector<Node*> children;
	std::vector<Mesh> meshes;
	Transform transform;
	glm::mat4 offset, finalTransform, globalInverseTransform;
	std::string name;
	std::vector<GLfloat> glMatrices;
	bool visible;
	bool bone;
};