-- Unit Path


function Game.createPath()
	local path = {};
	path.path = createList();
	path.vpath = createList();
	path.pvd = createList();
	path.complete = true;
	
	function path.addTile( tile )
		path.path.add( tile );
		path.vpath.add( tile.address );
		path.pvd.add( tile.pathValDir );
	end
	
	function path.addTileRemote( tile, pvd )
		path.path.add( tile );
		path.vpath.add( tile.address );
		path.pvd.add( pvd );
	end
	
	function path.length()
		return path.path.length();
	end
	
	function path.getDestination()
		return path.path.last();
	end
	
	return path;
end


function Game.createUnitPath( unit, path )
	local unitPath = {};
	unitPath.unit = unit;
	unitPath.path = path;
	unitPath.progressParam = 0.0;
	unitPath.currentTileIndex = 1;
	unitPath.finished = false;
	
	function unitPath.getCurrentTile()
		return path.path.get( unitPath.currentTileIndex );
	end
	
	function unitPath.getNextTile()
		if( unitPath.currentTileIndex +1 > path.path.length() ) then return nil; end
		return path.path.get( unitPath.currentTileIndex +1 );
	end
	
	
	-- initialize unit direction
	local pvd = unitPath.path.pvd.get(1);
	local dir0 = unitPath.unit.orientation;
	if( pvd < 0 ) then unitPath.unit.orientation = dir0;
	else unitPath.unit.orientation = pvd; end
	
	unit.alignToOrientation();
	
	function unitPath.isFinished()
		return unitPath.finished;
	end
	
	function unitPath.getDestination()
		return unitPath.path.path.last();
	end
	
	function unitPath.getAssociatedAP()
		return unitPath.path.path.length();
	end
	
	function unitPath.update()
		-- make progress
		unitPath.progressParam = unitPath.progressParam + 0.075 * 0.5;
		
		-- are we ready to move on to the next tile?
		if( unitPath.progressParam >= 1.0 ) then
			unitPath.currentTileIndex = unitPath.currentTileIndex + 1;
			
			-- subtract 1.0 rather than setting it to 0 to avoid slowing down the unit
			unitPath.progressParam = unitPath.progressParam - 1.0;
			
			-- update the direction
			local pvd = unitPath.path.pvd.get( unitPath.currentTileIndex );
			local dir0 = unitPath.unit.orientation;
			if( pvd >= 0 and pvd <= 5 ) then unitPath.unit.orientation = pvd; end
			
			LevelMap.moveUnit( unit, unitPath.getCurrentTile() );
			unit.alignToOrientation();
		end
		
		-- are we done?
		if( unitPath.currentTileIndex >= unitPath.path.path.length() ) then
			unitPath.finished = true;
			unitPath.unit.isMoving = false;
			return true;
		end
		
		-- set unit position
		unitPath.advanceUnit();
		return false;
	end
	
	
	function unitPath.computeNewPosition()
		local tile0 = unitPath.path.path.get( unitPath.currentTileIndex );
		local tile1 = unitPath.path.path.get( unitPath.currentTileIndex+1 );
		local p0 = tile0.position;
		local p1 = tile1.position;
		local r = Vec3_mul( Vec3_sub( p1, p0 ), unitPath.progressParam );
		local p = Vec3_add( p0, r );
		unitPath.unit.position = p;
		return p;
	end
	
	function unitPath.advanceUnit()
		Unit_advance( unitPath.unit.userdata, unitPath.computeNewPosition() );
	end
	
	
	
	return unitPath;
end