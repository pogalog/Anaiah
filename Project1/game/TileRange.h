#pragma once

#include <vector>
#include "model/Model.h"
#include "render/Color.h"
#include "render/Shader.h"
#include "game/Camera.h"


class MapTile;
class TileRange
{
public:
	TileRange() {}
	~TileRange() {}

	void draw( const Camera &camera );
	void buildModel();
	void setVisible( bool vis ) { model.visible = vis; }

	std::vector<MapTile*> tiles;
	Model model;
	Shader *shader;
	Color color;
};