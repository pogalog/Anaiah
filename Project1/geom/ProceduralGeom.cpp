
#include "ProceduralGeom.h"
#include "math/Transform.h"


#include <vector>
#include <iostream>
#include <glm/glm.hpp>

using namespace std;
using namespace glm;

namespace geom
{

	Model createWireCircle( int numSides )
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_LINES;

		int numVertices = 2 * numSides;
		mesh.numPositions = numVertices;
		mesh.numElements = numSides * 2;

		vector<GLfloat> &position = mesh.positionBuffer;
		vector<GLuint> &elements = mesh.elementBuffer;

		for( int i = 0; i < numSides; ++i )
		{
			int k = 2 * i;
			float angle = (2.0f * math_util::PI / numSides) * i + 0.5f * math_util::PI;
			float sine = sin( angle );
			float cosine = cos( angle );

			position.push_back( cosine );
			position.push_back( 0.0f );
			position.push_back( sine );
			elements.push_back( k );

			angle = (2.0f * math_util::PI / numSides) * (i + 1) + 0.5f * math_util::PI;
			sine = sin( angle );
			cosine = cos( angle );

			position.push_back( cosine );
			position.push_back( 0.0f );
			position.push_back( sine );
			elements.push_back( k + 1 );
		}


		return model;
	}


	Model createLineHex( vector<float> &height )
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();

		int numSides = 6;
		int numVertices = 2 * numSides;
		mesh.numPositions = numVertices;
		mesh.numElements = numSides * 2;
		mesh.drawMode = GL_LINES;

		vector<GLfloat> &position = mesh.positionBuffer;
		vector<GLuint> &elements = mesh.elementBuffer;

		for( int i = 0; i < numSides; ++i )
		{
			int k = 2 * i;
			float angle = (2.0f * math_util::PI / numSides) * i + 0.5f * math_util::PI;
			float sine = -sin( angle );
			float cosine = cos( angle );

			position.push_back( cosine );
			position.push_back( height[i] );
			position.push_back( sine );
			elements.push_back( k );

			angle = (2.0f * math_util::PI / numSides) * (i + 1) + 0.5f * math_util::PI;
			sine = -sin( angle );
			cosine = cos( angle );

			position.push_back( cosine );
			position.push_back( height[(i + 1) % 6] );
			position.push_back( sine );
			elements.push_back( k + 1 );
		}

		return model;
	}


	Model createFilledHex( vector<float> &height, float tileHeight )
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_TRIANGLES;

		int numSides = 6;
		mesh.numPositions = 3 * numSides;
		mesh.numElements = 3 * numSides;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		for( int i = 0; i < numSides; ++i )
		{
			int j = (i + 1) % numSides;
			float angle = (2.0f * math_util::PI / numSides) * i + 0.5f * math_util::PI;
			float sine = -sin( angle );
			float cosine = cos( angle );

			// center
			position.push_back( 0.0f );
			position.push_back( tileHeight );
			position.push_back( 0.0f );

			// i-th side vertex
			position.push_back( cosine );
			position.push_back( height[i] );
			position.push_back( sine );
			
			// (i+1)th side
			angle = (2.0f * math_util::PI / numSides) * j + 0.5f * math_util::PI;
			sine = -sin( angle );
			cosine = cos( angle );

			position.push_back( cosine );
			position.push_back( height[j] );
			position.push_back( sine );

			elements.push_back( 3*i );
			elements.push_back( 3 * i + 1 );
			elements.push_back( 3 * i + 2 );
		}

		return model;
	}


	Model createPFArrow()
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_LINES;

		mesh.numElements = 6;
		mesh.numPositions = 6;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		position.push_back( 0.0 );
		position.push_back( 0.0 );
		position.push_back( 0.0 );

		position.push_back( -0.25 );
		position.push_back( 0.0 );
		position.push_back( -0.25 );

		position.push_back( 0.25 );
		position.push_back( 0.0 );
		position.push_back( 0.0 );

		position.push_back( 0.25 );
		position.push_back( 0.0 );
		position.push_back( 0.0 );

		position.push_back( -0.25 );
		position.push_back( 0.0 );
		position.push_back( 0.25 );

		position.push_back( 0.0 );
		position.push_back( 0.0 );
		position.push_back( 0.0 );

		for( int i = 0; i < mesh.numElements; ++i ) elements.push_back( i );

		return model;
	}


	Model createQuad( float aspectRatio, Color color )
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_TRIANGLES;

		mesh.numElements = 6;
		mesh.numPositions = 6;
		mesh.numTexcoords = 6;
		mesh.numColors = 6;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLfloat> &texcoords = mesh.uvBuffer;
		texcoords.reserve( 2 * mesh.numTexcoords );
		vector<GLfloat> &colors = mesh.colorBuffer;
		colors.reserve( 4 * mesh.numColors );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		float h = 1.0f;
		float w = aspectRatio * h;

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0 );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		for( int i = 0; i < mesh.numElements; ++i ) elements.push_back( i );

		return model;
	}


	Model createQuad( float aspectRatio, Color color, FontMapTexcoord &ft )
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_TRIANGLES;

		mesh.numElements = 6;
		mesh.numPositions = 6;
		mesh.numTexcoords = 6;
		mesh.numColors = 6;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLfloat> &texcoords = mesh.uvBuffer;
		texcoords.reserve( 2 * mesh.numTexcoords );
		vector<GLfloat> &colors = mesh.colorBuffer;
		colors.reserve( 4 * mesh.numColors );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		float h = 1.0f;
		float w = aspectRatio * h;

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0 );
		texcoords.push_back( ft.t1.x );
		texcoords.push_back( 1.0f - ft.t1.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( ft.t0.x );
		texcoords.push_back( 1.0f - ft.t0.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( ft.t1.x );
		texcoords.push_back( 1.0f - ft.t0.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( ft.t1.x );
		texcoords.push_back( 1.0f - ft.t1.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( ft.t0.x );
		texcoords.push_back( 1.0f - ft.t1.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( ft.t0.x );
		texcoords.push_back( 1.0f - ft.t0.y );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		for( int i = 0; i < mesh.numElements; ++i ) elements.push_back( i );

		return model;
	}

	Model createCube()
	{
		Model model = Model();
		model.meshes.clear();
		model.meshes.push_back( Mesh() );
		Mesh &mesh = model.getPrimaryMesh();
		mesh.drawMode = GL_TRIANGLES;

		mesh.numElements = 36;
		mesh.numPositions = 36;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		float a = 0.5f;

		// front
		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		// back
		position.push_back( a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( -a );

		// top
		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		// bottom
		position.push_back( a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( a );

		// left
		position.push_back( -a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( -a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( -a );
		position.push_back( a );
		position.push_back( a );

		// right
		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( -a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( -a );

		position.push_back( a );
		position.push_back( a );
		position.push_back( a );

		for( int i = 0; i < mesh.numElements; ++i ) elements.push_back( i );

		return model;
	}





	Model* createQuad_p( float aspectRatio, Color color )
	{
		Model *model = new Model();
		model->meshes.clear();
		model->meshes.push_back( Mesh() );
		Mesh &mesh = model->getPrimaryMesh();
		mesh.drawMode = GL_TRIANGLES;

		mesh.numElements = 6;
		mesh.numPositions = 6;
		mesh.numTexcoords = 6;
		mesh.numColors = 6;

		vector<GLfloat> &position = mesh.positionBuffer;
		position.reserve( 3 * mesh.numPositions );
		vector<GLfloat> &texcoords = mesh.uvBuffer;
		texcoords.reserve( 2 * mesh.numTexcoords );
		vector<GLfloat> &colors = mesh.colorBuffer;
		colors.reserve( 4 * mesh.numColors );
		vector<GLuint> &elements = mesh.elementBuffer;
		elements.reserve( mesh.numElements );

		float h = 1.0f;
		float w = aspectRatio * h;

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0 );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( w );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( h );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 1.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		position.push_back( 0.0f );
		position.push_back( 0.0f );
		position.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		texcoords.push_back( 0.0f );
		colors.push_back( color.r() );
		colors.push_back( color.g() );
		colors.push_back( color.b() );
		colors.push_back( color.a() );

		for( int i = 0; i < mesh.numElements; ++i ) elements.push_back( i );

		return model;
	}

} // namespace geom


