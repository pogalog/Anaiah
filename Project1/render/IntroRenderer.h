#pragma once

#include <vector>
#include <glm/glm.hpp>

#include "ui/GameMenu.h"
#include "game/Camera.h"
#include "render/GameRenderer.h"

class IntroRenderer
{
public:
	IntroRenderer( int width, int height );
	~IntroRenderer();


	void init();
	void display();
	void checkNetwork( lua_State *L );


	// Menus
	// mutator
	void addMenu( GameMenu *menu ) { menus.push_back( menu ); }
	TextItem* createTextItem( FontMap *map, std::string text );
	void setClearColor( const glm::vec4 color ) { clearColor = glm::vec4( color ); }
	void addModel( Model *model ) { models.push_back( model ); }
	void setTime( float time ) { this->time = time; }
	void addTime( float dt ) { time += dt; }


	// accessor
	std::vector<TextItem*>& getTextItems() { return textItems; }
	std::vector<GameMenu*>& getMenus() { return menus; }
	std::vector<Model*>& getModels() { return models; }
	const Camera& getCamera() const { return camera; }
	const glm::vec4& getClearColor() const { return clearColor; }
	float getTime() { return time; }


private:
	std::vector<TextItem*> textItems;
	std::vector<GameMenu*> menus;
	std::vector<Model*> models;
	glm::vec4 clearColor;
	Camera camera;
	GlutWin win;
	float time;
};