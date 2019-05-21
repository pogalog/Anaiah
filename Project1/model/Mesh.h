/*
 * Mesh.h
 *
 *  Created on: Mar 10, 2016
 *      Author: pogal
 */

#ifndef MODEL_MESH_H_
#define MODEL_MESH_H_


#include <vector>

#include "Vertex.h"
#include "Material.h"
#include "render/Shader.h"
#include "math/Transform.h"
#include "lua/LuaScript.h"

#include <glm/glm.hpp>


class Shader;
class Mesh
{
public:
	Mesh();
	Mesh( int numVertices );
	Mesh( const Mesh &mesh );
	~Mesh();
	
	// operators
	//Mesh& operator =( const Mesh &mesh );
	//Mesh& operator =( Mesh mesh );
	//Mesh operator =( Mesh mesh ) = delete;

	GLuint buildVAO();
	
	void updatePositionData( GLfloat *v );
	void updateUVData( GLfloat *vt );
	void updateNormalData( GLfloat *vn );
	bool insertBoneWeight( int vertexID, int boneID, float weight );
	void initializeBoneArrays();

	void copyUniformValues();
	IUniform* getUniform( std::string name );
	void setIntUniform( std::string name, int data );
	void setFloatUniform( std::string name, float data );
	void setVec2Uniform( std::string name, glm::vec2 data );
	void setVec3Uniform( std::string name, glm::vec3 data );
	void setVec4Uniform( std::string name, glm::vec4 data );
	void setMat3Uniform( std::string name, glm::mat3 data );
	void setMat4Uniform( std::string name, glm::mat4 data );
	void setSampler2DUniform( std::string name, GLuint data );

	Shader* getShader() const { return shader; }
	void setShader( Shader *shader );
	
	
	std::vector<GLfloat> positionBuffer, normalBuffer, uvBuffer, boneWeights, colorBuffer;
	std::vector<GLuint> elementBuffer;
	std::vector<GLshort> boneIDs;
	
	bool visible;
	bool hasBones;
	GLuint drawMode, name, positionBufferName, normalBufferName, uvBufferName, boneIDBufferName, boneWeightBufferName, colorBufferName;
	int numPositions, numTexcoords, numNormals, numColors, numElements;
	
	Material *material;
	Transform transform;
	std::vector<IUniform*> uniforms;

private:
	Shader *shader;
	void copyUniform( IUniform *meshUniform, IUniform *shaderUniform );
	void linkUniform( IUniform *meshUniform );
	void linkUniforms();
};

#endif /* MODEL_MESH_H_ */
