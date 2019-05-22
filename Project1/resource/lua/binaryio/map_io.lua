-- Binary FileIO for Level Maps

require( "binaryio.processing" );



function Binary.readMapFromFile( filename )
	local inp = assert( io.open( filename, "rb" ) );
	local data = inp:read( "*a" );
	local buffer = Binary.createBuffer( data );
	assert( inp:close() );

	-- read file version and choose appropriate reader
	local maj_ver = string.byte( data, 1 );
	local min_ver = string.byte( data, 2 );
	buffer.pos = 3;

	if( maj_ver == 1 ) then
		if( min_ver == 5 ) then
			_G.currentMap = Binary.parseMapDataFromBinaryData( buffer );
			return _map;
		else
			return nil;
		end
	else
		return nil;
	end
end



function Binary.parseMapDataFromBinaryData( data, loadConnected )
	if(#data == 0) then
		return nil;
	end
	
	local buffer = Binary.createBuffer( data );
	
	local mapName = readString( buffer );
	
	-- SCRIPTS
	local mainScriptFile = readString( buffer );
	local mainScriptName = extractScriptName( mainScriptFile );
	local numScripts = readInt( buffer );

	-- read additional scripts
	for i = 1, numScripts do
		local script = readString( buffer );
		-- ignore the first script; it is the main script
		if( i > 1 ) then
			-- TODO load the scripts?
		end
	end


  -- GRID
	local dim = readVec2i( buffer );
	local map = Game.createLevelMap( mapName, mainFunc, dim.x, dim.y );
	
  -- UNITS
	local numUnits = readInt( buffer );
	for i = 1, numUnits do
		local unitFilename = readString( buffer );
	end
  
  -- TEAMS
	local numTeams = readInt( buffer );
	for i = 1, numTeams do
		local teamName = readString( buffer );
		local team = Game.createTeam( teamName );
--		local team = PF.readTeamFromDisk( teamName );
		-- starting tiles
		local numTiles = readInt( buffer );
		for j = 1, numTiles do
			local addy = readVec2i( buffer );
      -- need to probably do something with these tiles
      -- I will worry about this a little later. I don't have plans to put a placement mechanism
      -- into the game yet. Another alternative is that I could simply randomize unit locations...
      -- 11/8/14
			-- add to team
		end
		
		-- required units
		-- As with starting tiles, this information will not be used until a bit later.
		local minUnits = readInt( buffer );
		local maxUnits = readInt( buffer );
		local numReqd = readInt( buffer );
		for j = 1, numReqd do
			local unitID = readInt( buffer );
		end
		
		-- unit instancing
		local numInst = readInt( buffer );
		for j = 1, numInst do
			local origID = readInt( buffer );
			local instID = readInt( buffer );
		end
		
		-- static positions
		local numStatic = readInt( buffer );
		for j = 1, numStatic do
		  local unitID = readInt( buffer );
--		  local unit = team.getUnitByID( unitID );
--		  unit.staticPosition = true;
		end
		
		-- conditions
		local successDesc = readString( buffer );
		team.conditions.success = successDesc;
		local ssExists = readBool( buffer );
		if( ssExists ) then
		  -- read script
		  local ssFilename = readString( buffer );
		  local funcs = require( ssFilename );
		  local ssFuncName = readString( buffer );
		  team.conditions.success.func = funcs[ssFuncName];
		end
    
		local failureDesc = readString( buffer );
		team.conditions.failure = failureDesc;
		local fsExists = readBool( buffer );
		if( fsExists ) then
		  local fsFilename = readString( buffer );
		  local funcs = require( fsFilename );
		  local fsFuncName = readString( buffer );
		  team.conditions.failure.func = funcs[fsFuncName];
		end
		
		-- ai controlled?
		local aiEnum = readInt( buffer );
		
		-- team strategy
		local goal = readInt( buffer );
		local cluster = readInt( buffer );
		local violence = readInt( buffer );
		local healing = readInt( buffer );
		local protect = readInt( buffer );
		local buff = readInt( buffer );
		local debuff = readInt( buffer );
		local explore = readInt( buffer );
    
		-- add team
	end
	
  -- UNIT STRATEGY
	local nu = readInt( buffer );
	for i = 1, nu do
		local id = readInt( buffer );
		local synergy = readInt( buffer );
		local violence = readInt( buffer );
		
		local bool = readBool( buffer );
		if( bool ) then
			local msfn = readString( buffer );
			local haveCAFunction = readBool( buffer );
			if( haveCAFunction ) then
				readString( buffer );
			end
			local haveSAFunction = readBool( buffer );
			if( haveSAFunction ) then
				readString( buffer );
			end
		end
	end

  -- TILES
	for i = 1, dim.y do
		for j = 1, dim.x do
			local tile = map.grid.getTileAtAddress( j-1, i-1 );
			tile.name = readString( buffer );
			tile.description = readString( buffer );
			tile.position.y = readFloat( buffer );
			tile.height = tile.position.y;
			tile.visible = readBool( buffer );
			tile.exists = readBool( buffer );
      local hasOccupant = readBool( buffer );
      if( hasOccupant ) then
        local unitID = readInt( buffer );
        local unit = map.getUnitByID( unitID );
--        PF.setUnitToTile( unit, tile.address.x, tile.address.y );
      end
			readBool( buffer ); 				-- lock to terrain (not needed)
			tile.wall = readBool( buffer );
			tile.mapFlowIndex = readInt( buffer );
			tile.modifiers.def = readInt( buffer );
			tile.modifiers.atk = readInt( buffer );
			tile.modifiers.mv = readInt( buffer );
			tile.modifiers.fire = readInt( buffer );
			tile.modifiers.ice = readInt( buffer );
			tile.modifiers.lightning = readInt( buffer );
			tile.modifiers.vis = readFloat( buffer );
			tile.modifiers.amb = readFloat( buffer );
		end
	end

	map.ambientBrightness = readFloat( buffer );
	
	-- PORTS
	local numMapPorts = readInt( buffer );
	for i = 1, numMapPorts do
		local port = createPort();
		map.addPort( port );
		
		-- islands
		local numIslands = readInt( buffer );
		for j = 1, numIslands do
			local island = createIsland();
			island.map = map;
			port.addIsland( island );
			
			local numIslandTiles = readInt( buffer );
			for k = 1, numIslandTiles do
				local address = readVec2i( buffer );
				local tile = map.grid.getTile( address );
				island.addTile( tile );
				tile.island = island;
			end
			
			island.buildModel();
			LevelMap_addDebugModel( GameInstance, island.model.userdata );
			Model_setShader( island.model.userdata, Shaders.wireShader.userdata );
		end
	end
	
	-- connections
	local numConnections = readInt( buffer );
	for k = 1, numConnections do
		local connection = createConnection();
		map.connections.add( connection );
		connection.isLocal = readBool( buffer );
		
		local connectedMapName = nil;
		if( isLocal == false ) then
			connectedMapName = readString( buffer );
		end
		
		connection.rotation = readInt( buffer );
		connection.embed = readBool( buffer );
		
		if( embed ) then
			connection.embedOffset = readVec2i( buffer );
		end
		
		local islandATileAddress = readVec2i( buffer );
		local islandBTileAddress = readVec2i( buffer );
		connection.islandA = map.grid.getTile( islandATileAddress ).island;
		connection.islandA.originIndex = connection.islandA.find( map.grid.getTile( islandATileAddress ) );
		if( connection.isLocal ) then
			connection.islandB = map.grid.getTile( islandBTileAddress ).island;
			connection.islandB.originIndex = connection.islandB.find( map.grid.getTile( islandBTileAddress ) );
		end
	end
	

	-- HINTS
	local numHints = readInt( buffer );
	for i = 1, numHints do
		local hint = createAIHint();
		map.hints.add( hint );
		local hintType = readInt( buffer );
		hint.hintType = hintType;
		if( hintType == HINT_ITEM_UNIT ) then
			hint.unitID = readInt( buffer );
		elseif( hintType == HINT_ITEM_TILE ) then
			hint.tileAddress = readVec2i( buffer );
		end
		
		hint.name = readString( buffer );
		hint.maxActivations = readInt( buffer );
		hint.priority = readFloat( buffer );
		
		-- excluded teams
		local numTeams = readInt( buffer );
		for j = 1, numTeams do
			local teamName = readString( buffer );
			local team = map.getTeamByName( teamName );
			if( team ~= nil ) then
				hint.excludedTeams.add( team );
			end
		end
		
		-- excluded units
		local numUnits = readInt( buffer );
		for j = 1, numUnits do
			local unitID = readInt( buffer );
			local unit = map.getUnitByID( unitID );
			if( unit ~= nil ) then
				hint.excludedUnits.add( buffer );
			end
		end
		
		-- activation tiles
		local numTiles = readInt( buffer );
		if( numTiles > 0 ) then
			local relative = readBool( buffer );
			if( relative ) then
				for j = 1, numTiles do
					local addy = readVec2i( buffer );
					local tile = map.grid.getTile( addy );
					if( tile ~= nil ) then
						hint.activationTiles.add( tile );
					end
				end
				local targetID = readInt( buffer );
				local unit = map.getUnitByID( targetID );
				hint.relative = (unit ~= nil);
				hint.target = unit;
			end
		end
				
		-- activation script/func
		local scriptExists = readBool( buffer );
		if( scriptExists ) then
			local scriptFilename = readString( buffer );
			local funcs = require( scriptFilename );
			local funcName = readString( buffer );
			hint.setActivationFunc( funcs[funcName] );
		end
	end
	
	if( loadConnected ) then
		MapIO.loadConnectedMaps( map );
	end
    
	return map;
end


MapIO = {};

function MapIO.loadConnectedMaps( map )
	local connectedMaps = createList();
	
	for i = 1, map.connections.length() do
		local mc = map.connections.get(i);
		local lm = map;
		if( mc.isLocal ) then
			if( mc.islandA == nil or mc.islandB == nil ) then
				generateWarning( "Locally connected island is incomplete!", "binaryio::map_io::MapIO.loadConnectedMaps" );
			end
		else
			local lookup = Game.lookupMap( mc.remoteMapName );
			if( lookup == nil ) then
				lm = MapIO.threadedLoadMap( "./resource/map" .. mc.remoteMapName .. ".tbs" );
				connectedMaps.add( lm );
			else
				lm = lookup;
			end
		end
		
		mc.activate();
	end
	
	
	for i = 1, connectedMaps.length() do
		local cm = connectedMaps.get(i);
		MapIO.loadConnectedMaps( cm );
	end
	
end



function MapIO.threadedLoadMap( filename )
	local data = LevelMap_load( filename );
	local map = parseMapDataFromBinaryData( data, false );
	
	-- probably need to just use the existing parseMapData function, and pass a boolean to indicate
	-- whether it should have the host immediately load, or do it in a threaded fashion
	
	return map;
end


