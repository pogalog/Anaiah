-- Inventory Item

-- item types
ITEM_HEALING = 0;
ITEM_RECOVERY = 1;
ITEM_BUFF = 2;
ITEM_DEBUFF = 3;
ITEM_STAT = 4;
ITEM_TREASURE = 5;

function createItem( id, itemType, name )
	local item = {};
	item.id = id;
	item.type = itemType;
	item.name = name;
	item.description = nil;
	item.maxStack = 3;
	item.quantity = item.maxStack;
	item.use = nil;
	item.script = nil;
	
	function item.copy()
		local cp = createItem( item.id );
		cp.name = item.name;
		cp.description = item.description;
		cp.maxStack = item.maxStack;
		cp.quantity = item.quantity;
		cp.func = item.func;
		cp.script = item.script;
		cp.type = item.type;

		return cp;
	end
	
	-- Must be overidden!
	function item.use( unit, target ) end
	
	return item;
end

function fileExists( file )
  local f = io.open( file, "rb" );
  if( f ) then f:close(); end
  return f ~= nil;
end


function linesFromFile( file )
  if( not fileExists( file ) ) then return {}; end
  local ln = {};
  for line in io.lines( file ) do
    ln[#ln+1] = line;
  end
  return ln;
end

function prepareInfo( line )
  local info = {};
  for i in string.gmatch( line, '[^,%[%] ]+' ) do
    info[#info+1] = i;
  end
  return info;
end


Items = {};
-- read item info from items.txt
function readItemsFromDisk()
	local filename = "./resource/item/items.txt";
	local ln = linesFromFile( filename );
	for ind, line in pairs( ln ) do
		local info = prepareInfo( line );
		local item = createItem( tonumber( info[1] ), info[2] );
		item.maxStack = tonumber( info[3] );
		item.quantity = item.maxStack;
		item.name = info[4];
		item.script = info[5];
		local err = pcall( require, "game.item." .. item.script );
		item.use = _G[info[6]];
		item.description = info[7];
		Items[item.id] = item;
		Items[item.name] = item;
	end
	
end

Weapons = {};
-- read item info from items.txt
function readWeaponsFromDisk()
	local filename = "./resource/item/weapons.txt";
	local ln = linesFromFile( filename );
	for ind, line in pairs( ln ) do
		local info = prepareInfo( line );
		local weapon = createWeapon( tonumber( info[1] ) );
		weapon.name = info[2];
		weapon.type = tonumber( info[3] );
		weapon.range.low = tonumber( info[4] );
		weapon.range.high = tonumber( info[5] );
		weapon.description = info[6];
		Weapons[weapon.id] = weapon;
		Weapons[weapon.name] = weapon;
	end
	
end

