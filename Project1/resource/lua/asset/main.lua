-- Asset Management System
require( "structure.list" );

Asset = {};
Asset.Shaders = createList();
Asset.Models = createList();
Asset.Textures = createList();
Asset.Fonts = createList();
Asset.Animations = createList();
Asset.Sounds = createList();
Asset.Music = createList();
Asset.Units = createList();

function Asset.loadShader( vertPath, fragPath )
	local shader = Render.createShader( vertPath, fragPath );
	Asset.Shaders.add( shader );
	return shader;
end


function Asset.loadFont( fontName )
	local font = Render.createFont( fontName );
	Asset.Fonts.add( font );
	return font;
end


function Asset.loadUnit( unitName )
	
end
