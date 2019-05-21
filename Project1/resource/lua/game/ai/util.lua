-- AI Utility

function chooseActionUnit( team )
	local actionUnit = nil;
	for i = 1, team.units.length() do
		local unit = team.units.get(i);
		if( unit.isAvailable() ) then
			actionUnit = unit;
			break;
		end
	end
	
	return actionUnit;
end


function chooseTarget( unit )
	local target = nil;
	local atkRange = LevelMap.grid.getAttackRange( unit );
	for i = 1, atkRange.length() do
		local tile = atkRange.get(i);
		local occupant = tile.getOccupant();
		
		if( occupant ~= nil and occupant.team ~= unit.team and occupant.ko == false ) then
			target = tile.occupant;
		end
	end
	
	return target;
end


function findFooting( unit, target )
	print( "Target at " .. Vec2_tostring( target.tile.address ) );
	print( "Unit at " .. Vec2_tostring( unit.tile.address ) );
	-- shouldn't use false for ignoreUnits, or something like that...
	local tiles = LevelMap.grid.getTilesWithinRange( target, unit.equipped.range.high, true );
	for i = 1, tiles.length() do
		local tile = tiles.get(i);
		
		-- isAvailable is not good here, because it will ignore a tile with the 'unit' on it, and it shouldn't
		if( tile.isAvailableIgnoreUnit( unit ) == false ) then goto cont; end
		
		LevelMap.grid.pathFindTargets.clear();
		LevelMap.grid.addPathFindingTarget( tile );
		print( "Pathing to target: " .. Vec2_tostring( tile.address ) );
		LevelMap.grid.findPath();
		testPF();
		local path = LevelMap.grid.getPathForUnit( unit );
		print( "LEN: " .. path.path.length() .. " and " .. (unit.getMovementRange()+1) );
		if( path.path.length() <= unit.getMovementRange()+1 and isRouteValid( path.path, tile ) ) then
			print( "FOUND SOMETHING!!!" );
			return tile;
		end
		print( "NO GO!!" );
		::cont::
	end
	
	return nil;
end

function testPF()
	for i = 1, #LevelMap.grid.rows do
		local row = LevelMap.grid.rows[i];
		for j = 1, #row.tiles do
			local tile = row.tiles[j];
			if( tile.bestTile == nil and tile.exists ) then
				print( Vec2_tostring( tile.address ) .. " does not have a besty!" );
			end
		end
	end
end

-- start at the second tile in the path, because the first one is the starting point (occupied)
function isRouteValid( path, destination )
	print( "CHECKING ROUTE" );
	local hasDest = false;
	for i = 2, path.length() do
		local tile = path.get(i);
		print( Vec2_tostring( tile.address ) );
		if( tile.getOccupant() ~= nil ) then
			print( "SOMEONE IN THE WAY AT " .. Vec2_tostring( tile.address ) );
			return false;
		end
		if( tile == destination ) then
			hasDest = true;
		end
	end
	print( "" );

	return hasDest;
end