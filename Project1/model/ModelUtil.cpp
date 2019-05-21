#include "ModelUtil.h"

#include <iostream>
#include <math.h>

namespace model_util
{

	using namespace std;
	using namespace glm;


	// General Model Utilities
	void groupMeshes( vector<Model*> &models, Mesh &outMesh )
	{
		outMesh.numElements = 0;
		outMesh.numNormals = 0;
		outMesh.numTexcoords = 0;
		outMesh.numPositions = 0;

		bool hasTex = models.size() > 0;
		bool hasNorm = models.size() > 0;

		// clear anything the outMesh might already have
		outMesh.positionBuffer.clear();
		outMesh.uvBuffer.clear();
		outMesh.normalBuffer.clear();
		outMesh.elementBuffer.clear();

		vector<GLfloat> &positions = outMesh.positionBuffer;
		vector<GLfloat> &normals = outMesh.normalBuffer;
		vector<GLfloat> &texcoords = outMesh.uvBuffer;
		vector<GLuint> &elements = outMesh.elementBuffer;

		positions.reserve( models.size() * 100 );
		normals.reserve( models.size() * 100 );
		texcoords.reserve( models.size() * 100 );
		elements.reserve( models.size() * 30 );

		for( vector<Model*>::iterator mit = models.begin(); mit != models.end(); ++mit )
		{
			Model *model = *mit;
			for( vector<Mesh>::iterator it = model->meshes.begin(); it != model->meshes.end(); ++it )
			{
				Mesh &mesh = *it;

				vector<GLfloat> &v = mesh.positionBuffer;
				vector<GLfloat> &vn = mesh.normalBuffer;
				vector<GLfloat> &vt = mesh.uvBuffer;
				vector<GLuint> &e = mesh.elementBuffer;

				for( unsigned int i = 0; i < v.size(); i += 3 )
				{
					++outMesh.numPositions;
					vec4 r = vec4( v[i], v[i + 1], v[i + 2], 1.0 );
					vec4 rt = mesh.transform.matrix * r;

					positions.push_back( rt.x );
					positions.push_back( rt.y );
					positions.push_back( rt.z );
				}

				if( hasTex )
				{
					for( vector<GLfloat>::iterator vit = vt.begin(); vit != vt.end(); ++vit )
					{
						++outMesh.numTexcoords;
						texcoords.push_back( *vit );
					}
				}

				if( hasNorm )
				{
					for( unsigned int i = 0; i < vn.size(); i += 3 )
					{
						++outMesh.numNormals;
						vec4 n = vec4( vn[i], vn[i + 1], vn[i + 2], 0.0 );
						vec4 nt = mesh.transform.matrix * n;

						normals.push_back( nt.x );
						normals.push_back( nt.y );
						normals.push_back( nt.z );
					}
				}

				for( vector<GLuint>::iterator vit = e.begin(); vit != e.end(); ++vit )
				{
					++outMesh.numElements;
					GLuint val = *vit;
					elements.push_back( val );
				}
			}
		}

	}

	void groupMeshes( vector<Model> &models, Mesh &outMesh )
	{
		outMesh.numElements = 0;
		outMesh.numNormals = 0;
		outMesh.numTexcoords = 0;
		outMesh.numPositions = 0;
		outMesh.numColors = 0;

		bool hasTex = models.size() > 0;
		bool hasNorm = models.size() > 0;
		bool hasColor = models.size() > 0;

		// clear anything the outMesh might already have
		outMesh.positionBuffer.clear();
		outMesh.uvBuffer.clear();
		outMesh.normalBuffer.clear();
		outMesh.elementBuffer.clear();
		outMesh.colorBuffer.clear();

		vector<GLfloat> &positions = outMesh.positionBuffer;
		vector<GLfloat> &normals = outMesh.normalBuffer;
		vector<GLfloat> &texcoords = outMesh.uvBuffer;
		vector<GLfloat> &colors = outMesh.colorBuffer;
		vector<GLuint> &elements = outMesh.elementBuffer;

		positions.reserve( models.size() * 100 );
		normals.reserve( models.size() * 100 );
		texcoords.reserve( models.size() * 100 );
		colors.reserve( models.size() * 100 );
		elements.reserve( models.size() * 30 );

		for( vector<Model>::iterator mit = models.begin(); mit != models.end(); ++mit )
		{
			Model &model = *mit;
			for( vector<Mesh>::iterator it = model.meshes.begin(); it != model.meshes.end(); ++it )
			{
				Mesh &mesh = *it;

				vector<GLfloat> &v = mesh.positionBuffer;
				vector<GLfloat> &vn = mesh.normalBuffer;
				vector<GLfloat> &vt = mesh.uvBuffer;
				vector<GLfloat> &vc = mesh.colorBuffer;
				vector<GLuint> &e = mesh.elementBuffer;

				for( unsigned int i = 0; i < v.size(); i += 3 )
				{
					++outMesh.numPositions;
					vec4 r = vec4( v[i], v[i + 1], v[i + 2], 1.0 );
					vec4 rt = mesh.transform.matrix * r;

					positions.push_back( rt.x );
					positions.push_back( rt.y );
					positions.push_back( rt.z );
				}

				if( hasTex )
				{
					for( vector<GLfloat>::iterator vit = vt.begin(); vit != vt.end(); ++vit )
					{
						++outMesh.numTexcoords;
						texcoords.push_back( *vit );
					}
				}

				if( hasNorm )
				{
					for( unsigned int i = 0; i < vn.size(); i += 3 )
					{
						++outMesh.numNormals;
						vec4 n = vec4( vn[i], vn[i + 1], vn[i + 2], 0.0 );
						vec4 nt = mesh.transform.matrix * n;

						normals.push_back( nt.x );
						normals.push_back( nt.y );
						normals.push_back( nt.z );
					}
				}

				if( hasColor )
				{
					for( unsigned int i = 0; i < vc.size(); i += 4 )
					{
						++outMesh.numColors;
						vec4 c = vec4( vc[i], vc[i + 1], vc[i + 2], vc[i + 3] );
						colors.push_back( c.r );
						colors.push_back( c.g );
						colors.push_back( c.b );
						colors.push_back( c.a );
					}
				}

				for( vector<GLuint>::iterator vit = e.begin(); vit != e.end(); ++vit )
				{
					++outMesh.numElements;
					GLuint val = *vit;
					elements.push_back( val );
				}
			}
		}

	}

	void groupMeshes( vector<Model> &models, vector<vec4> &colorArray, Mesh &outMesh )
	{

	}


	// Map Utilities
	void createGridModel( MapGrid *grid )
	{
		vector<Model*> wireModels = vector<Model*>();

		for( vector<GridRow>::iterator grit = grid->rows.begin(); grit != grid->rows.end(); ++grit )
		{
			GridRow &row = *grit;
			for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
			{
				MapTile &tile = *mtit;
				if( tile.exists )
				{
					wireModels.push_back( &tile.wireModel );

					Mesh &mesh = tile.wireModel.getPrimaryMesh();
					mesh.transform.setPosition( tile.position );
				}
			}
		}

		Mesh &primary = grid->model.getPrimaryMesh();
		primary.drawMode = GL_LINES;
		groupMeshes( wireModels, primary );
		primary.buildVAO();
	}

	void createPathFindModel( MapGrid *grid )
	{
		vector<Model*> arrowModels = vector<Model*>();

		for( vector<GridRow>::iterator grit = grid->rows.begin(); grit != grid->rows.end(); ++grit )
		{
			GridRow &row = *grit;
			for( vector<MapTile>::iterator mtit = row.tiles.begin(); mtit != row.tiles.end(); ++mtit )
			{
				MapTile &tile = *mtit;
				if( tile.exists && !tile.isTarget && tile.pathValDir >= 0 )
				{
					arrowModels.push_back( &tile.arrowModel );

					float angle = ((tile.pathValDir % 6) + 1) * math_util::PI / 3.0f;
					mat4 rotate = Transform::getRotationY( -angle );
					Mesh &mesh = tile.arrowModel.getPrimaryMesh();
					mesh.transform.reset();
					mesh.transform.setPosition( vec3( tile.position.x, tile.height, tile.position.z ) );
					mesh.transform.setMatrix( mesh.transform.matrix * rotate );
				}
			}
		}

		Mesh &primary = grid->getPathFindModel().getPrimaryMesh();
		groupMeshes( arrowModels, primary );
		primary.buildVAO();
	}


	void createRangeModel( vector<MapTile*> tiles, Model &rangeModel )
	{
		vector<Model*> solidModels = vector<Model*>();

		for( vector<MapTile*>::iterator tit = tiles.begin(); tit != tiles.end(); ++tit )
		{
			MapTile *tile = *tit;
			solidModels.push_back( &tile->solidModel );

			Mesh &mesh = tile->solidModel.getPrimaryMesh();
			mesh.transform.setPosition( tile->position );
		}

		Mesh &primary = rangeModel.getPrimaryMesh();
		groupMeshes( solidModels, primary );
	}


}