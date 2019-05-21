require( "binaryio.processing" );
require( "game.map.port" );



-- levelmap
function Game.createLevelMap( name, mainLoop, xsize, zsize )
	local map = {};
	map.desc = "LevelMap";
	map.cursor = Game.createCursor( map );
	map.selectedUnit = nil;
	map.name = name;
	map.userdata = nil;
	map.units = createList();
	map.teams = createList();
	map.grid = Game.createGrid( map, xsize, zsize );
	map.triggers = createList();
	map.hints = createList();
	map.ports = createList();
	map.connections = createList();
	map.activeConnections = createList();
	map.ambientBrightness = 0.0;
	
	-- ranges
	function map.initTileRanges()
		map.ranges = createList();
		map.moveRange = Game.createTileRange( Color_new( 0.1, 0.6, 0.1, 0.3 ) );
		map.moveRange.update = map.updateMovementRange;
		map.attackRange = Game.createTileRange( Color_new( 0.8, 0.1, 0.1, 0.3 ) );
		map.attackRange.update = map.updateAttackRange;
		map.singleAttackRange = Game.createTileRange( Color_new( 0.8, 0.1, 0.1, 0.3 ) );
		map.itemRange = Game.createTileRange( Color_new( 0.1, 0.1, 0.5, 0.3 ) );

		map.ranges.add( map.moveRange );
		map.ranges.add( map.attackRange );
		map.ranges.add( map.singleAttackRange );
		map.ranges.add( map.itemRange );
		
		map.buildRanges();
	end
	
	function map.setRangeShaders( shader )
		for i = 1, map.ranges.length() do
			map.ranges.get(i).setShader( shader );
		end
	end
	
	function map.addRangesToRenderUnit( ru )
		for i = 1, map.ranges.length() do
			ru.addStaticModel( map.ranges.get(i).model );
		end
	end
	
	function map.buildRanges()
		for i = 1, map.ranges.length() do
			map.ranges.get(i).build( createList() );
		end
	end
	
	
	--[[ The main loop is a pointer to a function that is executed by
	the game engine each time the game state needs to be updated. This
	funciton is responsible for executing all level-specific game logic]]
	map.mainLoop = mainLoop;

	-- FUNCTIONS
	function map.updateCamera()
		local valueX = Controller.state.RightX;
		local valueY = Controller.state.RightY;
		
		if( math.abs(valueX) > 0 and math.abs(valueX) > math.abs(valueY) ) then
			local norm = valueX / Controller.ANALOG_MAX;
			local angle = norm * 0.025;
			Camera.orbitX( angle );
		end
		
		if( math.abs(valueY) > 0 and math.abs(valueY) > math.abs(valueX) ) then
			local norm = valueY / Controller.ANALOG_MAX;
			local angle = norm * 0.025;
			Camera.orbitY( -angle );
		end
		
	end
	
	function map.setPointers( pointers )
		local index = 1;
		for k, row in pairs( map.grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				tile.userdata = pointers[index];
				index = index + 1;
			end
		end
	end
	
	function map.getUnitByID( id )
		for i = 1, map.units.length() do
			local unit = map.units.get(i);
			if( id == unit.unitID ) then
				return unit;
			end
		end
		return nil;
	end
	
	function map.getTeamByName( name )
		for i = 1, map.teams.length() do
			local team = map.teams.get(i);
			if( team.name == name ) then return team; end
		end
		return nil;
	end
  
	function map.addTrigger( trigger )
		map.triggers[#map.triggers+1] = trigger;
	end
	
	function map.addPort( port )
		map.ports.add( port );
	end

	function map.run()
		map.mainLoop();
	end

	function map.setMainLoop( loopFunc )
		map.mainLoop = loopFunc;
	end

	function map.setGridSize( xsize, zsize )
		map.grid.setSize( xsize, zsize );
	end

	function map.setName( newName )
		map.name = newName;
	end

	function map.addUnitByName( unit, name )
		map.units[name] = unit;
		map.units.add( unit );
	end
	
	function map.addUnit( unit )
		map.units[unit.name] = unit;
		map.units.add( unit );
	end
  
	function map.removeUnit( unit )
		if( unit == nil ) then return; end
		map.units.remove( unit );
		unit.team.units.remove( unit );
		if( unit.tile ~= nil ) then
			unit.tile.occupant = nil;
			unit.tile = nil;
		end
		unit.setVisible( false );
	end
	
	function map.hideUnit( unit )
		if( unit == nil ) then return; end
		if( unit.tile ~= nil ) then
			unit.tile.occupant = nil;
			unit.tile = nil;
		end
		unit.setVisible( false );
	end
  

	function map.addTeam( team )
		map.teams[#map.teams+1] = team;
	end

	function map.getUnit( name )
		return map.units[name];
	end

	function map.clearUnits()
		map.units = {};
	end

	function map.clearTriggers()
		map.triggers = {};
	end
	
	function map.getSelectedTile()
		return map.cursor.selectedTile;
	end
	
	function map.getHighlightedUnit()
		return map.cursor.getHighlightedUnit();
	end
	
	function map.getHighlightedTile()
		return map.cursor.highlightedTile;
	end
	
	function map.addCurrentTileToPath()
		map.movePath.addTile( map.grid.getTile( map.cursor ), map.selectedUnit );
	end
	
	function map.animateUnits()
		for i = 1, map.units.length() do
			local unit = map.units.get(i);
			if( unit.currentAnimation ~= nil ) then
				local animation = unit.currentAnimation;
				animation.update( Global_dt );
				unit.animate( animation.elapsedTime );
			end
		end
	end
	
	function map.moveUnitToCursor()
		local unit = map.selectedUnit;
		unit.moveToTile( map.cursor.highlightedTile );
	end
	
	function map.moveUnit( unit, tile )
		unit.moveToTile( tile );
		
		if( tile.coexist == nil ) then
			LevelMap_moveUnit( GameInstance, unit.userdata, tile.address );
		else
			LevelMap_coexistUnit( GameInstance, unit.userdata, tile.address, tile.coexist.address );
		end
	end
	
	function map.returnUnit( unit )
	    unit.tile.occupant = nil;
	    unit.tile = unit.prevTile;
	    unit.orientation = unit.prevOrientation;
	    unit.location = unit.prevLocation;
	    unit.tile.occupant = unit;
	    map.selectedUnit = unit;
	    unit.stat.ap = unit.stat.ap + unit.pointsConsumed;
	end
	
	function map.returnCursor()
	    map.cursor = Vec2_copy( map.selectedUnit.location );
	end
	
	function map.selectUnit( unit )
	    map.selectedUnit = unit;
	end
	
	
	
	-- Luac Wrappers (Lua Crappers)
	function map.setGridShader( shader )
		LevelMap_setGridShader( GameInstance, shader.userdata );
	end
	
	function map.setRangeShader( shader )
		LevelMap_setRangeShader( GameInstance, shader.userdata );
	end
	
	
	function map.setCursorPosition( address )
		map.cursor.moveTo( address );
	end
	
	function map.moveCursor( dir )
		return map.cursor.move( dir );
	end
	
	
	function map.markRangesForUnit( unit, team )
		map.singleAttackRange.setVisible( false );
		if( team == nil or unit.team ~= team ) then
			map.markAttackRangeForUnit( unit );
		else
			unit.moveRange = map.findMovementRange( unit );
			unit.attackRange = map.findAttackRange( unit );
			map.moveRange.build( unit.moveRange );
			map.attackRange.build( unit.attackRange );
			map.moveRange.setVisible( true );
			map.attackRange.setVisible( true );
			
			map.moveRange.setUnit( unit );
			map.attackRange.setUnit( unit );
		end
	end
	
	
	function map.markAttackRangeForUnit( unit )
		unit.moveRange = map.findMovementRange( unit );
		unit.attackRange = map.findAttackRange( unit );
		map.attackRange.build( unit.attackRange );
		map.attackRange.setVisible( true );
		
		map.moveRange.setUnit( unit );
		map.attackRange.setUnit( unit );
	end
	
	function map.markItemRangeForUnit( unit, tile )
		unit.itemRange = map.findItemRange( unit, tile );
		map.itemRange.build( unit.itemRange );
		
		map.itemRange.setUnit( unit );
	end
	
	
	function map.updateMovementRange()
		local unit = map.moveRange.unit;
		unit.moveRange = map.findMovementRange( unit );
		map.moveRange.build( unit.moveRange );
	end
	
	function map.updateAttackRange()
		local unit = map.attackRange.unit;
		unit.moveRange = map.findMovementRange( unit );
		unit.attackRange = map.findAttackRange( unit );
		map.attackRange.build( unit.attackRange );
	end
	
	function map.updateSingleAttackRange( unit )
		local tile = unit.ghostTile == nil and unit.tile or unit.ghostTile;
		local tiles = map.grid.getSingleAttackRange( unit, tile );
		map.singleAttackRange.build( tiles );
	end
	
	function map.updateItemRange( unit )
		unit.itemRange = map.findItemRange( unit, unit.ghostTile );
		map.buildItemRange( unit );
	end
	
	function map.updateRanges()
		for i = 1, map.ranges.length() do
			local range = map.ranges.get(i);
			if( range.visible ) then
				range.update();
			end
		end
		
--		local unit = map.cursor.getHighlightedUnit();
--		if( unit == nil ) then return; end
--		
--		map.updateMovementRange( unit );
--		map.updateAttackRange( unit );
	end
	
	function map.updateVisibleRanges()
		local unit = map.cursor.getSelectedUnit();
		if( unit == nil ) then
			unit = map.cursor.getHighlightedUnit();
		end
		if( unit == nil ) then return; end
		
		
		if( map.moveRange.visible ) then
			map.updateMovementRange( unit );
		end
		
		if( map.attackRange.visible ) then
			map.updateAttackRange( unit );
		end
		
		if( map.singleAttackRange.visible ) then
			map.updateSingleAttackRange( unit );
		end
		
		if( map.itemRange.visible ) then
			map.updateItemRange( unit );
		end
	end
	
	function map.findMovementRange( unit )
		local MV = unit.getMovementRange();
		return map.grid.getTilesWithinRange( unit, MV, false );
	end
	
	
	function map.findAttackRange( unit )
		return map.grid.getAttackRange( unit );
	end
	
	function map.findItemRange( unit, tile )
		return map.grid.getItemRange( unit, tile );
	end
	
		
	function map.getTilePointers()
		local LM_pointers = Grid_getTilePointers( GameInstance );
		LevelMap.setPointers( LM_pointers );
		map.setPointers( LM_pointers );
	end
	
	function map.buildPathFindModel()
		LevelMap_buildPathFindModel( GameInstance );
	end
	
	function map.setPathFindVisible( visible )
		LevelMap_setPathFindVisible( GameInstance, visible );
	end
	
	function map.setMoveRangeVisible( visible )
		map.moveRange.setVisible( visible );
	end
	
	function map.setSingleAttackRangeVisible( visible )
		map.singleAttackRange.setVisible( visible );
	end
	
	function map.setAttackRangeVisible( visible )
		map.attackRange.setVisible( visible );
	end
	
	function map.setItemRangeVisible( visible )
		map.itemRange.setVisible( visible );
	end
	
	function map.setRangesVisible( visible )
		map.setMoveRangeVisible( visible );
		map.setAttackRangeVisible( visible );
	end
	
	return map;
end



