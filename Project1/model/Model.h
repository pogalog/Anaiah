#pragma once

#include <vector>
#include <list>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "Mesh.h"
#include "math/Transform.h"

class IUniform;
class Camera;
class Mat4;
class Texture;
class Model
{
public:
	Model();
	~Model();
	
	void draw( const Camera &cam, bool shaderOverride = false );
	void buildAllVAOs();

	Mesh& getPrimaryMesh() { return meshes.at( 0 ); }
	
	// Model is owner of mesh and animation.
	std::vector<Mesh> meshes;
	std::vector<Texture*> textures;
	Transform transform;
	float lineWidth;
	bool visible, billboard;

private:
};

