-- Map Connection Port
require( "game.map.edge" );
require( "render.geom" );



-- Port
function createPort()
	local port = {};
	port.islands = createList();
	
	function port.addIsland( island )
		port.islands.add( island );
	end
	
	function port.removeIsland( island )
		port.islands.remove( island );
	end
	
	function port.buildModels()
		for i = 1, islands.length() do
			local island = islands.get(i);
			island.buildModel();
		end
	end
	
	return port;
end




-- Island (list of Tile objects)
function createIsland()
	local island = createList();
	island.connections = createList();
	island.originIndex = -1;
	island.map = nil;
	
	
	function island.getOrigin()
		return island.get( island.originIndex );
	end
	
	function island.addTile( tile )
		island.add( tile );
		tile.island = island;
	end
	
	function island.removeTile( tile )
		island.remove( tile );
		tile.island = nil;
	end
	
	function island.addConnection( connection )
		island.connections.add( connection );
	end
	
	function island.removeConnection( connection )
		island.connections.remove( connection );
	end
	
	function island.buildModel()
		local edges = island.findBorder();
		island.model = Geom.createIslandBorder( edges );
		island.model.build();
	end
	
	
	function island.findExternalTile()
		for i = 1, island.length() do
			local tile = island.get(i);
			for j = 1, 6 do
				local neighbor = tile.neighbors[j];
				if( neighbor == nil or neighbor.island ~= island ) then return tile; end
			end
		end
		
		return nil;
	end
	
	function island.findExternalVertex( externalTile )
		if( externalTile == nil ) then return -1; end
		
		for i = 1, 6 do
			local neighbor = externalTile.neighbors[i];
			if( neighbor == nil or neighbor.island ~= island ) then return i; end
		end
		
		return -1;
	end
	
	function island.containsAddress( address )
		for i = 1, island.length() do
			local tile = island.get(i);
			if( tile.address.equals( address ) ) then return true; end
		end
		
		return false;
	end
	
	
	function island.findBorder()
		local edges = createList();
		local externalTile = island.findExternalTile();
		local externalEdge = island.findExternalVertex( externalTile );
		local start = createEdge( externalTile, externalEdge );
		local tile = start.tile;
		edges.add( start );
		
		local n = externalEdge;
		while( true ) do
			local neighbors = tile.neighbors;
			local n1 = neighbors[n+1];
			
			if( n1 == nil or n1.island ~= island ) then
				local e = createEdge( tile, (n+1) % 6 );
				if( edges.contains( e ) ) then break; end
				edges.add( e );
				n = (n+1) % 6;
				goto continue;
			end
			
			tile = n1;
			n = (n+4) % 6;
			::continue::
		end
		
		return edges;
	end
	
	
	return island;
end



-- Connection
function createConnection( islandA, islandB )
	local conn = {};
	conn.islandA = islandA;
	conn.islandB = islandB;
	conn.active = false;
	conn.isLocal = false;
	conn.embed = false;
	conn.rotation = 0;
	conn.embedOffset = Vec2_new( 0, 0 );
	conn.remoteMapName = "";
	conn.remappings = createList();
	
	
	function conn.activate()
		conn.active = true;
		conn.islandA.map.activeConnections.add( conn );
		if( conn.isLocal == false ) then
			conn.islandB.map.activeConnections.add( conn );
		end
		
		for i = 1, conn.islandA.length() do
			local tileA = conn.islandA.get(i);
			
			local coexistB = conn.findCoexistingTile( i, conn.islandA );
			tileA.coexist = coexistB;
			local neighbors = tileA.neighbors;
			for j = 1, 6 do
				local neighborA = neighbors[j];
				if( neighborA == nil or neighborA.exists == false ) then
					local index = (j + 6 - conn.rotation) % 6;
					local neighborB = coexistB.neighbors[index == 0 and 6 or index];
					if( neighborB ~= nil and neighborB.exists ) then
						-- remap
						tileA.neighbors[j] = neighborB;
						
						local edge = createEdge( tileA, j );
						local remap = createEdgeRemap( edge, neighborB );
						conn.remappings.add( remap );
					end
				end
			end
		end
		
		for i = 1, conn.islandB.length() do
			local tileB = conn.islandB.get(i);
			
			local coexistA = conn.findCoexistingTile( i, conn.islandB );
			tileB.coexist = coexistA;
			local neighbors = tileB.neighbors;
			for j = 1, 6 do
				local neighborB = neighbors[j];
				if( neighborB == nil or neighborB.exists == false ) then
					local index = (j + 6 + conn.rotation) % 6;
					local neighborA = coexistA.neighbors[index == 0 and 6 or index];
					if( neighborA ~= nil and neighborA.exists ) then
						-- remap
						tileB.neighbors[j] = neighborA;
						
						local edge = createEdge( tileB, j );
						local remap = createEdgeRemap( edge, neighborA );
						conn.remappings.add( remap );
					end
				end
			end
		end
		
		-- TODO Either block off unmapped edges, or allow for local traversal
	end
	
	
	function conn.deactivate()
		conon.active = false;
		conn.islandA.map.grid.buildNeighborsForTiles( conn.islandA );
		conn.islandB.map.grid.buildNeighborsForTiles( conn.islandB );
		
		for i = 1, conn.islandA.length() do
			local tileA = conn.islandA.get(i);
			local tileB = conn.islandB.get(i);
			tileA.coexist = nil;
			tileB.coexist = nil;
		end
		
		conn.islandA.map.activeConnections.remove( conn );
		if( conn.isLocal == false ) then
			conn.islandB.map.activeConnections.remove( conn );
		end
		
	end
	
	
	function conn.findCoexistingTile( tileIndex, localIsland )
		local reverse = localIsland == conn.islandA;
		local remoteIsland = localIsland == conn.islandA and conn.islandB or conn.islandA;
		
		-- find offset of tile from local island origin tile
		local offset = Vec2_sub( localIsland.get( tileIndex ).address, localIsland.getOrigin().address );
		local rotatedOffset = Vec2_rotate( offset, reverse and ((6 - conn.rotation) % 6) or conn.rotation );
		local remoteAddress = Vec2_add( remoteIsland.getOrigin().address, rotatedOffset );
		local remoteTile = remoteIsland.map.grid.getTile( remoteAddress );
		
		return remoteTile;
	end
	
	
	return conn;
end
