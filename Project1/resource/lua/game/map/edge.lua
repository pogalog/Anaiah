-- Tile Edge

function createEdge( tile, direction )
	local edge = {};
	edge.tile = tile;
	edge.direction = direction;
	
	
	function edge.equals( e )
		if( e == nil ) then return false; end
--		print( "compare: " .. Vec2_tostring( e.tile.address ) .. ", " .. e.direction );
--		print( Vec2_tostring( edge.tile.address ) .. ", " .. edge.direction );
		if( edge.tile == e.tile and edge.direction == e.direction ) then return true; end
		return false;
	end
	
	
	function edge.print()
		print( string.format( "Edge <%s> @%d", Vec2_tostring( edge.tile.address ), edge.direction ) );
	end
	
	return edge;
end




function createEdgeRemap( edge, tile )
	local er = {};
	er.edge = edge;
	er.tile = tile;
	
	
	return er;
end