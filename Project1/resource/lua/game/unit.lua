-- character unit
require( "animation.main" );



NEXT_UNIT_ID = 0;
function generateUnitID()
	NEXT_UNIT_ID = NEXT_UNIT_ID + 1;
	return NEXT_UNIT_ID;
end

function createUnit( name, grid )
	local unit = {};
	unit.name = name;
	unit.grid = grid;
	unit.orientation = 1;
	unit.prevOrientation = 0;
	unit.bio = nil;
	unit.profileImages = createList();
	
	-- Animation
	unit.animations = {};
	unit.currentAnimation = nil;
	unit.isMoving = false;
	unit.position = Vec3_new( 0, 0, 0 );
	
	-- util
	unit.team = nil;
	unit.location = Vec2_new( 0, 0 );
	unit.prevLocation = nil;
	unit.tile = nil;
	unit.prevTile = nil;
	unit.moved = false;
	unit.unitID = generateUnitID();
	unit.staticPosition = false;
	unit.ghostTile = nil;
  
	-- inventory
	unit.items = createList();
	unit.weapons = createList();
	unit.maxEquip = 4;
	unit.maxItem = 4;
	unit.desc = "CharacterUnit";
  
	-- stats
	local stat = {};	
	stat.hp = 25;
	stat.maxHP = 25;
	stat.ap = 8.0;
	stat.maxAP = 8.0;
	stat.minAP = 2.5;
	stat.mv = 4;
	stat.itemRange = 4;
	stat.str = 5;
	stat.mag = 5;
	stat.def = 8;
	stat.res = 4;
	stat.vis = 3;
	stat.clk = 2;
	stat.spd = 5;
	stat.eva = 4;
	stat.luck = 8;
	stat.skill = 10;
	stat.rating = 0;
	stat.priorityRank = 0;
	unit.stat = stat;
	local growth = {};
	growth.hp = 0.4;
	growth.str = 0.3;
	growth.mag = 0.4;
	growth.def = 0.5;
	growth.res = 0.3;
	growth.spd = 0.3;
	unit.growth = growth;
  
	-- status
	unit.status = 0;
	unit.ko = false;
	unit.present = true;
  
	-- AI
	unit.ai = {};
--	unit.ai.strategy = createDefaultStrategy();
--	unit.ai.parameters = {};
--	unit.ai.parameters.synergy = 10; -- range[-10,10]
--	unit.ai.parameters.aggressive = 2; -- range[0,10]
--	unit.ai.parameters.unpredictability = 1; -- range[0,10]
--	unit.ai.parameters.violence = 3; -- range[-10,10]
--	unit.ai.unitAffinity = {};
--	unit.ai.noAttack = createList();
  
	-- ranges
	unit.range = {};
	unit.range.move = createList();
	unit.range.attack = createList();
  
	unit.userdata = nil;
	unit.visible = true;
	unit.enabled = true;
	
	-- TODO Leave room for the possibility of allowing a special ability to change this behavior
	function unit.getMovementRange()
		local mv = math.min( unit.stat.mv, unit.stat.ap );
		return math.floor( mv );
	end
	
	function unit.occupiesTile( tile )
		if( unit.tile == tile ) then return true; end
		if( unit.doesCoexist() and unit.tile.coexist == tile ) then return true; end
		return false;
	end
	
	function unit.doesCoexist()
		return unit.tile.coexist ~= nil;
	end
	
	-- ghost
	function unit.setGhostTile( tile )
		unit.ghostTile = tile;
		Unit_setGhostTile( unit.userdata, tile.userdata );
	end
	
	function unit.setGhostVisible( vis )
		Unit_setGhostVisible( unit.userdata, vis );
	end
	
	function unit.hasGhost()
		return unit.ghostTile ~= nil;
	end
	
	function unit.resetGhost()
		unit.ghostTile = nil;
		unit.setGhostVisible( false );
	end
	
	function unit.moveToTile( tile )
		unit.prevTile = unit.tile;
		unit.prevLocation = Vec2_copy( unit.location );
		unit.prevOrientation = unit.orientation;
		unit.tile = tile;
		unit.location = tile.address;
		unit.position = tile.position;
		if( unit.prevTile ~= nil ) then unit.prevTile.occupant = nil; end
		tile.occupant = unit;
	end
	
	-- Animtion functions
	function unit.addAnimation( animation )
		Unit_animate( GameInstance, unit.userdata, 0 );
		unit.animations[animation.state] = animation;
	end
	
	function unit.animate( time )
		Unit_animate( GameInstance, unit.userdata, time );
	end
	
	function unit.setAnimation( state )
		unit.currentAnimation = unit.animations[state];
		Unit_setAnimation( unit.userdata, state );
		unit.animate(0);
	end
	
	function unit.loadModel( filename )
		Unit_loadModel( unit.userdata, filename );
		unit.alignToOrientation();
	end
		
	function unit.rotate( angle )
		Unit_rotate( unit.userdata, angle );
	end
	
	function unit.checkAPStatus()
		if( stat.ap < stat.minAP ) then
			unit.setEnabled( false );
		else
			unit.setEnabled( true );
		end
	end
	
	function unit.setEnabled( enabled )
		if( unit.enabled == enabled ) then return; end
		unit.enabled = enabled;
		Unit_setEnabled( unit.userdata, enabled );
	end
	
	-- Inventory
	function unit.addItem( item )
		unit.items.add( item );
	end
	
	function unit.getItemCalled( itemName )
		for i = 1, unit.items.length() do
			local item = unit.items.get(i);
			if( item.name == itemName ) then
				return item;
			end
		end
		return nil;
	end
	
	
	-- Model and Shader
	function unit.setForwardVector( fv, passOrientation )
		local fv_unit = Vec3_getUnit( fv );
		unit.orientation = unit.grid.getDirectionIndexFromVector( fv_unit );
		Unit_setForwardVector( unit.userdata, fv_unit );
	end
	
	--[[Note: Currently, the winding direction for tile neighbors opposes the direction of
		a positive rotation. This may need to be rectified in the near future.]]
	
	function unit.alignToOrientation()
		local offset = math.pi / 3;
		local angle = (-unit.orientation - 1) * offset;
		local forward = Vec3_new( math.cos( angle ), 0.0, math.sin( angle ) );
		unit.setForwardVector( forward, false );
	end
	
	
	
	function unit.lookAtPoint( p )
		local look = Vec3_sub( p, unit.position );
		unit.setForwardVector( look );
	end
	
	function unit.setTeamColor( color )
		Unit_setTeamColor( unit.userdata, color );
	end
	
	function unit.setShader( shader )
		Unit_setShader( unit.userdata, Shaders.animShader.userdata );
	end
	
	function unit.setRingShader( shader )
		Unit_setRingShader( unit.userdata, shader.userdata );
	end
	
	function unit.setVisible( visible )
		unit.visible = visible;
		Unit_setVisible( unit.userdata, visible );
	end
	
	
	function unit.isAvailable()
		return unit.stat.ap >= unit.stat.minAP and unit.ko == false and unit.present;
	end
	
	function unit.changeHP( amount )
		unit.stat.hp = math.round( unit.stat.hp + amount );
		if( unit.stat.hp <= 0 ) then
			unit.knockOut();
		elseif( unit.stat.hp > unit.stat.maxHP ) then
			unit.stat.hp = unit.stat.maxHP;
		end
	end
	
	function unit.hasLowAP()
		return stat.ap < stat.minAP;
	end
	
	
	function unit.hasLowHP()
		return stat.hp < stat.maxHP / 4;
	end
	
	function unit.hasFullHP()
		return stat.hp == stat.maxHP;
	end
	
	function unit.knockOut()
		unit.hp = 0;
		unit.ko = true;
	end
  
	-- compute current move range based on AP
	function unit.getMoveRange()
		return math.floor( math.min( unit.stat.ap, unit.stat.mv ) );
	end
    
	function unit.canAttack()
		return unit.available() and unit.weapons.length() > 0;
	end
  
  
	function unit.computeRating()
		local rating = 0;
		local s = unit.stat;
		rating = s.hp + s.mv + s.str + s.mag + s.def;
		rating = rating + s.res + s.vis + s.clk + s.spd + s.eva + s.luck;
		rating = rating + s.skill;
		unit.stat.rating = rating;
		return rating;
	end
  
  	unit.computeRating();
  
	function unit.useItem( id )
	    local item = nil;
	    for i = 1, unit.items.length() do
	      local ii = unit.items.get(i);
	      if( ii.id == id ) then
	        item = ii;
	        break;
	      end
		end
    
		item.quantity = item.quantity -1;
		if( item.quantity == 0 ) then
			unit.items.remove( item );
		end
	end
  
	function unit.getItemOfType( itemType )
		for i = 1, unit.items.length() do
			local item = unit.items.get(i);
			if( item.type == itemType ) then
				return item;
			end
		end
		return nil;
	end
  
	function unit.inRangeOfHealer()
		return false;
	end
  
	function unit.canEscapeEnemyRange()
		return false;
	end
  
  -- Most calls to this function will omit the second and third arguments. Doing so implies that the unit and targets should be
  -- considered to occupy the tiles that they are currently occupying.
  function unit.simulateAttack( target, unitTile, targetTile )
    local data = {};
    local wpn = unit.equipped;
    local accuracy = 0;
    
    -- use unitTile (and targetTile) as the location for 'unit' and 'target' if they have been provided
    local tile = unit.tile;
    local tile2 = target.tile;
    if( unitTile ~= nil ) then
      tile = unitTile;
    end
    if( targetTile ~= nil ) then
      tile2 = targetTile;
    end
    
    if( wpn ~= nil ) then
      accuracy = wpn.stat.hit * 100 + 2 * unit.stat.skill + unit.stat.luck;
    else
      accuracy = 2 * unit.stat.skill + unit.stat.luck;
    end
    
    local eva = target.stat.luck;
    -- penalize target unit, if AP is low
    if( target.stat.ap > 0 ) then
      eva = eva + target.stat.skill/2;
    end
    if( target.stat.ap > target.stat.minAP ) then
      eva = eva + 2 * target.computeAttackSpeed() + target.stat.skill/2;
    end
    
    local acc = accuracy - eva;
    if( acc < 0 ) then acc = 0;
    elseif( acc > 100 ) then acc = 100; end
    data.acc = acc;
    
    -- check for critical hit
    local baseCrit = wpn.stat.crit * 100 + (unit.stat.skill+unit.stat.luck)/2.0;
    local dodge = target.stat.luck;
    local critPercent = baseCrit - dodge;
    
    -- compute damage
    local effectiveness = 1; -- used for bonus damage
    local terrainAtkBonus = tile.modifiers.atk;
    local terrainDefBonus = tile2.modifiers.def;
    local baseDamage = unit.stat.str + wpn.stat.atk * effectiveness + terrainAtkBonus;
    local totalDef = target.stat.def + terrainDefBonus;
    data.damage = baseDamage - totalDef;
    data.kill = target.stat.hp <= data.damage;
    
    return data;
  end
  
	-- FUNCTIONS
	function unit.equip( weapon )
		if( weapons.contains( weapon ) ) then
			equipped = weapon;
		end
	end
	
	function unit.changeAP( ap )
		unit.stat.ap = unit.stat.ap + ap;
		if( unit.stat.ap > unit.stat.maxAP ) then
			unit.stat.ap = unit.stat.maxAP;
		end
		unit.checkAPStatus();
	end
	
	function unit.gainHP( hp )
		unit.stat.hp = unit.stat.hp + hp;
		if( unit.stat.hp > unit.stat.maxHP ) then
			unit.stat.hp = unit.stat.maxHP;
		end
	end
	
	function unit.computeAttackSpeed()
		local spd = unit.stat.spd;
		if( unit.equipped ~= nil ) then
			return spd - (unit.equipped.stat.wt - unit.stat.str);
		end
		return spd;
	end
	
	function unit.computeAttackPower()
		if( unit.equipped ~= nil ) then
			return unit.stat.str + unit.equipped.stat.atk;
		end
		return unit.stat.str;
	end
	
	
	-- fileio util
	function unit.writeToBuffer( buffer )
		writeInt( buffer, unit.unitID );
		writeString( buffer, unit.name );
		writeInt( buffer, unit.orientation );

		-- items
		writeInt( buffer, unit.items.length() );
		for j = 1, unit.items.length() do
			local item = unit.items.get(j);
			writeInt( buffer, item.id );
		end

		-- weapons
		writeInt( buffer, unit.weapons.length() );
		for j = 1, unit.weapons.length() do
			local weapon = unit.weapons.get(j);
			writeInt( buffer, weapon.id );
		end
		local equippedID = unit.equipped == nil and 0 or unit.equipped.id;
		writeInt( buffer, equippedID );

		-- stats
		local stat = unit.stat;
		writeInt( buffer, stat.hp );
		writeInt( buffer, stat.maxHP );
		writeFloat( buffer, stat.ap );
		writeFloat( buffer, stat.minAP );
		writeFloat( buffer, stat.maxAP );
		writeInt( buffer, stat.mv );
		writeInt( buffer, stat.str );
		writeInt( buffer, stat.mag );
		writeInt( buffer, stat.def );
		writeInt( buffer, stat.res );
		writeInt( buffer, stat.vis );
		writeInt( buffer, stat.clk );
		writeInt( buffer, stat.spd );
		writeInt( buffer, stat.eva );
		writeInt( buffer, stat.luck );
		writeInt( buffer, stat.skill );
	end
	
	return unit;
end

function createUnitFromData( buffer, grid )
	local unit = createUnit( "AI_controlled", grid );
	unit.unitID = readInt( buffer );
	unit.name = readString( buffer );
	unit.orientation = readInt( buffer );

	-- items
	local numItems = readInt( buffer );
	for j = 1, numItems do
		local itemID = readInt( buffer );
		unit.items.add( Items[itemID] );
	end

	-- weapons
	local numWeapons = readInt( buffer );
	for j = 1, numWeapons do
		local weaponID = readInt( buffer );
		unit.weapons.add( Weapons[weaponID] );
	end
	local equippedID = readInt( buffer );
	unit.equipped = Weapons[equippedID];

	-- stats
	unit.stat.hp = readInt( buffer );
	unit.stat.maxHP = readInt( buffer );
	unit.stat.ap = readFloat( buffer );
	unit.stat.minAP = readFloat( buffer );
	unit.stat.maxAP = readFloat( buffer );
	unit.stat.mv = readInt( buffer );
	unit.stat.str = readInt( buffer );
	unit.stat.mag = readInt( buffer );
	unit.stat.def = readInt( buffer );
	unit.stat.res = readInt( buffer );
	unit.stat.vis = readInt( buffer );
	unit.stat.clk = readInt( buffer );
	unit.stat.spd = readInt( buffer );
	unit.stat.eva = readInt( buffer );
	unit.stat.luck = readInt( buffer );
	unit.stat.skill = readInt( buffer );
	
	return unit;
end

function readUnitFromFile( filename )
	local inp = assert( io.open( filename, "rb" ) );
	local data = inp:read( "*a" );
	assert( inp:close() );
	
	-- read file version and choose appropriate reader
	local maj_ver = string.byte( data, 1 );
	local min_ver = string.byte( data, 2 );
	File_Pos = 3;

	if( maj_ver == 1 ) then
		if( min_ver == 0 ) then
      local unit = parseUnitDataFromBinaryData( data );
			return unit;
		else
      print( 'unit file format unknown: '..tostring( maj_ver )..'.'..tostring( min_ver ) );
			return nil;
		end
	else
		return nil;
	end
end

function parseUnitDataFromBinaryData( buffer )
	local unitID = readInt( buffer );
	local name = readString( buffer );
	local unit = createUnit( name, LevelMap.grid );
	unit.unitID = unitID;
	unit.bio = readString( buffer );
	unit.size = readInt( buffer );
	unit.height = readFloat( buffer );
	
	-- PROFILE IMAGES
	local length = readInt( buffer );
	for i = 1, length do
		local img = createProfileImage();
		img.target = readInt( buffer );
		img.filename = readString( buffer );
		unit.profileImages.add( img );
	end
	
	-- INVENTORY
	-- weapons
	unit.maxEquip = readInt( buffer );
	length = readInt( buffer );
	for i = 1, length do
		local id = readInt( buffer );
		local wpn = Game.createWeapon( id );
		unit.weapons.add( wpn );
		if( i == 1 ) then unit.equipped = wpn; end
	end
	-- items
	unit.maxItem = readInt( buffer );
	length = readInt( buffer );
	for i = 1, length do
		local num = readInt( buffer );
		local item = Items[num].copy();
		unit.items.add( item );
	end
  
	-- BASE STATS
	unit.stat.maxHP = readInt( buffer );
	-- need to put this crap into the editor
	-- manaully do something, for now
	unit.stat.maxHP = 25;
	unit.stat.str = readInt( buffer );
	unit.stat.mag = readInt( buffer );
	unit.stat.def = readInt( buffer );
	unit.stat.res = readInt( buffer );
	unit.stat.spd = readInt( buffer );
	unit.stat.clk = readInt( buffer );
	unit.stat.mv = readInt( buffer );
	unit.stat.eva = readInt( buffer );
	unit.stat.vis = readFloat( buffer );

	-- STAT GROWTH
	unit.growth.hp = readFloat( buffer );
	unit.growth.str = readFloat( buffer );
	unit.growth.mag = readFloat( buffer );
	unit.growth.def = readFloat( buffer );
	unit.growth.res = readFloat( buffer );
	unit.growth.spd = readFloat( buffer );

	-- sprites (may not need)
	-- cycles (probably won't need)
  return unit;
end
