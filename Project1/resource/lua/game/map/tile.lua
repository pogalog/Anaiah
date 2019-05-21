-- tile
TILE_WIDTH = math.sqrt(3);
TILE_RADIUS = 1.0;

function createTile( x, y )
	local tile = {};
	tile.address = Vec2_new( x, y );
	tile.name = "Unloved Tile";
	tile.description = "Thingbutt";
	tile.occupant = nil;
	tile.desc = "MapTile";
	tile.height = 0;
	tile.island = nil;
	
	local neighbors = {};
	tile.neighborIndex = 1;
	for i = 1, 6 do
		neighbors[i] = nil;
	end
	tile.neighbors = neighbors;
	tile.position = Vec3_new( 0, 0, 0 );
	tile.position.x = TILE_WIDTH * (tile.address.x - tile.address.y/2.0);
	tile.position.y = 0.0;
	tile.position.z = -1.5 * TILE_RADIUS * tile.address.y;
	
	function tile.print()
		print( "Tile: (" .. tile.address.x .. ', ' .. tile.address.y .. ') : ' .. tile.pathValDir );
	end
	
	-- modifiers
	local modifiers = {};
	modifiers.mv = 0;
	modifiers.atk = 0;
	modifiers.def = 0;
	modifiers.fire = 0;
	modifiers.ice = 0;
	modifiers.lightning = 0;
	modifiers.vis = 0;
	modifiers.amb = 0;
	tile.modifiers = modifiers;
	
	-- field values (AI use)
	local field = {};
	field.influence = Vec3_new();
	field.threat = Vec3_new();
	field.taperedThreat = Vec3_new();
	tile.field = field;
	
	-- bool properties
	tile.visible = true;
	tile.exists = true;
	tile.occupiable = true;
	tile.wall = false;
	
	-- model
	tile.wireModel = nil;
	tile.solidModel = nil;

	-- path finding and range marking tools
	tile.moveID = 1000;
	tile.moveID2 = 1000;
  	tile.open = false;
	tile.pathValDir = -1;
	tile.pathValCost = 1000;
  	tile.mapFlowIndex = 0;
	tile.localFlowIndex = 0;
	tile.bestTile = nil;
	tile.bestTile2 = nil;
	tile.goal = nil;
	-- attack data used to denote enemy attack ranges
	-- attack2 data used for ally attack ranges
	-- attackWI data used for a possible scneario where enemy attack ranges might change ("what if")
	tile.attack = false;
	tile.attack2 = false;
	tile.attackWI = false;
	tile.attackIndex = 0;
	tile.attackIndex2 = 0;
	tile.attackIndexWI = 0;
	tile.attackers = createList();
	tile.attackers2 = createList();
	tile.attackersWI = createList();

	-- FUNCTIONS
	function tile.isNeighbor( other )
		for i = 1, 6 do
			if( other == tile.neighbors[i] ) then
				return true;
			end
		end
		return false;
	end
	
	function tile.hasOccupant()
		if( tile.occupant ~= nil ) then return true; end
		if( tile.coexists() ) then
			local ct = tile.coexist;
			if( ct.occupant ~= nil ) then return true; end
		end
		return false;
	end
	
	function tile.getOccupant()
		if( tile.occupant ~= nil ) then return tile.occupant; end
		if( tile.coexists() ) then
			local ct = tile.coexist;
			if( ct.occupant ~= nil ) then return ct.occupant; end
		end
		return nil;
	end
	
	function tile.coexists()
		return tile.coexist ~= nil;
	end
	
	function tile.getDistanceToTile( otherTile )
		local distX = math.abs( tile.address.x - otherTile.address.x );
		local distY = math.abs( tile.address.y - otherTile.address.y );
		return math.max( distX, distY );
	end

	function tile.isAvailable( ignoreUnits )
		if( tile.coexists() ) then
			local ct = tile.coexist;
			return tile.wall == false and tile.occupiable and tile.exists and (tile.getOccupant() == nil or ignoreUnits) and
				   ct.wall == false and ct.occupiable and ct.exists and (ct.getOccupant() == nil or ignoreUnits);
		end
		return tile.wall == false and tile.occupiable and tile.exists and (tile.getOccupant() == nil or ignoreUnits);
	end
	
	function tile.isAvailableIgnoreUnit( unit )
		return tile.wall == false and tile.occupiable and tile.exists and (tile.getOccupant() == nil or tile.getOccupant() == unit);
	end
	
	function tile.isAvailableToTeam( ignoreAlly, team )
		return tile.wall == false and tile.occupiable and tile.exists and (tile.getOccupant() == nil or (ignoreAlly and tile.getOccupant().team == team));
	end
	
	function tile.isPathable()
		return tile.wall == false and tile.occupiable and tile.exists;
	end

	function tile.tostring() return tile.name .. ": " .. tile.address.tostring(); end

	function tile.addNeighbor( neighbor )
		tile.neighbors[tile.neighborIndex] = neighbor;
    tile.neighborIndex = tile.neighborIndex + 1;
	end
  
	function tile.getDirectionToNeighbor( neighbor )
		for i = 1, 6 do
			if( tile.neighbors[i] == neighbor ) then
				return i-1;
			end
		end
		return 0;
	end
	
	-- fileio util
	function tile.writeToBuffer( buffer )
		local mod = tile.modifiers;
		local occupantID = tile.getOccupant() == nil and 0 or tile.getOccupant().unitID;
		writeInt( buffer, occupantID );
		writeFloat( buffer, tile.height );
		writeInt( buffer, mod.mv );
		writeInt( buffer, mod.atk );
		writeInt( buffer, mod.def );
		writeInt( buffer, mod.fire );
		writeInt( buffer, mod.ice );
		writeInt( buffer, mod.lightning );
		writeFloat( buffer, mod.vis );
		writeFloat( buffer, mod.amb );
		writeBool( buffer, tile.visible );
		writeBool( buffer, tile.exists );
		writeBool( buffer, tile.occupiable );
		writeBool( buffer, tile.wall );
	end
	
	return tile;
end



function createTileFromData( buffer, i, j )
	local tile = createTile( i, j );
	tile.occupantID = readInt( buffer );
	tile.height = readFloat( buffer );
	tile.modifiers.mv = readInt( buffer );
	tile.modifiers.atk = readInt( buffer );
	tile.modifiers.def = readInt( buffer );
	tile.modifiers.fire = readInt( buffer );
	tile.modifiers.ice = readInt( buffer );
	tile.modifiers.lightning = readInt( buffer );
	tile.modifiers.vis = readFloat( buffer );
	tile.modifiers.amb = readFloat( buffer );
	tile.visible = readBool( buffer );
	tile.exists = readBool( buffer );
	tile.occupiable = readBool( buffer );
	tile.all = readBool( buffer );
	return tile;
end

