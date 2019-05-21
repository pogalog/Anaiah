#pragma once
#include <string>
#include <list>
#include <GL/glew.h>

// testou
#include "model/Model.h"

class GameInstance;
class Model;
class Shader;
class Unit;
class Cubemap;
class RenderUnit;

struct GlutWin
{
	int width, height;
	std::string title;
	float xpix, ypix;
};

class GameRenderer
{
public:
	GameRenderer( GameInstance *game );
	~GameRenderer();

	void init();
	void display();
	void reshape( GLint width, GLint height );
	void animateProps( float time );
	void animateUnits( float time );
	void animateUnit( Unit *unit, float time );

	GameInstance *game;
	GlutWin win;

	void cullBackFaces( bool cull );
	void useDepthTest( bool test );
	void writeDepthMask( bool write );
	void useBlending( bool blend );
	void useDepthFunc( GLenum func );
	void useBlendFunc( GLenum source, GLenum dest );

	void addRenderUnit( RenderUnit *ru );


	// testou
	Shader testShader;
	Model quad;
	float time;
	GLuint bufferName;
	

	// GL status variables
	bool cull, depthTest, depthMaskWrite, blend;
	GLenum depthFunc, blendSource, blendDest;
	GLint windowWidth, windowHeight;

private:
	std::list<RenderUnit*> units;
};