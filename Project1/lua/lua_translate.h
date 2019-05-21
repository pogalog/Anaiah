#pragma once
#include <GL/glew.h>

namespace lua
{

	GLuint translateDrawMode( GLuint luaValue )
	{
		switch( luaValue )
		{
			case 0: return GL_LINES;
			case 1: return GL_LINE_STRIP;
			case 2: return GL_TRIANGLES;
			case 3: return GL_TRIANGLE_STRIP;
			default: return 0;
		}
	}

	GLuint translatePrimitiveType( GLuint luaValue )
	{
		switch( luaValue )
		{
			case 0: return GL_UNSIGNED_BYTE;
			case 1: return GL_BYTE;
			case 2: return GL_UNSIGNED_SHORT;
			case 3: return GL_SHORT;
			case 4: return GL_UNSIGNED_INT;
			case 5: return GL_INT;
			case 6: return GL_FLOAT;
			default: return 0;
		}
	}

	GLuint translateBlendFunc( GLuint luaValue )
	{
		switch( luaValue )
		{
			case 0: return GL_ZERO;
			case 1: return GL_ONE;
			case 2: return GL_SRC_COLOR;
			case 3: return GL_ONE_MINUS_SRC_COLOR;
			case 4: return GL_DST_COLOR;
			case 5: return GL_ONE_MINUS_DST_COLOR;
			case 6: return GL_SRC_ALPHA;
			case 7: return GL_ONE_MINUS_SRC_ALPHA;
			case 8: return GL_DST_ALPHA;
			case 9: return GL_ONE_MINUS_DST_ALPHA;
			case 10: return GL_CONSTANT_COLOR;
			case 11: return GL_ONE_MINUS_CONSTANT_COLOR;
			case 12: return GL_CONSTANT_ALPHA;
			case 13: return GL_ONE_MINUS_CONSTANT_ALPHA;
			case 14: return GL_SRC_ALPHA_SATURATE;
			case 15: return GL_SRC1_COLOR;
			case 16: return GL_ONE_MINUS_SRC1_COLOR;
			case 17: return GL_SRC1_ALPHA;
			case 18: return GL_ONE_MINUS_SRC1_ALPHA;
		}
		return 0;
	}

	GLuint translateDepthMode( GLuint luaValue )
	{
		switch( luaValue )
		{
			case 0: return GL_NEVER;
			case 1: return GL_LESS;
			case 2: return GL_EQUAL;
			case 3: return GL_LEQUAL;
			case 4: return GL_GREATER;
			case 5: return GL_NOTEQUAL;
			case 6: return GL_GEQUAL;
			case 7: return GL_ALWAYS;
		}
		return 0;
	}

	GLuint translateColorMode( GLuint luaValue )
	{
		switch( luaValue )
		{
			case 0: return GL_RGBA;
			default: return 0;
		}
	}
}