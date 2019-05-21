-- Font
-- Lua Encapsulation of the C++ object
require( "render.main" );

Render.FontShader = nil;


function Render.setFontShader( shader )
	Render.FontShader = shader;
end


function Render.createFont( fontName )
	local font = {};
	font.userdata = Font_load( GameInstance, fontName, Render.FontShader.userdata );
	
	return font;
end

