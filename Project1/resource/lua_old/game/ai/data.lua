-- Data Packing for AI
-- (game.ai.data)
require( "game.fileioutil" );

function packAIData( teamID )
	local buffer = {};
	buffer.data = "";
	io_reset();
	
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
	
	finalizeBuffer( buffer );
	return string.len( buffer.data ), buffer.data;
end


function interpretAIData( data )
	if( string.len( data ) == 0 ) then
		print( "EMPTY!" );
		return;
	end
	
	io_reset();
	
	-- AI team id
	local activeTeamID = readInt( data );
	
	-- units/teams
	_G.Teams = createList();
	_G.Units = {};
	local numTeams = readInt( data );
	for i = 1, numTeams do
		local team = createTeam( "AI_team" );
		team.aiControlled = readBool( data );
		local numUnits = readInt( data );
		for j = 1, numUnits do
			local unit = createUnitFromData( data );
			team.addUnit( unit );
			Units[unit.unitID] = unit;
		end
		Teams.add( team );
	end
	
	_G.ActiveTeam = Teams.get( activeTeamID );
	
	-- the grid
	local numRows = readInt( data );
	local numCols = readInt( data );
	local map = createLevelMap( "AI_map", nil, numCols, numRows );
	for i = 1, numRows do
		for j = 1, numCols do
			local tile = createTileFromData( data, j-1, i-1 );
			map.grid.rows[i].tiles[j] = tile;
			if( tile.occupantID > 0 ) then
				tile.occupant = Units[tile.occupantID];
				tile.occupant.tile = tile;
			end
		end
	end
	map.grid.buildNeighbors();
	
	return map;
end



function packAIResult( result )
	local buffer = createBuffer();
	writeInt( buffer, result.unit.unitID );
	writeInt( buffer, result.target.unitID );
	writeVec2i( buffer, result.destination.address );
	finalizeBuffer( buffer );
	return buffer.data;
end


function interpretAIResult( data )
	if( string.len( data ) == 0 ) then return; end
	
	io_reset();
	-- extract data
	local unitID = readInt( data );
	local targetID = readInt( data );
	local destinationAddress = readVec2i( data );
	
	-- interpret data
	local unit = LevelMap.getUnitByID( unitID );
	local target = LevelMap.getUnitByID( targetID );
	local destination = LevelMap.grid.getTile( destinationAddress );
	
	-- should replace this check with something more rigorous
	if( unit == nil or target == nil or destination.occpant ~= nil ) then return nil; end
	if( unit.tile == nil ) then return nil; end
	
	local result = {};
	result.unit = unit;
	result.target = target;
	result.destination = destination;
	return result;
end

