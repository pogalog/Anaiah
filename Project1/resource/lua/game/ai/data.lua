-- AI Data Processing
-- Invokes the Binary System to store map data and retrieve result data


function AI.fetchResult()
	local ai_data = Game_fetchAIResult( GameInstance );
	local result = AI.interpretAIResult( ai_data );
	if( result == nil ) then return; end
	
	-- do we need a move action?
	local actionList = createList();
	if( result.unit.tile ~= result.destination ) then
		local grid = LevelMap.grid;
		grid.clearPathFinding();
		grid.addPathFindingTarget( result.destination );
		grid.findPath();
		result.unit.path = grid.getPathForUnit( result.unit );
		local unitPath = Game.createUnitPath( result.unit, result.unit.path );
		
		actionList.add( Exec.createAIMoveAction( unitPath ) );
	end
	actionList.add( Exec.createAIAttackAction( result.unit, result.target ) );
	Exec.commitActions( actionList );
end


function AI.packAIData( teamID )
	local buffer = Binary.createBuffer();
	
	-- AI team id
	writeInt( buffer, teamID );
	
	-- units/teams
	-- TODO: Should determine which units of which the active AI team should have knowledge,
	-- and only send the data for those units.
	-- UPDATE: Maybe, do this. I need to benchmark if it is actually beneficial to do this
	-- in terms of overhead. It may slow things down, but could improve performance if done efficiently.
	writeInt( buffer, Teams.length() );
	for i = 1, Teams.length() do
		local team = Teams.get(i);
		writeBool( buffer, team.aiControlled );
		writeInt( buffer, team.units.length() );
		for j = 1, team.units.length() do
			local unit = team.units.get(j);
			unit.writeToBuffer( buffer );
		end
	end
	
	-- the grid
	local rows = LevelMap.grid.rows;
	writeInt( buffer, #rows );
	writeInt( buffer, #rows[1].tiles );
	for i = 1, #rows do
		local row = rows[i];
		for j = 1, #row.tiles do
			local tile = row.tiles[j];
			tile.writeToBuffer( buffer );
		end
	end
	
	-- remapped neighbors
	writeInt( buffer, LevelMap.activeConnections.length() );
	for i = 1, LevelMap.activeConnections.length() do
		local ac = LevelMap.activeConnections.get(i);
		
		writeInt( buffer, ac.remappings.length() );
		for j = 1, ac.remappings.length() do
			local remap = ac.remappings.get(j);
			writeVec2i( buffer, remap.edge.tile.address );
			writeInt( buffer, remap.edge.direction );
			writeVec2i( buffer, remap.tile.address );
		end
	end
	
	buffer.finalize();
	return string.len( buffer.data ), buffer.data;
end


function AI.interpretAIData( data )
	if( string.len( data ) == 0 ) then
		print( "EMPTY!" );
		return;
	end
	
	local buffer = Binary.createBuffer( data );
	
	-- AI team id
	local activeTeamID = readInt( buffer );
	
	-- units/teams
	_G.Teams = createList();
	_G.Units = {};
	local numTeams = readInt( buffer );
	for i = 1, numTeams do
		local team = Game.createTeam( "AI_team" );
		team.aiControlled = readBool( buffer );
		local numUnits = readInt( buffer );
		for j = 1, numUnits do
			local unit = createUnitFromData( buffer );
			team.addUnit( unit );
			Units[unit.unitID] = unit;
		end
		Teams.add( team );
	end
	
	_G.ActiveTeam = Teams.get( activeTeamID );
	
	-- the grid
	local numRows = readInt( buffer );
	local numCols = readInt( buffer );
	local map = Game.createLevelMap( "AI_map", nil, numCols, numRows );
	for i = 1, numRows do
		for j = 1, numCols do
			local tile = createTileFromData( buffer, j-1, i-1 );
			map.grid.rows[i].tiles[j] = tile;
			if( tile.occupantID > 0 ) then
				tile.occupant = Units[tile.occupantID];
				tile.occupant.tile = tile;
			end
		end
	end
	map.grid.buildNeighbors();
	
	-- connections
	local numConnections = readInt( buffer );
	for i = 1, numConnections do
		local numRemap = readInt( buffer );
		
		for j = 1, numRemap do
			local tileAaddress = readVec2i( buffer );
			local tileA = map.grid.getTile( tileAaddress );
			local direction = readInt( buffer );
			local tileBaddress = readVec2i( buffer );
			local tileB = map.grid.getTile( tileBaddress );
			
			tileA.neighbors[direction] = tileB;
		end
	end
	
	return map;
end



function AI.packAIResult( result )
	local buffer = Binary.createBuffer();
	writeInt( buffer, result.unit.unitID );
	writeInt( buffer, result.target.unitID );
	writeVec2i( buffer, result.destination.address );
	buffer.finalize();
	return buffer.data;
end


function AI.interpretAIResult( data )
	if( string.len( data ) == 0 ) then return; end
	
	local buffer = Binary.createBuffer( data );
	-- extract data
	local unitID = readInt( buffer );
	local targetID = readInt( buffer );
	local destinationAddress = readVec2i( buffer );
	
	-- interpret data
	local unit = LevelMap.getUnitByID( unitID );
	local target = LevelMap.getUnitByID( targetID );
	local destination = LevelMap.grid.getTile( destinationAddress );
	
	-- should replace this check with something more rigorous
	if( unit == nil or target == nil or destination.getOccupant() ~= nil ) then return nil; end
	if( unit.tile == nil ) then return nil; end
	
	local result = {};
	result.unit = unit;
	result.target = target;
	result.destination = destination;
	return result;
end