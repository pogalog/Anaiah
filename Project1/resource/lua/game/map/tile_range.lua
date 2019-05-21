-- Tile Range


function Game.createTileRange( color, shader )
	local range = {};
	range.color = color;
	range.shader = shader;
	range.userdata = Range_new( GameInstance );
	range.visible = false;
	range.controlTile = nil;
	range.unit = nil;
	range.built = false;
	
	
	-- Override this function to provide a way to collect tiles
	function range.update() end
	
	
	function range.setUnit( unit )
		range.unit = unit;
	end
	
	function range.build( tiles )
		local ud = {};
		for i = 1, tiles.length() do
			ud[#ud+1] = tiles.get(i).userdata;
		end
		
		local mud = Range_build( range.userdata, ud );
		if( range.built ) then
			range.model.userdata = mud;
		else
			range.model = Geom.createModel( mud );
		end
		range.model.build();
		
		range.built = true;
		range.setColor( range.color );
		range.setShader( range.shader );
		range.setVisible( range.visible );
	end
	
	function range.setVisible( visible )
		range.visible = visible;
		
		if( range.built ) then
			range.model.setVisible( visible );
		end
	end
	
	function range.setColor( color )
		if( color == nil ) then return; end
		range.color = color;
		
		if( range.built ) then
			range.model.setUniform( "vec4 color", color );
		end
	end
	
	function range.setShader( shader )
		if( shader == nil ) then return; end
		range.shader = shader;
		
		if( range.built ) then
			range.model.setShader( shader );
		end
	end
	
	return range;
end