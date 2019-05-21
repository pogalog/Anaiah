require( "game.grid" );
require( "game.fileioutil" );
require( "game.cursor" );
require( "game.tile_range" );

-- levelmap
function createLevelMap( name, mainLoop, xsize, zsize )
	local map = {};
	map.desc = "LevelMap";
	map.cursor = createCursor( map );
	map.selectedUnit = nil;
	map.name = name;
	map.userdata = nil;
	map.units = createList();
	map.teams = createList();
	map.grid = createGrid( map, xsize, zsize );
	map.triggers = createList();
	map.hints = createList();
	map.ambientBrightness = 0.0;
	
	-- ranges
	function map.initTileRanges()
		map.ranges = createList();
		map.moveRange = createTileRange( createColor( 0.1, 0.6, 0.1, 0.3 ) );
		map.attackRange = createTileRange( createColor( 0.8, 0.1, 0.1, 0.3 ) );
		map.singleAttackRange = createTileRange( createColor( 0.8, 0.1, 0.1, 0.3 ) );
		map.itemRange = createTileRange( createColor( 0.1, 0.1, 0.5, 0.3 ) );

		map.ranges.add( map.moveRange );
		map.ranges.add( map.attackRange );
		map.ranges.add( map.singleAttackRange );
		map.ranges.add( map.itemRange );
	end
	
	function map.setRangeShaders( shader )
		for i = 1, map.ranges.length() do
			map.ranges.get(i).setShader( shader );
		end
	end
	
	
	--[[ the main loop is a pointer to a function that is executed by
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
			Camera_orbitX( GameInstance, angle );
		end
		
		if( math.abs(valueY) > 0 and math.abs(valueY) > math.abs(valueX) ) then
			local norm = valueY / Controller.ANALOG_MAX;
			local angle = norm * 0.025;
			Camera_orbitY( GameInstance, -angle );
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
		LevelMap_moveUnit( GameInstance, unit.userdata, tile.address );
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
	    map.cursor = map.selectedUnit.location.copy();
	end
	
	function map.selectUnit( unit )
	    map.selectedUnit = unit;
	end
	
	
	
	-- Luac Wrappers
	function map.setGridShader( shader )
		LevelMap_setGridShader( GameInstance, shader );
	end
	
	function map.setRangeShader( shader )
		LevelMap_setRangeShader( GameInstance, shader );
	end
	
	function map.setCursorShader( shader )
		LevelMap_setCursorShader( GameInstance, shader );
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
		end
	end
	
	
	function map.markAttackRangeForUnit( unit )
		unit.moveRange = map.findMovementRange( unit );
		unit.attackRange = map.findAttackRange( unit );
		map.attackRange.build( unit.attackRange );
		map.attackRange.setVisible( true );
	end
	
	function map.markItemRangeForUnit( unit, tile )
		unit.itemRange = map.findItemRange( unit, tile );
		map.itemRange.build( unit.itemRange );
	end
	
	
	function map.updateMovementRange( unit )
		unit.moveRange = map.findMovementRange( unit );
		map.moveRange.build( unit.moveRange );
	end
	
	function map.updateAttackRange( unit )
		print( "UPDATE ATK" );
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
		local unit = map.cursor.getHighlightedUnit();
		if( unit == nil ) then return; end
		
		map.updateMovementRange();
		map.updateAttackRange();
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




-- FileIO
function readMapFromFile( filename, j_map )
	local inp = assert( io.open( filename, "rb" ) );
	local data = inp:read( "*a" );
	assert( inp:close() );

	-- read file version and choose appropriate reader
	local maj_ver = string.byte( data, 1 );
	local min_ver = string.byte( data, 2 );
	File_Pos = 3;

	if( maj_ver == 1 ) then
		if( min_ver == 4 ) then
			_G.currentMap = parseMapDataFromBinaryData( data );
			return _map;
		else
			return nil;
		end
	else
		return nil;
	end
end

function parseMapDataFromBinaryData( data )
	local mapName = readString( data );
	
	-- SCRIPTS
	local mainScriptFile = readString( data );
	local mainScriptName = extractScriptName( mainScriptFile );
	local numScripts = readInt( data );

	-- read additional scripts
	for i = 1, numScripts do
		local script = readString( data );
		-- ignore the first script; it is the main script
		if( i > 1 ) then
		end
	end


  -- GRID
	local dim = readVec2i( data );
	local map = createLevelMap( mapName, mainFunc, dim.x, dim.y );
	
  -- UNITS
	local numUnits = readInt( data );
	for i = 1, numUnits do
		local unitFilename = readString( data );
	end
  
  -- TEAMS
	local numTeams = readInt( data );
	for i = 1, numTeams do
		local teamName = readString( data );
--		local team = PF.readTeamFromDisk( teamName );
		-- starting tiles
		local numTiles = readInt( data );
		for j = 1, numTiles do
			local addy = readVec2i( data );
      -- need to probably do something with these tiles
      -- I will worry about this a little later. I don't have plans to put a placement mechanism
      -- into the game yet. Another alternative is that I could simply randomize unit locations...
      -- 11/8/14
			-- add to team
		end
		
		-- required units
		-- As with starting tiles, this information will not be used until a bit later.
		local minUnits = readInt( data );
		local maxUnits = readInt( data );
		local numReqd = readInt( data );
		for j = 1, numReqd do
			local unitID = readInt( data );
		end
		
		-- unit instancing
		local numInst = readInt( data );
		for j = 1, numInst do
			local origID = readInt( data );
			local instID = readInt( data );
		end
		
		-- static positions
		local numStatic = readInt( data );
		for j = 1, numStatic do
		  local unitID = readInt( data );
--		  local unit = team.getUnitByID( unitID );
--		  unit.staticPosition = true;
		end
		
		-- conditions
		local successDesc = readString( data );
		team.conditions.success = successDesc;
		local ssExists = readBool( data );
		if( ssExists ) then
		  -- read script
		  local ssFilename = readString( data );
		  local funcs = require( ssFilename );
		  local ssFuncName = readString( data );
		  team.conditions.success.func = funcs[ssFuncName];
		end
    
		local failureDesc = readString( data );
		team.conditions.failure = failureDesc;
		local fsExists = readBool( data );
		if( fsExists ) then
		  local fsFilename = readString( data );
		  local funcs = require( fsFilename );
		  local fsFuncName = readString( data );
		  team.conditions.failure.func = funcs[fsFuncName];
		end
		
		-- ai controlled?
		local aiEnum = readInt( data );
		
		-- team strategy
		local goal = readInt( data );
		local cluster = readInt( data );
		local violence = readInt( data );
		local healing = readInt( data );
		local protect = readInt( data );
		local buff = readInt( data );
		local debuff = readInt( data );
		local explore = readInt( data );
    
		-- add team
	end
	
  -- UNIT STRATEGY
	local nu = readInt( data );
	for i = 1, nu do
		local id = readInt( data );
		local synergy = readInt( data );
		local violence = readInt( data );
		
		local bool = readBool( data );
		if( bool ) then
			local msfn = readString( data );
			local haveCAFunction = readBool( data );
			if( haveCAFunction ) then
				readString( data );
			end
			local haveSAFunction = readBool( data );
			if( haveSAFunction ) then
				readString( data );
			end
		end
	end

  -- TIlES
	for i = 1, dim.y do
		for j = 1, dim.x do
			local tile = map.grid.getTileAtAddress( j-1, i-1 );
			tile.name = readString( data );
			tile.description = readString( data );
			tile.position.y = readFloat( data );
			tile.height = tile.position.y;
			tile.visible = readBool( data );
			tile.exists = readBool( data );
      local hasOccupant = readBool( data );
      if( hasOccupant ) then
        local unitID = readInt( data );
        local unit = map.getUnitByID( unitID );
        PF.setUnitToTile( unit, tile.address.x, tile.address.y );
      end
			readBool( data ); 				-- lock to terrain (not needed)
			tile.wall = readBool( data );
			tile.mapFlowIndex = readInt( data );  -- as of file version 1.1
			tile.modifiers.def = readInt( data );
			tile.modifiers.atk = readInt( data );
			tile.modifiers.mv = readInt( data );
			tile.modifiers.fire = readInt( data );
			tile.modifiers.ice = readInt( data );
			tile.modifiers.lightning = readInt( data );
			tile.modifiers.vis = readFloat( data );
			tile.modifiers.amb = readFloat( data );
		end
	end

	map.ambientBrightness = readFloat( data );

	-- HINTS
	local numHints = readInt( data );
	for i = 1, numHints do
		local hint = createAIHint();
		map.hints.add( hint );
		local hintType = readInt( data );
		hint.hintType = hintType;
		if( hintType == HINT_ITEM_UNIT ) then
			hint.unitID = readInt( data );
		elseif( hintType == HINT_ITEM_TILE ) then
			hint.tileAddress = readVec2i( data );
		end
		
		hint.name = readString( data );
		hint.maxActivations = readInt( data );
		hint.priority = readFloat( data );
		
		-- excluded teams
		local numTeams = readInt( data );
		for j = 1, numTeams do
			local teamName = readString( data );
			local team = map.getTeamByName( teamName );
			if( team ~= nil ) then
				hint.excludedTeams.add( team );
			end
		end
		
		-- excluded units
		local numUnits = readInt( data );
		for j = 1, numUnits do
			local unitID = readInt( data );
			local unit = map.getUnitByID( unitID );
			if( unit ~= nil ) then
				hint.excludedUnits.add( unit );
			end
		end
		
		-- activation tiles
		local numTiles = readInt( data );
		if( numTiles > 0 ) then
			local relative = readBool( data );
			if( relative ) then
				for j = 1, numTiles do
					local addy = readVec2i( data );
					local tile = map.grid.getTile( addy );
					if( tile ~= nil ) then
						hint.activationTiles.add( tile );
					end
				end
				local targetID = readInt( data );
				local unit = map.getUnitByID( targetID );
				hint.relative = (unit ~= nil);
				hint.target = unit;
			end
		end
				
		-- activation script/func
		local scriptExists = readBool( data );
		if( scriptExists ) then
			local scriptFilename = readString( data );
			local funcs = require( scriptFilename );
			local funcName = readString( data );
			hint.setActivationFunc( funcs[funcName] );
		end
	end
    
	return map;
end

