-- Lua Wrapper for an OpenGL Cubemap

require( "render.main" );


function Render.createCubemap( path, baseName )
	local cm = {};
	cm.path = path;
	cm.baseName = baseName;
	cm.shader = nil;
	
	function cm.setShader( shader )
		cm.shader = shader;
		Cubemap_setShader( cm.userdata, shader.userdata );
	end
	
	function cm.setPosXImage( filename )
		cm.posX = filename;
		Cubemap_posX( cm.userdata, filename );
	end
	
	function cm.setNegXImage( filename )
		cm.negX = filename;
		Cubemap_negX( cm.userdata, filename );
	end
	
	function cm.setPosYImage( filename )
		cm.posY = filename;
		Cubemap_posY( cm.userdata, filename );
	end
	
	function cm.setNegYImage( filename )
		cm.negY = filename;
		Cubemap_negY( cm.userdata, filename );
	end
	
	function cm.setPosZImage( filename )
		cm.posZ = filename;
		Cubemap_posZ( cm.userdata, filename );
	end
	
	function cm.setNegZImage( filename )
		cm.negZ = filename;
		Cubemap_negZ( cm.userdata, filename );
	end
	
	cm.userdata = Render_createCubemap( path, baseName );
	
	return cm;
end