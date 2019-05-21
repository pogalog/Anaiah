#pragma once
#include <gl/glew.h>
#include "Texture.h"


class Framebuffer
{
public:
    Framebuffer();
    Framebuffer( int, int );
    Framebuffer( int w, int h, bool );
    Framebuffer( const Framebuffer& orig );
    static Framebuffer createParticleBuffer( int sx, int sy )
    {
    	Framebuffer fb = Framebuffer( sx, sy, true );
    	fb.setupParticleBuffer();
    	return fb;
    }
	static Framebuffer* createGBuffer( GLint w, GLint h );
    virtual ~Framebuffer();
    
    void bind();
	void transferDepthDataTo( Framebuffer *fb );
    
	GLuint bufferID, depthBufferID;
    int width, height;
	Texture texture, posTexture, normTexture;
private:
    
    void setupParticleBuffer();

};

