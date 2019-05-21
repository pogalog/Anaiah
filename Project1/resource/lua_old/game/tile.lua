-- tile
TILE_WIDTH = math.sqrt(3);
TILE_RADIUS = 1.0;

function createTile( x, y )
	local tile = {};
	tile.address = createVec2( x, y );
	tile.name = "Unloved Tile";
	tile.description = "Thingbutt";
	tile.occupant = nil;
	tile.desc = "MapTile";
	tile.height = 0;
	local neighbors = {};
	tile.neighborIndex = 1;
	for i = 1, 6 do
		neighbors[i] = nil;
	end
	tile.neighbors = neighbors;
	tile.position = createVec3( 0, 0, 0 );
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
	field.influence = createVec3();
	field.threat = createVec3();
	field.taperedThreat = createVec3();
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
	function tile.getDistanceToTile( otherTile )
		local distX = math.abs( tile.address.x - otherTile.address.x );
		local distY = math.abs( tile.address.y - otherTile.address.y );
		return math.max( distX, distY );
	end

	function tile.isAvailable( ignoreUnits )
		return tile.wall == false and tile.occupiable and tile.exists and (tile.occupant == nil or ignoreUnits);
	end
	
	function tile.isAvailableIgnoreUnit( unit )
		return tile.wall == false and tile.occupiable and tile.exists and (tile.occupant == nil or tile.occupant == unit);
	end
	
	function tile.isAvailableToTeam( ignoreAlly, team )
		return tile.wall == false and tile.occupiable and tile.exists and (tile.occupant == nil or (ignoreAlly and tile.occupant.team == team));
	end
	
	function tile.isPathable()
		return tile.wall == false and tile.occupiable and tile.exists;
	end

	function tile.toString() return tile.name .. ": " .. tile.address.toString(); end

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
		local occupantID = tile.occupant == nil and 0 or tile.occupant.unitID;
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



function createTileFromData( data, i, j )
	local tile = createTile( i, j );
	tile.occupantID = readInt( data );
	tile.height = readFloat( data );
	tile.modifiers.mv = readInt( data );
	tile.modifiers.atk = readInt( data );
	tile.modifiers.def = readInt( data );
	tile.modifiers.fire = readInt( data );
	tile.modifiers.ice = readInt( data );
	tile.modifiers.lightning = readInt( data );
	tile.modifiers.vis = readFloat( data );
	tile.modifiers.amb = readFloat( data );
	tile.visible = readBool( data );
	tile.exists = readBool( data );
	tile.occupiable = readBool( data );
	tile.all = readBool( data );
	return tile;
end

