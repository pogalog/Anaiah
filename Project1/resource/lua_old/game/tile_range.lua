-- Tile Range

function createTileRange( color, shader )
	local range = {};
	range.color = color;
	range.shader = shader;
	range.userdata = Range_new( GameInstance );
	Range_setColor( range.userdata, color );
	range.visible = false;
	range.controlTile = nil;
	
	
	function range.build( tiles )
		local ud = {};
		for i = 1, tiles.length() do
			ud[#ud+1] = tiles.get(i).userdata;
		end
		Range_build( range.userdata, ud );
	end
	
	function range.setVisible( visible )
		range.visible = visible;
		Range_setVisible( range.userdata, visible );
	end
	
	function range.setColor( color )
		range.color = color;
		Range_setColor( range.userdata, color );
	end
	
	function range.setShader( shader )
		range.shader = shader;
		Range_setShader( range.userdata, shader );
	end
	
	return range;
end