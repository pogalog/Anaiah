#include "FrameBuffer.h"

#include "Framebuffer.h"
#include <stdio.h>
#include <iostream>

using namespace std;

Framebuffer::Framebuffer()
{
	texture = Texture();
	depthBufferID = -1;
    width = 2*4096;
    height = 2*4096;
    bufferID = 0;
    glGenFramebuffers( 1, &bufferID );
    glBindFramebuffer( GL_FRAMEBUFFER, bufferID );
        
    // depth buffer
    glGenTextures( 1, &texture.name );
    glBindTexture( GL_TEXTURE_2D, texture.name );
    glTexImage2D( GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, 0 );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST ); 
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL );
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE );
	glFramebufferTexture( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, texture.name, 0 );
    
    glDrawBuffer( GL_NONE );
    
    if( glCheckFramebufferStatus( GL_FRAMEBUFFER ) != GL_FRAMEBUFFER_COMPLETE )
    {
        printf( "Error creating framebuffer\n" );
    }
}

Framebuffer::Framebuffer( int w, int h, bool dummy )
{
	texture = Texture();
	depthBufferID = -1;
	width = w;
	height = h;
	bufferID = -1;
	texture.name = -1;
}

Framebuffer::Framebuffer( int w, int h )
{
    width = w;
    height = h;
    bufferID = 0;
    glGenFramebuffers( 1, &bufferID );
    glBindFramebuffer( GL_FRAMEBUFFER, bufferID );
    
	texture.name = 0;
    glGenTextures( 1, &texture.name );
    glBindTexture( GL_TEXTURE_2D, texture.name );
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0 );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    //glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    //glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    // depth buffer
    depthBufferID = 0;
    glGenRenderbuffers( 1, &depthBufferID );
    glBindRenderbuffer( GL_RENDERBUFFER, depthBufferID );
    glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height );
    glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBufferID );
    
    glFramebufferTexture( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texture.name, 0 );
    GLenum drawBuffers[1] = {GL_COLOR_ATTACHMENT0};
    glDrawBuffers( 1, drawBuffers );
    if( glCheckFramebufferStatus( GL_FRAMEBUFFER ) != GL_FRAMEBUFFER_COMPLETE )
    {
        printf( "Error creating framebuffer\n" );
    }

	glBindFramebuffer( GL_FRAMEBUFFER, 0 );
}

Framebuffer* Framebuffer::createGBuffer( GLint w, GLint h )
{
	Framebuffer *gb = new Framebuffer( w, h, true );
	GLuint gBuffer;
	glGenFramebuffers( 1, &gBuffer );
	glBindFramebuffer( GL_FRAMEBUFFER, gBuffer );
	GLuint gpos, gnorm, gcolspec;

	// position color buffer
	glGenTextures( 1, &gpos );
	glBindTexture( GL_TEXTURE_2D, gpos );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB16F, w, h, 0, GL_RGB, GL_FLOAT, NULL );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, gpos, 0 );

	// normal color buffer
	glGenTextures( 1, &gnorm );
	glBindTexture( GL_TEXTURE_2D, gnorm );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB16F, w, h, 0, GL_RGB, GL_FLOAT, NULL );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, gnorm, 0 );

	// color/specular color buffer
	glGenTextures( 1, &gcolspec );
	glBindTexture( GL_TEXTURE_2D, gcolspec );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, gcolspec, 0 );

	GLuint attachments[3] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2};
	glDrawBuffers( 3, attachments );

	// renderbuffer
	GLuint rboDepth;
	glGenRenderbuffers( 1, &rboDepth );
	glBindRenderbuffer( GL_RENDERBUFFER, rboDepth );
	glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT, w, h );
	glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepth );

	if( glCheckFramebufferStatus( GL_FRAMEBUFFER ) != GL_FRAMEBUFFER_COMPLETE )
	{
		printf( "Error creating framebuffer\n" );
	}
	glBindFramebuffer( GL_FRAMEBUFFER, 0 );

	gb->bufferID = gBuffer;
	gb->depthBufferID = rboDepth;
	gb->texture.name = gcolspec;
	gb->posTexture.name = gpos;
	gb->normTexture.name = gnorm;
	return gb;
}

Framebuffer::Framebuffer( const Framebuffer& orig )
{
}

Framebuffer::~Framebuffer()
{
}

void Framebuffer::bind()
{
    glBindFramebuffer( GL_FRAMEBUFFER, bufferID );
    glViewport( 0, 0, width, height );
}

void Framebuffer::transferDepthDataTo( Framebuffer *fb )
{
	glBindFramebuffer( GL_READ_FRAMEBUFFER, bufferID );
	glBindFramebuffer( GL_DRAW_FRAMEBUFFER, fb == NULL ? 0 : fb->bufferID );
	glBlitFramebuffer( 0, 0, width, height, 0, 0, fb == NULL ? width : fb->width, fb == NULL ? height : fb->height, GL_DEPTH_BUFFER_BIT, GL_NEAREST );
	glBindFramebuffer( GL_FRAMEBUFFER, 0 );
}

void Framebuffer::setupParticleBuffer()
{
	bufferID = 0;
	glGenFramebuffers( 1, &bufferID );
	glBindFramebuffer( GL_FRAMEBUFFER, bufferID );
	
	texture.name = 0;
	glGenTextures( 1, &texture.name );
	glBindTexture( GL_TEXTURE_2D, texture.name );
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_FLOAT, 0 );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	
	// depth buffer
//	depthBufferID = 0;
//	glGenRenderbuffers( 1, &depthBufferID );
//	glBindRenderbuffer( GL_RENDERBUFFER, depthBufferID );
//	glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height );
//	glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBufferID );
	
	glFramebufferTexture( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texture.name, 0 );
	GLenum drawBuffers[1] = {GL_COLOR_ATTACHMENT0};
	glDrawBuffers( 1, drawBuffers );
	if( glCheckFramebufferStatus( GL_FRAMEBUFFER ) != GL_FRAMEBUFFER_COMPLETE )
	{
		printf( "Error creating framebuffer\n" );
	}
}

