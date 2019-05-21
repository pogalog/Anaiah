#pragma once
#include <string>
#include <iostream>
#include <GL/glew.h>

namespace gl
{
	using namespace std;

	string getGLErrorString( GLenum errCode )
	{
		switch( errCode )
		{
			case GL_NO_ERROR: return "No error";
			case GL_INVALID_ENUM: return "Invalid enum";
			case GL_INVALID_VALUE: return "Invalid value";
			case GL_INVALID_OPERATION: return "Invalid Operation";
			case GL_INVALID_FRAMEBUFFER_OPERATION: return "Invalid Framebuffer Operation";
			case GL_OUT_OF_MEMORY: return "Out of Memory";
		}
		return "";
	}

	void glError()
	{
		GLenum err = glGetError();
		if( err == GL_NO_ERROR ) return;

		string errString = getGLErrorString( err );
		cout << "OPENGL ERROR: " << errString << endl;
	}

	void glError( string message )
	{
		GLenum err = glGetError();
		if( err == GL_NO_ERROR ) return;

		string errString = getGLErrorString( err );
		cout << "OPENGL ERROR: " << errString << "@" << message << endl;
	}

	
}