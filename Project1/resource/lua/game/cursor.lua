-- Cursor

function Game.createCursor( map )
	local cursor = {};
	cursor.map = map;
	cursor.highlightedTile = nil;
	cursor.selectedTile = nil;
	cursor.selectedUnit = nil;
	cursor.targetPosition = Vec3_new( 0, 0, 0 );
	cursor.position = Vec3_new( 0, 0, 0 );
	cursor.velocity = Vec3_new( 0, 0, 0 );
	cursor.acceleration = Vec3_new( 0, 0, 0 );
	cursor.externalForce = Vec3_new( 0, 0, 0 );
	cursor.stiffness = 1000.0;
	cursor.damping = 50.0;
	cursor.MAX_EXTERNAL_FORCE = 100.0;
	cursor.analog = false;
	cursor.color = Vec3_new( 1, 1, 0 );
	
	
	-- rendering
	function cursor.buildModel()
		cursor.model = Geom.createWireHexModel();
		cursor.model.build();
		cursor.model.setUniform( "vec3 color", cursor.color );
		cursor.model.setLineWidth( 4.0 );
	end
	
	function cursor.setShader( shader )
		cursor.model.setShader( shader );
	end
	
	function cursor.setColor( color )
		cursor.color = color;
		cursor.model.setUniform( "vec3 color", cursor.color );
	end
	
	function cursor.setForce( fx, fy )
		local c = Vec2_new( fx, fy );
		local f = Camera.forward;
		local r = Camera.right;
		-- take a dot product between c (local camera space) and f and r (also local to camera), which are just c.y and c.x, respectively
		-- multiply those components by the camera's local vectors (world space)
		cursor.externalForce.x = c.y * f.x + c.x * r.x;
		cursor.externalForce.z = c.y * f.y + c.x * r.y;
		
		Vec3_mulLocal( cursor.externalForce, cursor.MAX_EXTERNAL_FORCE );
	end
	
	function cursor.update()
		local dt = 0.016;
		cursor.acceleration = Vec3_mul( Vec3_sub( cursor.position, cursor.targetPosition ), -cursor.stiffness );
		Vec3_subLocal( cursor.acceleration, Vec3_mul( cursor.velocity, cursor.damping ) );
		Vec3_addLocal( cursor.acceleration, cursor.externalForce );
		Vec3_addLocal( cursor.velocity, Vec3_mul( cursor.acceleration, dt ) );
		Vec3_addLocal( cursor.position, Vec3_mul( cursor.velocity, dt ) );
		
		if( cursor.analog ) then
			LevelMap.cursor.attachToNearestTile();
		end
		cursor.model.setPosition( cursor.position );
	end
	
	function cursor.useDigitalControl()
		Vec3_set( cursor.externalForce, 0, 0, 0 );
		cursor.stiffness = 1000.0;
		cursor.damping = 50.0;
		cursor.analog = false;
	end
	
	function cursor.useAnalogControl()
		cursor.stiffness = 50.0;
		cursor.damping = 5.0;
		cursor.analog = true;
	end
	
	function cursor.attachToNearestTile()
		local address = cursor.map.grid.getAddressThatContainsPoint( cursor.position );
		local tile = cursor.map.grid.getTile( address );
		if( tile == nil ) then
			return;
		end
		cursor.moveTo( address );
--		cursor.targetPosition = tile.position;
	end
	
	function cursor.moveTo( address )
		local tile = map.grid.getTile( address );
		if( tile == cursor.highlightedTile ) then return; end
		cursor.highlightedTile = tile;
		
		-- callback to overlay
		Overlay.disposeUnitOverlay();
		local unit = cursor.getHighlightedUnit();
		if( unit ~= nil ) then
			Overlay.displayUnitOverlay( unit );
		end
		
		-- callback to camera
		Camera.lookDownAtTile( cursor.highlightedTile );
		
		-- callback to UI
		UI.callback( "cursorMoved", cursor.highlightedTile );
		
		-- is cursor on a Unit?
		if( cursor.highlightedTile.hasOccupant() ) then
			UI.callback( "cursorOnUnit", cursor.getHighlightedUnit() );
		end
		
		cursor.targetPosition = Vec3_add( cursor.highlightedTile.position, Vec3_new( 0, 0.05, 0 ) );
	end
	
	function cursor.moveToTile( tile )
		if( tile == nil ) then return; end
		cursor.moveTo( tile.address );
	end
	
	function cursor.getAddress()
		if( cursor.highlightedTile == nil ) then return Vec2_new( 0, 0 ); end
		return cursor.highlightedTile.address;
	end
	
	function cursor.move( direction )
		local index = cursor.getNeighborIndexFromDirection( direction );
		if( index < 0 ) then
			generateWarning( string.format( "Invalid move direction in cursor (%s)", Vec2_tostring( direction ) ), "game::cursor::cursor::move" );
			return;
		end
		
		local newTile = cursor.highlightedTile.neighbors[index];
		if( newTile == nil ) then return; end
		
		cursor.moveTo( newTile.address );
--		local currentAddress = cursor.getAddress();
--		local newAddress = Vec2_add( currentAddress, direction );
--		if( newAddress.x < 0 or newAddress.y < 0 ) then return; end
--		if( newAddress.x >= map.grid.size.x or newAddress.y >= map.grid.size.y ) then return; end
--		return cursor.moveTo( newAddress );
	end
	
	
	function cursor.getNeighborIndexFromDirection( dir )
		
		if( dir.x == 1 and dir.y == 1 ) then return 1; end
		if( dir.x == 0 and dir.y == 1 ) then return 2; end
		if( dir.x ==-1 and dir.y == 0 ) then return 3; end
		if( dir.x ==-1 and dir.y ==-1 ) then return 4; end
		if( dir.x == 0 and dir.y ==-1 ) then return 5; end
		if( dir.x == 1 and dir.y == 0 ) then return 6; end
		
		return -1;
	end
	
	
	function cursor.moveToSelectedUnit()
		if( cursor.selectedUnit == nil ) then return; end
		local address = cursor.selectedUnit.tile.address;
		cursor.moveTo( address );
	end
	
	function cursor.selectTile()
		if( cursor.highlightedTile == nil ) then return false; end
		Vec3_set( cursor.externalForce, 0, 0, 0 );
		cursor.useDigitalControl();
		cursor.selectedTile = cursor.highlightedTile;
		UI.callback( "selectTile", cursor.selectedTile );
		
		return false;
	end
	
	function cursor.deselectTile()
		cursor.selectedTile = nil;
		cursor.selectedUnit = nil;
	end
	
	
	function cursor.getHighlightedUnit()
		if( cursor.highlightedTile == nil ) then return nil; end
		return cursor.highlightedTile.getOccupant();
	end
	
	function cursor.getSelectedUnit()
		return cursor.selectedUnit;
	end
	
	
	
	return cursor;
end

