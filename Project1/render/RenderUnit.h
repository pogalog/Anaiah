#pragma once
#include "Shader.h"
#include "Framebuffer.h"
#include "model/Model.h"
#include "model/Node.h"

#include <list>
#include <iostream>

class Cubemap;
class Overlay;
class GameMenu;
class TextItem;

class RenderUnit
{

public:
	RenderUnit( std::string name );
	~RenderUnit();

	void init( GLint width, GLint height );
	void reshape( GLint width, GLint height );
	void display( const Camera &camera );

	void setStaticShader( Shader *shader ) { staticShader = shader; }
	void setAnimatedShader( Shader *shader ) { animatedShader = shader; }
	void addStaticModel( Model *m ) { staticModels.push_back( m ); }
	void removeStaticModel( Model *m ) { staticModels.remove( m ); }
	void addAnimatedModel( Node *n ) { animatedModels.push_back( n ); }
	void removeAnimatedModel( Node *n ) { animatedModels.remove( n ); }
	void addUnit( Unit *unit ) { units.push_back( unit ); }
	void removeUnit( Unit *unit ) { units.remove( unit ); }
	void addTextItem( TextItem *ti ) { textItems.push_back( ti ); }
	void removeTextItem( TextItem *ti ) { textItems.remove( ti ); }
	void addOverlay( Overlay *overlay ) { overlays.push_back( overlay ); }
	void removeOverlay( Overlay *overlay ) { overlays.remove( overlay ); }
	void addMenu( GameMenu *menu ) { menus.push_back( menu ); }
	void removeMenu( GameMenu *menu ) { menus.remove( menu ); }
	void setOutputBuffer( Framebuffer *output ) { this->output = output; useDefaultFBO = false; }
	void setCubemap( Cubemap *cm ) { cubemap = cm; }
	void setClearColor( glm::vec4 color ) { clearColor = color; }


	Shader *staticShader;
	Shader *animatedShader;
	std::list<Model*> staticModels;
	std::list<Node*> animatedModels;
	std::list<Unit*> units;
	std::list<TextItem*> textItems;
	std::list<Overlay*> overlays;
	std::list<GameMenu*> menus;
	Cubemap *cubemap;
	Framebuffer *output;
	bool clearBufferBits;
	glm::vec4 clearColor;
	std::string name;

	bool useDefaultFBO;
	bool cullBackFaces, depthTest, depthMaskWrite, blend;
	GLenum depthFunc, blendSource, blendDest;
	GLint windowWidth, windowHeight;
};