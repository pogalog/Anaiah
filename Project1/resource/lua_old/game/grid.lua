require( "game.vector" );
require( "game.tile" );
require( "game.list" );
require( "game.unit_path" );

-- grid
function createGrid( map, xsize, zsize )
	local grid = {};
	local rows = {};
	grid.map = map;
	grid.size = createVec2( xsize, zsize );
	grid.pathFindTargets = createList();
	for i = 0, zsize-1 do
		rows[i+1] = createRow( i, xsize );
	end
	grid.rows = rows;
	grid.desc = "MapGrid";
	
	
	-- FUNCTIONS
	function grid.setSize( xsize, zsize )
		print( "set size to " .. xsize, zsize );
	end
	
	function grid.placeUnit( unit, i, j )
		local tile = rows[j+1].tiles[i+1];
		tile.occupant = unit;
		unit.tile = tile;
	end
	
	
	function grid.getTileAtAddress( i, j )
		if( j+1 > #grid.rows or j+1 <= 0 ) then return nil; end
		if( i+1 > #grid.rows[j+1].tiles or i+1 <= 0 ) then return nil; end
		return grid.rows[j+1].tiles[i+1];
	end
	
	function grid.getTile( location )
	    local i = location.x+1;
	    local j = location.y+1;
	    if( j > #grid.rows or j <= 0 ) then return nil; end
		if( i > #grid.rows[j].tiles or i <= 0 ) then return nil; end
		return grid.rows[j].tiles[i];
	end
	
	function grid.buildNeighbors()
		for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				-- clear existing neighbors
				tile.neighbors = {};
				local addy = tile.address;
				
				local right = grid.getTileAtAddress( addy.x+1, addy.y );
				local left = grid.getTileAtAddress( addy.x-1, addy.y );
				local upLeft = grid.getTileAtAddress( addy.x, addy.y+1 );
				local downRight = grid.getTileAtAddress( addy.x, addy.y-1 );
				local upRight = grid.getTileAtAddress( addy.x+1, addy.y+1 );
				local downLeft = grid.getTileAtAddress( addy.x-1, addy.y-1 );
				
				-- add neighbors starting from "up_right", work ccw
				tile.addNeighbor( upRight );
				tile.addNeighbor( upLeft );
				tile.addNeighbor( left );
				tile.addNeighbor( downLeft );
				tile.addNeighbor( downRight );
				tile.addNeighbor( right );
			end
		end
	end
	
	function grid.clearMarkings()
		for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				tile.moveID = 1000;
        tile.moveID2 = 1000;
        tile.open = false;
        tile.attack = false;
        tile.attack2 = false;
        tile.attackIndex = 0;
        tile.attackIndex2 = 0;
        tile.attackers.clear();
        tile.attackers2.clear();
			end
		end
	end
  
  -- clear markings from tiles in a list
  function grid.clearTiles( tiles )
    if( tiles == nil ) then return; end
    for i = 1, tiles.length() do
      local tile = tiles.get(i);
      tile.moveID = 1000;
      tile.moveID2 = 1000;
      tile.open = false;
      tile.attack = false;
      tile.attackIndex = 0;
      tile.attackers.clear();
    end
  end
  
  function grid.clearTilesAlt( tiles )
    if( tiles == nil ) then return; end
    for i = 1, tiles.length() do
      local tile = tiles.get(i);
      tile.moveID = 1000;
      tile.moveID2 = 1000;
      tile.open = false;
    end
  end 
  
  
  function grid.clearAttack()
    for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
        tile.attack = false;
        tile.attackIndex = 0;
        tile.attackers.clear();
			end
		end
  end
  
  function grid.clearAttack2()
    for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
        tile.attack2 = false;
        tile.attackIndex2 = 0;
        tile.attackers2.clear();
			end
		end
  end
  
  function grid.clearAttackAll()
    for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
        tile.attack = false;
        tile.attackIndex = 0;
        tile.attackers.clear();
        tile.attack2 = false;
        tile.attackIndex2 = 0;
        tile.attackers2.clear();
			end
		end
  end
  
  function grid.clearAttackWI()
    for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
        tile.attackWI = false;
        tile.attackIndexWI = 0;
        tile.attackersWI.clear();
			end
		end
  end
  
  function grid.clearMarkingsAlt()
		for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				tile.moveID = 1000;
        tile.moveID2 = 1000;
        tile.open = false;
			end
		end
	end
  
	function grid.removeAttackForUnit( unit )
		if( unit.range.attack.length() == 0 ) then return; end
		for i = 1, unit.range.attack.length() do
			local tile = unit.range.attack.get(i);
			tile.attackers.remove( unit );
			tile.attackIndex = tile.attackIndex -1;
			if( tile.attackIndex == 0 ) then
				tile.attack = false;
			end
		end
		unit.range.attack.clear();
	end
  
	function grid.removeAttackForUnit2( unit )
		if( unit.range.attack.length() == 0 ) then return; end
		for i = 1, unit.range.attack.length() do
			local tile = unit.range.attack.get(i);
			tile.attackers2.remove( unit );
			tile.attackIndex2 = tile.attackIndex -1;
			if( tile.attackIndex2 == 0 ) then
				tile.attack2 = false;
			end
		end
		unit.range.attack.clear();
	end
  
  
	function grid.print()
		for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				print( tostring( tile.attackIndex ) );
			end
		end
	end
  
  
	function grid.markInfluence()

	end

	function grid.getTilesWithinRange( unit, distance, ignoreUnits )
		local range = createList();
		local assignment = createList();
		local traversal = createList();
		range.add( unit.tile );
		grid.clearMarkingsAlt();
		if( unit == nil ) then return createList(); end
		if( unit.tile == nil ) then return createList(); end

		-- add unit's tile to traversal
		traversal.add( unit.tile );
		unit.tile.moveID = 0;
		local i = 0;
		while( i <= distance ) do
			for ti, trav in pairs( traversal.data ) do
				for ni, neighbor in pairs( trav.neighbors ) do
					if( neighbor ~= nil ) then
						local newID = trav.moveID + trav.modifiers.mv + 1;
						if( neighbor.moveID > newID and neighbor.isAvailable( ignoreUnits ) ) then
							if( newID <= distance ) then
								neighbor.moveID = newID;
								assignment.add( neighbor );
								if( range.contains( neighbor ) == false ) then
									range.add( neighbor );
									neighbor.open = true;
								end
							end
						end
					end
				end
			end
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
			i = i + 1;
		end
		return range;
	end
  
  -- Like its brother functions, but doesn't assume a unit, and simply takes a tile as a start location.
  function grid.getRange( start, distance, ignoreUnits )
		local range = createList();
		local assignment = createList();
		local traversal = createList();
		range.add( start );
		grid.clearMarkingsAlt();

		-- add unit's tile to traversal
		traversal.add( start );
		start.moveID = 0;
		local i = 0;
		while( i <= distance ) do
			for ti, trav in pairs( traversal.data ) do
				for ni, neighbor in pairs( trav.neighbors ) do
					if( neighbor ~= nil ) then
						local newID = trav.moveID + trav.modifiers.mv + 1;
						if( neighbor.moveID > newID and neighbor.isAvailable( ignoreUnits ) ) then
							if( newID <= distance ) then
								neighbor.moveID = newID;
								assignment.add( neighbor );
								if( range.contains( neighbor ) == false ) then
									range.add( neighbor );
									neighbor.open = true;
								end
							end
						end
					end
				end
			end
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
			i = i + 1;
		end
		return range;
	end
  
  function grid.getTilesWithinRangeAlt( unit, distance, ignoreAlly )
		local range = createList();
		local assignment = createList();
		local traversal = createList();
		range.add( unit.tile );
		grid.clearMarkings();

		-- add unit's tile to traversal
		traversal.add( unit.tile );
		unit.tile.moveID = 0;
		local i = 0;
		while( i <= distance ) do
			for ti, trav in pairs( traversal.data ) do
				for ni, neighbor in pairs( trav.neighbors ) do
					if( neighbor ~= nil ) then
						local newID = trav.moveID + trav.modifiers.mv + 1;
						if( neighbor.moveID > newID and neighbor.isAvailable( ignoreAlly, unit.team ) ) then
							if( newID <= distance ) then
								neighbor.moveID = newID;
								assignment.add( neighbor );
								if( range.contains( neighbor ) == false ) then
									range.add( neighbor );
									neighbor.open = true;
								end
							end
						end
					end
				end
			end
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
			i = i + 1;
		end
		return range;
	end
  
  function grid.getTilesWithinRange2( unit, distance, ignoreUnits )
		local range = createList();
		local assignment = createList();
		local traversal = createList();
		range.add( unit.tile );

		-- add unit's tile to traversal
		traversal.add( unit.tile );
		unit.tile.moveID2 = 0;
		local i = 0;
		while( i <= distance ) do
			for ti, trav in pairs( traversal.data ) do
				for ni, neighbor in pairs( trav.neighbors ) do
					if( neighbor ~= nil ) then
						local newID = trav.moveID2 + trav.modifiers.mv + 1;
						if( neighbor.moveID > newID and neighbor.isAvailable( ignoreUnits ) ) then
							if( newID <= distance ) then
								neighbor.moveID2 = newID;
								assignment.add( neighbor );
								if( range.contains( neighbor ) == false ) then
									range.add( neighbor );
								end
							end
						end
					end
				end
			end
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
			i = i + 1;
		end
		return range;
	end
  
  function grid.checkTile( tile )
    local addy = tile.address;
    if( addy.x < 0 ) then print( 'oob:'..addy.toString() ); end
    if( addy.y < 0 ) then print( 'oob:'..addy.toString() ); end
    if( addy.x >= grid.size.x ) then print( 'oob:'..addy.toString()..' : '..grid.size.toString() ); end
    if( addy.y >= grid.size.y ) then print( 'oob:'..addy.toString()..' : '..grid.size.toString() ); end
  end
  
  --[[ Can be used by the player or AI processes.
   Marks all tiles which can be attacked by 'team' by
   setting tile.attack = true, and incrementing the
   tile.attackIndex each time a unit can reach the tile.
  ]]
  function grid.markAttackForTeam( team )
    for i = 1, team.units.length() do
      local unit = team.units.get(i);
      -- need to estimate the unit move range rather than using max
      local atkRange = grid.getAttackRange( unit, unit.stat.mv );
      unit.range.attack = atkRange;
      for j = 1, atkRange.length() do
        local tile = atkRange.get(j);
        tile.attack = true;
        tile.attackIndex = tile.attackIndex + 1;
        tile.attackers.add( unit );
        
        -- clean up a bit
        tile.moveID = 1000;
        tile.moveID2 = 1000;
        tile.open = false;
      end
    end
  end
  
  function grid.markAttackForTeam2( team )
    for i = 1, team.units.length() do
      local unit = team.units.get(i);
      -- need to estimate the unit move range rather than using max
      local atkRange = grid.getAttackRange( unit, unit.stat.mv );
      unit.range.attack = atkRange;
      for j = 1, atkRange.length() do
        local tile = atkRange.get(j);
        tile.attack2 = true;
        tile.attackIndex2 = tile.attackIndex2 + 1;
        tile.attackers2.add( unit );
        
        -- clean up a bit
        tile.moveID = 1000;
        tile.moveID2 = 1000;
        tile.open = false;
      end
    end
  end
  
  function grid.markAttackForTeamWI( team, deadUnit )
    deadUnit.tile.occupant = nil;
    for i = 1, team.units.length() do
      local unit = team.units.get(i);
      if( unit ~= deadUnit ) then
        -- need to estimate the unit move range rather than using max
        local atkRange = grid.getAttackRange( unit, unit.stat.mv );
        unit.range.attack = atkRange;
        for j = 1, atkRange.length() do
          local tile = atkRange.get(j);
          tile.attackWI = true;
          tile.attackIndexWI = tile.attackIndexWI + 1;
          tile.attackersWI.add( unit );
          
          -- clean up a bit
          tile.moveID = 1000;
          tile.moveID2 = 1000;
          tile.open = false;
        end
      end
    end
    deadUnit.tile.occupant = deadUnit;
  end
  
  function grid.markAttackForUnitsWI( units, displacedUnit, newTile )
    if( newTile.occupant ~= nil ) then return; end
    local oldTile = displacedUnit.tile;
    newTile.occupant = displacedUnit;
    oldTile.occupant = nil;
    displacedUnit.tile = newTile;
    
    for i = 1, units.length() do
      local unit = units.get(i);
      -- need to estimate the unit move range rather than using max
      local atkRange = grid.getAttackRange( unit, unit.stat.mv );
      unit.range.attack = atkRange;
      for j = 1, atkRange.length() do
        local tile = atkRange.get(j);
        tile.attackWI = true;
        tile.attackIndexWI = tile.attackIndexWI + 1;
        tile.attackersWI.add( unit );
        
        -- clean up a bit
        tile.moveID = 1000;
        tile.moveID2 = 1000;
        tile.open = false;
      end
    end
    
    -- move the displaced unit back
    displacedUnit.tile.occupant = nil;
    displacedUnit.tile = oldTile;
    oldTile.occupant = displacedUnit;
  end
  
  --[[ Analyze the local flow in order to identify choke points.
    This function is intended for AI use.
  ]]
  function grid.analyzeLocalFlow( group1, group2 )
    grid.pathFindTargets.clear();
    grid.clearCustomFlowMarkings();
    local g1Tiles = createList();
    local g2Tiles = createList();
    -- collect group1 tiles
    for i = 1, group1.length() do
      local tile = group1.get(i).tile;
      -- default spread radius is 4 tiles
      local spreadRadius = 4;
      if( tile.occupant ~= nil ) then
        spreadRadius = tile.occupant.stat.mv / 2;
      end
      local range = grid.getRange( tile, spreadRadius, false );
      for j = 1, range.length() do
        g1Tiles.addUnique( range.get(j) );
      end
    end
    
    -- collect group2 tiles
    for i = 1, group2.length() do
      local tile = group2.get(i).tile;
      local spreadRadius = 4;
      if( tile.occupant ~= nil ) then
        spreadRadius = tile.occupant.stat.mv / 2;
      end
      local range = grid.getRange( tile, spreadRadius, false );
      for j = 1, range.length() do
        g2Tiles.addUnique( range.get(j) );
      end
    end
    
    -- trace paths (default is to trace 20 times to average out randomness)
    local num = 20;
    for i = 1, g1Tiles.length() do
      local tile = g1Tiles.get(i);
      grid.pathFindTargets.add( tile );
      grid.findPath();
      for j = 1, num do
        grid.markLocalPath( g1Tiles, g2Tiles );
      end
      grid.clearPathFinding();
    end
    
    for i = 1, g2Tiles.length() do
      local tile = g2Tiles.get(i);
      grid.pathFindTargets.add( tile );
      grid.findPath();
      for j = 1, num do
        grid.markLocalPath( g2Tiles, g1Tiles );
      end
      grid.clearPathFinding();
    end
    
  end
  
  function grid.markLocalPath( finals, initials )
    for i = 1, initials.length() do
      local tile = initials.get(i);
      if( finals.contains( tile ) ) then goto continue; end
      if( tile.exists == false ) then goto continue; end
      
      local nextTile = tile.bestTile;
      if( tile.bestTile2 ~= nil ) then
        local rando = (math.random( 1, 10 ) > 5);
        if( rando ) then nextTile = tile.bestTile2; end
      end
      
      while finals.contains( nextTile ) == false and nextTile ~= nil do
        nextTile.localFlowIndex = nextTile.localFlowIndex + 1;
        local n = nextTile.bestTile;
        if( nextTile.bestTile2 ~= nil ) then
          local rando = (math.random( 1, 10 ) > 5);
          if( rando ) then n = nextTile.bestTile2; end
        end
        nextTile = n;
      end
      
      ::continue::
    end
    
  end
  
  function grid.clearCustomFlowMarkings()
    for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
        tile.pathValCost = 1000;
        tile.pathValDir = -1;
        tile.bestTile = nil;
        tile.bestTile2 = nil;
        tile.localFlowIndex = 0;
      end
    end
    
  end
	
	-- used both by players and AI processes
	-- returns a list containing all tiles which 'unit' can attack
	function grid.getAttackRange( unit )
		local moveRange = unit.moveRange;
		
		if( moveRange == nil ) then
			moveRange = grid.getTilesWithinRange( unit, unit.getMovementRange(), false );
		elseif( type( moveRange ) == "number" ) then
			moveRange = grid.getTilesWithinRange( unit, moveRange, false );
		end
		
		local atkRange = createList();
		local shape = grid.generateAttackShape( unit );
		
		for i = 1, moveRange.length() do
			local tile = moveRange.get(i);
			for j = 1, shape.length() do
				local localAddress = shape.get(j).address;
				local center = tile.address;
				local realAddress = createVec2( localAddress.x+center.x, localAddress.y+center.y );
				local atkTile = grid.getTileAtAddress( realAddress.x, realAddress.y );
				if( atkTile ~= nil and atkTile.exists and atkRange.contains( atkTile ) == false ) then
					atkRange.add( atkTile );
				end
			end
		end
		return atkRange;
	end
	
	
	-- get attack range for a unit at a single location
	function grid.getSingleAttackRange( unit, tile )
		local atkRange = createList();
		local shape = grid.generateAttackShape( unit );
		
		for j = 1, shape.length() do
			local localAddress = shape.get(j).address;
			local center = tile.address;
			local realAddress = createVec2( localAddress.x+center.x, localAddress.y+center.y );
			local atkTile = grid.getTileAtAddress( realAddress.x, realAddress.y );
			if( atkTile ~= nil and atkTile.exists and atkRange.contains( atkTile ) == false ) then
				atkRange.add( atkTile );
			end
		end
		return atkRange;
	end
	
	
	function grid.getItemRange( unit, tile )
		return grid.getRange( tile, unit.stat.itemRange, true );
	end
	
  
  function grid.getAttackPlacement( unit, targetTile )
    -- get the unit's move range, if we don't already have it
    if( unit.range.move == nil or unit.range.move.length() == 0 ) then
      unit.range.move = grid.getTilesWithinRange( unit, unit.getMoveRange(), false );
      grid.clearTilesAlt( range );
    end
    
    local range = createList();
		local assignment = createList();
		local traversal = createList();
    local min = unit.equipped.range.low;
    local max = unit.equipped.range.high;

		-- add unit's tile to traversal
		traversal.add( targetTile );
		targetTile.moveID = 0;
		local i = 1;
		while( i <= max ) do
			for ti, trav in pairs( traversal.data ) do
				for ni, neighbor in pairs( trav.neighbors ) do
					if( neighbor ~= nil ) then
						local newID = trav.moveID + 1;
						if( neighbor.moveID > newID and neighbor.isAvailable( false ) ) then
							if( newID <= max ) then
								neighbor.moveID = newID;
								assignment.add( neighbor );
								if( newID >= min and range.contains( neighbor ) == false and unit.range.move.contains( neighbor ) ) then
									range.add( neighbor );
									neighbor.open = true;
								end
							end
						end
					end
				end
			end
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
			i = i + 1;
		end
    grid.clearMarkingsAlt();
    
    return range;
    
  end
  
  -- subroutine called by getAttackRange() which creates a list of tiles
  -- that represent the shape of a unit's standing attack range; addresses
  -- are relative to (0,0)
	function grid.generateAttackShape( unit )
		local shape = createList();
		if( unit.equipped == nil ) then return shape; end
		for i = unit.equipped.range.low, unit.equipped.range.high do
			local included = unit.equipped.range.withinRangeInclusive( i );
      
			-- top-left corner
			local t0 = createTile( 0, i );
			t0.exists = included;
			shape.add( t0 );

			-- sweep +n (x): top
			for j = 1, i do
				local top = createTile( j, i );
				top.exists = included;
				shape.add( top );
			end

			-- sweep -n (y): top-right
			for j = 0, i-1 do
				local topRight = createTile( i, j );
				topRight.exists = included;
				shape.add( topRight );
			end

			-- sweep -n (x,y): bottom-right
			for j = 1, i do
				local bottomRight = createTile( i-j, -j );
				bottomRight.exists = included;
				shape.add( bottomRight );
			end

			-- sweep -n (x): bottom
			for j = 1, i do
				local bottom = createTile( -j, -i );
				bottom.exists = included;
				shape.add( bottom );
			end

			-- sweep +n (y): bottom-left
			for j = 1, i do
				local bottomLeft = createTile( -i, j-i );
				bottomLeft.exists = included;
				shape.add( bottomLeft );
			end

			-- sweep +n (x,y): top-left
			for j = 1, i-1 do
				local topLeft = createTile( j-i, j );
				topLeft.exists = included;
				shape.add( topLeft );
			end
		end
		return shape;
	end

	function grid.clearPFMarkings()
		for k, row in pairs( grid.rows ) do
			for k1, tile in pairs( row.tiles ) do
				tile.pathValCost = 1000;
				tile.pathValDir = -1;
				tile.bestTile = nil;
			end
		end
	end
  
	function grid.addPathFindingTarget( target )
		grid.pathFindTargets.add( target );
	end

	function grid.clearPathFinding()
		grid.clearPFMarkings();
		grid.pathFindTargets.clear();
	end
  
	function grid.getPathForUnit( unit, truncate )
		local limit = truncate == true and unit.getMovementRange() or 999;
		
		-- start at unit, step toward goal and add tiles to a list
		local path = createPath();
		local tile = unit.tile;
		while( tile.bestTile ~= nil ) do
			limit = limit - 1;
			path.addTile( tile );
			tile = tile.bestTile;
			if( limit == 0 ) then
				break;
			end
		end
		path.addTile( tile );
		path.length = path.vpath.length();
		if( path.length == 1 ) then
			path.complete = false;
		end
		
		return path;
	end
	
  
	function grid.findPath()
		local traversal = createList();
		local assignment = createList();
		grid.clearPFMarkings();
		for i = 1, grid.pathFindTargets.length() do
			local target = grid.pathFindTargets.get(i);
			traversal.add( target );
			target.pathValCost = 0;
			target.goal = target;
		end
		
		local count = 0;
		while( traversal.length() > 0 ) do
			for i = 1, traversal.length() do
				local tile = traversal.get(i);
				for j = 0, 5 do
					local neighbor = tile.neighbors[j+1];
					if( neighbor ~= nil and neighbor.isPathable() ) then
						local neighborCost = neighbor.pathValCost;
						local myCost = tile.pathValCost;
						local mvPenalty = neighbor.modifiers.mv;
						local dir = j;
						local undir = (dir + 3) % 6;
						
						-- uncontested conversion
						if( neighborCost > myCost + mvPenalty + 1 ) then
							-- point neighbor to "me"
							neighbor.pathValCost = myCost + mvPenalty + 1;
							neighbor.pathValDir = undir;
							neighbor.bestTile = tile;
							neighbor.bestTile2 = nil;
							neighbor.goal = tile.goal;
						    -- may need to change this to check for a team
						    if( neighbor.occupant == nil ) then
							  	assignment.add( neighbor );
						    end
							
							goto cont;
						end
						
						-- compare distance to goal
						-- NOTE: I have made a change keeps both paths in the case of equal cost paths for use in flow analysis.
						if( (neighborCost == myCost + mvPenalty + 1) and (neighbor.pathValDir ~= undir) ) then
							if( neighbor.bestTile == nil ) then
								neighbor.bestTile = tile;
								neighbor.pathValDir = undir;
								neighbor.goal = tile.goal;
								-- may need to change this to check for a team
								if( neighbor.occupant == nil ) then
									assignment.add( neighbor );
								end
							end
							local otherDist = neighbor.goal.address.hexDistanceTo( neighbor.bestTile.address );
							local myDist = tile.address.hexDistanceTo( tile.goal.address );
							if( myDist < otherDist ) then
								neighbor.pathValDir = undir;
								neighbor.bestTile = tile;
								neighbor.goal = tile.goal;
								assignment.add( neighbor );
								goto cont;
							end
						end
					end
					::cont::
				end
			end
			-- add more stuff to traversal
			traversal.clear();
			traversal.addList( assignment );
			assignment.clear();
      
			count = count + 1;
		end
	end
  
	function grid.getLargestRowSize()
		local largest = 0;
		for i = 1, #grid.rows do
			if( #row.tiles > largest ) then
				largest = #row.tiles;
			end
		end
		return largest;
	end

	function grid.getAddressThatContainsPoint( pos )
		local w = TILE_WIDTH;
		local R = TILE_RADIUS;
		local i = math.floor( pos.x/w - pos.z/(3.0*R) + w/4.0 );
		local j = math.floor( -2.0*pos.z/(3.0*R) + w/4.0 );
		return createVec2( i, j );
	end

	grid.buildNeighbors();
	return grid;
end



-- row
function createRow( zAddress, size )
	local row = {};
	local tiles = {};
	for i = 0, size-1 do
		tiles[i+1] = createTile( i, zAddress );
	end
	row.tiles = tiles;

	-- FUNCTIONS
	function row.getTile( index )
		return row.tiles[index];
	end

	return row;
end
