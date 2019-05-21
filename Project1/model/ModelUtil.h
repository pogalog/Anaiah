#pragma once

#include <glm/glm.hpp>

#include "model/Model.h"
#include "game/MapGrid.h"
#include "game/Edge.h"

namespace model_util
{
	
	// Map Utilities
	void createGridModel( MapGrid *grid );
	void createPathFindModel( MapGrid *grid );
	void createRangeModel( std::vector<MapTile*> tiles, Model &rangeModel );
	void createIslandBorderModel( std::vector<Edge*> tiles, Model &borderModel );


	// General Model Utilities
	void groupMeshes( std::vector<Model> &models, std::vector<glm::vec4> &colorArray, Mesh &outMesh );
	void groupMeshes( std::vector<Model> &models, Mesh &outMesh );
	void groupMeshes( std::vector<Model*> &models, Mesh &outMesh );
}