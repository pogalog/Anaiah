#pragma once
#include "GameMenuItem.h"
#include "game/Camera.h"

#include <string>
#include <vector>
#include <glm/glm.hpp>

class Shader;
class GameMenu
{
public:
	GameMenu();
	~GameMenu();

	void draw( const Camera& );

	// accessor
	FontMap* getFont() { return font; }
	int getCursorPosition() { return cursorPosition; }
	GameMenuItem* getSelectedItem() { return menuItems.at( cursorPosition ); }
	std::vector<GameMenuItem*>& getItems() { return menuItems; }
	bool isVisible() { return visible; }

	// mutator
	void setFont( FontMap *font ) { this->font = font; }
	GameMenuItem* addMenuItem( std::string message );
	void moveCursorUp();
	void moveCursorDown();
	void setCursorPosition( int pos );
	void buildModel() { model.getPrimaryMesh().buildVAO(); }
	void setShader( Shader *shader ) { this->shader = shader; }
	void setItemShader( Shader *shader ) { itemShader = shader; }
	void setSize( glm::vec2 size ) { model.transform.setScale( glm::vec3( size, 1.0f ) ); }
	void setPosition( glm::vec2 pos ) { model.transform.setPosition( glm::vec3( pos, 0.0f ) ); }
	void setVisible( bool visible ) { this->visible = visible; }
	void setLayout( std::vector<GameMenuItem*> items );
	void resize();

private:

	
	glm::vec3 getNextPosition();

	Model model;
	glm::mat4 scaleMatrix;
	Shader *shader, *itemShader;
	FontMap *font;
	std::vector<GameMenuItem*> menuItems;
	glm::vec2 position, dimension;
	int cursorPosition;
	bool cursorWrap;
	bool visible;
	bool toodee;
};