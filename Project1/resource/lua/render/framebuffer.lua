-- OpenGL Framebuffer Object Wrapper

require( "render.main" );

function Render.createFramebuffer( w, h )
	local fb = {};
	fb.width = w;
	fb.height = h;
	
	fb.userdata = Framebuffer_new( w, h );
	
	return fb;
end


function Render.createGBuffer( w, h )
	local gb = {};
	gb.width = w;
	gb.height = h;
	
	gb.userdata, gb.posUD, gb.normUD, gb.colorUD = Framebuffer_newGBuffer( w, h );
	gb.pos = Render.createTexture( w, h, gb.posUD );
	gb.norm = Render.createTexture( w, h, gb.normUD );
	gb.color = Render.createTexture( w, h, gb.colorUD );
	
	return gb;
end


function Render.createTexture( w, h, ud )
	local texture = {};
	texture.width = w;
	texture.height = h;
	texture.userdata = ud;
	
	return texture;
end