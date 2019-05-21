#pragma once
#include "game/Camera.h"

#include <string>
#include <vector>
#include <glm/glm.hpp>

class Shader;
class OverlayItem;
class FontMap;
class Overlay
{
public:
	Overlay();
	~Overlay();

	void draw( const Camera& );

	// accessor
	FontMap* getFont() { return font; }
	std::vector<OverlayItem*>& getItems() { return overlayItems; }
	bool isVisible() { return visible; }

	// mutator
	void setFont( FontMap *font ) { this->font = font; }
	OverlayItem* addOverlayItem( std::string message );
	void buildModel() { model.getPrimaryMesh().buildVAO(); }
	void setShader( Shader *shader ) { this->shader = shader; }
	void setItemShader( Shader *shader ) { itemShader = shader; }
	void setSize( glm::vec2 size ) { model.transform.setScale( glm::vec3( size, 1.0f ) ); }
	void setPosition( glm::vec2 pos ) { model.transform.setPosition( glm::vec3( pos, 0.0f ) ); }
	void setVisible( bool visible ) { this->visible = visible; }
	void setLayout( std::vector<OverlayItem*> items );
	void resize();

private:


	glm::vec3 getNextPosition();

	Model model;
	glm::mat4 scaleMatrix;
	Shader *shader, *itemShader;
	FontMap *font;
	std::vector<OverlayItem*> overlayItems;
	glm::vec2 position, dimension;
	bool visible;
	bool toodee;
};