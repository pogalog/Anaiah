-- Render Unit
-- Specifies a group of assets to be rendered to a given output Framebuffer

require( "render.main" );

function Render.createUnit( name )
	local unit = {};
	unit.name = name;
	unit.output = nil;
	unit.staticShader = nil;
	unit.animatedShader = nil;
	unit.useDefaultFBO = true;
	unit.blendSrc = GL.SRC_ALPHA;
	unit.blendDst = GL.ONE_MINUS_SRC_ALPHA;
	unit.depthTest = true;
	unit.depthFunc = GL.LEQUAL;
		
	function unit.setOutput( framebuffer )
		unit.output = framebuffer;
		unit.useDefaultFBO = false;
		Render_setOutput( unit.userdata, framebuffer.userdata );
	end
	
	function unit.clearBufferBits()
		Render_clearBufferBits( unit.userdata );
	end
	
	function unit.useDefaultFBO()
		unit.useDefaultFBO = true;
		Render_useDefaultFBO( unit.userdata );
	end
	
	function unit.setStaticShader( shader )
		unit.staticShader = shader;
		Render_setStaticShader( unit.userdata, shader.userdata );
	end
	
	function unit.setAnimatedShader( shader )
		unit.animatedShader = shader;
		Render_setAnimatedShader( unit.userdata, shader.userdata );
	end
	
	function unit.addStaticModel( model )
		Render_addStaticModel( unit.userdata, model.userdata );
	end
	
	function unit.addAnimatedModel( model )
		Render_addAnimatedModel( unit.userdata, model.userdata );
	end
	
	function unit.addUnit( cu )
		Render_addUnit( unit.userdata, cu.userdata );
	end
	
	function unit.addUIMessage( msg )
		Render_addTextItem( unit.userdata, msg.userdata );
	end
	
	function unit.removeUIMessage( msg )
		Render_removeTextItem( unit.userdata, msg.userdata );
	end
	
	function unit.addUIOverlay( overlay )
		Render_addOverlay( unit.userdata, overlay.userdata );
	end
	
	function unit.removeUIOverlay( overlay )
		Render_removeOverlay( unit.userdata, overlay.userdata );
	end
	
	function unit.addUIMenu( menu )
		Render_addMenu( unit.userdata, menu.userdata );
	end
	
	function unit.setCubemap( cm )
		Render_setCubemap( unit.userdata, cm.userdata );
	end
	
	function unit.useOrthoLens()
		Render_useOrthoLens( unit.userdata );
	end
	
	function unit.usePerspectiveLens()
		Render_usePerspectiveLens( unit.userdata );
	end
	
	function unit.useBlending( blend )
		unit.blend = blend;
		Render_useBlend( unit.userdata, blend );
	end
	
	function unit.useBlendFunc( src, dst )
		unit.blendSrc = src;
		unit.blendDst = dst;
		unit.blend = true;
		Render_useBlendFunc( unit.userdata, src, dst );
	end
	
	function unit.useDepthTest( useTest )
		unit.depthTest = useTest;
		Render_useDepthTest( unit.userdata, useTest );
	end
	
	function unit.useDepthFunc( func )
		unit.depthFunc = func;
		Render_useDepthFunc( unit.userdata, func );
	end
	
	
	unit.userdata = Render_createUnit( GameInstance, name );
	
	return unit;
end


function Render.createPostRU( name, ... )
	local ru = Render.createUnit( name );
	ru.quad = Geom.createQuadModel();
	ru.quad.build();
	
	local args = { ... };
	if( #args == 1 ) then
		ru.shader = Render.createShader( "quad.vsh", args[1] );
	else
		ru.shader = Render.createShader( args[1], args[2] );
	end
	
	-- shader
	
	ru.quad.setShader( ru.shader );
	ru.quad.setUniform( "mat4 MVP", ortho( -1, 1, -1, 1 ) );
	ru.addStaticModel( ru.quad );
	
	function ru.addInput( name, framebuffer )
		ru.quad.addFramebuffer( name, framebuffer );
	end
		
	function ru.addTexture( name, texture )
		ru.quad.addTexture( name, texture )
	end
	
	function ru.setUniform( name, value )
		ru.quad.setUniform( name, value );
	end
	
	
	return ru;
end

