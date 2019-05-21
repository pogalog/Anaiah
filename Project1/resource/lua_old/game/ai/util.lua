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
		if( tile.occupant ~= nil and tile.occupant.team ~= unit.team and tile.occupant.ko == false ) then
			target = tile.occupant;
		end
	end
	
	return target;
end


function findFooting( unit, target )
	-- shouldn't use false for ignoreUnits, or something like that...
	local tiles = LevelMap.grid.getTilesWithinRange( target, unit.equipped.range.high, true );
	for i = 1, tiles.length() do
		local tile = tiles.get(i);
		
		-- isAvailable is not good here, because it will ignore a tile with the 'unit' on it, and it shouldn't
		if( tile.isAvailableIgnoreUnit( unit ) == false ) then goto cont; end
		LevelMap.grid.pathFindTargets.clear();
		LevelMap.grid.addPathFindingTarget( tile );
		LevelMap.grid.findPath();
		local path = LevelMap.grid.getPathForUnit( unit );
		if( path.path.length() <= unit.getMovementRange()+1 and isRouteValid( path.path, tile ) ) then
			return tile;
		end
		
		::cont::
	end
	
	return nil;
end

-- start at the second tile in the path, because the first one is the starting point (occupied)
function isRouteValid( path, destination )
	local hasDest = false;
	for i = 2, path.length() do
		local tile = path.get(i);
		if( tile.occupant ~= nil ) then
			return false;
		end
		if( tile == destination ) then
			hasDest = true;
		end
	end

	return hasDest;
end