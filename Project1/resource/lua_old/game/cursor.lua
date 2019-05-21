-- cursor

function createCursor( map )
	local cursor = {};
	cursor.map = map;
	cursor.highlightedTile = nil;
	cursor.selectedTile = nil;
	cursor.selectedUnit = nil;
	cursor.targetPosition = createVec3( 0, 0, 0 );
	cursor.position = createVec3( 0, 0, 0 );
	cursor.velocity = createVec3( 0, 0, 0 );
	cursor.acceleration = createVec3( 0, 0, 0 );
	cursor.externalForce = createVec3( 0, 0, 0 );
	cursor.stiffness = 1000.0;
	cursor.damping = 50.0;
	cursor.MAX_EXTERNAL_FORCE = 100.0;
	cursor.analog = false;
	
	
	function cursor.update()
		local dt = 0.016;
		cursor.acceleration = (cursor.position.sub( cursor.targetPosition ).mul( -cursor.stiffness ));
		cursor.acceleration.subLocal( cursor.velocity.mul( cursor.damping ) );
		cursor.acceleration.addLocal( cursor.externalForce );
		cursor.velocity.addLocal( cursor.acceleration.mul( dt ) );
		cursor.position.addLocal( cursor.velocity.mul( dt ) );
		
		if( cursor.analog ) then
			LevelMap.cursor.attachToNearestTile();
		end
		Cursor_setPosition( GameInstance, cursor.position );
	end
	
	function cursor.useDigitalControl()
		cursor.externalForce.set( 0, 0, 0 );
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
		Camera_lookDownAtTile( GameInstance, cursor.highlightedTile.userdata );
		
		-- callback to UI
		if( UIReg.activeUI ~= nil and UIReg.activeUI.cursorMoved ~= nil ) then
			UIReg.activeUI.cursorMoved( cursor.highlightedTile );
		end
		
		-- is cursor on a Unit?
		if( cursor.highlightedTile.occupant ~= nil ) then
			UIReg.activeUI.cursorOnUnit( cursor.highlightedTile.occupant );
		end
		
		cursor.targetPosition = cursor.highlightedTile.position.add( createVec3( 0, 0.05, 0 ) );
	end
	
	function cursor.getAddress()
		if( cursor.highlightedTile == nil ) then return createVec2( 0, 0 ); end
		return cursor.highlightedTile.address;
	end
	
	function cursor.move( direction )
		local currentAddress = cursor.getAddress();
		local newAddress = currentAddress.add( direction );
		if( newAddress.x < 0 or newAddress.y < 0 ) then return; end
		if( newAddress.x >= map.grid.size.x or newAddress.y >= map.grid.size.y ) then return; end
		return cursor.moveTo( newAddress );
	end
	
	function cursor.moveToSelectedUnit()
		if( cursor.selectedUnit == nil ) then return; end
		local address = cursor.selectedUnit.tile.address;
		cursor.moveTo( address );
	end
	
	function cursor.selectTile()
		if( cursor.highlightedTile == nil ) then return false; end
		cursor.externalForce.set( 0, 0, 0 );
		cursor.useDigitalControl();
		cursor.selectedTile = cursor.highlightedTile;
		UIReg.activeUI.selectTile( cursor.selectedTile );
		
		return false;
	end
	
	function cursor.deselectTile()
		cursor.selectedTile = nil;
		cursor.selectedUnit = nil;
	end
	
	
	function cursor.getHighlightedUnit()
		if( cursor.highlightedTile == nil ) then return nil; end
		return cursor.highlightedTile.occupant;
	end
	
	function cursor.getSelectedUnit()
		return cursor.selectedUnit;
	end
	
	
	
	return cursor;
end

