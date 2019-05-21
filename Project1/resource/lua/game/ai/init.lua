-- AI Initialization
-- Executed on AI thread


package.path = "resource/lua/?.lua;resource/lua/game/?.lua;resource/map/?.lua";
require( "math.vector" );
require( "structure.list" );
require( "game.main" );
--require( "game.map.levelmap" );
--require( "game.team" );
--require( "game.item.main" );
--require( "game.ai.util" );


function storeAIData( data )
	-- item and weapon lists (disk)
	Game.readItemsFromDisk();
	Game.readWeaponsFromDisk();
	
	-- the AI bulk data
	LevelMap = AI.interpretAIData( data );
end

-- Main AI Task function
-- Returns a boolean to indicate if the result should be used
function processTask()
	-- run the AI calculations
	local result = simpleAI();
	if( result == nil ) then
		return false;
	end
	
	-- package the result in a binary string, pass to host program
	_G.Result = AI.packAIResult( result );
	
	return true;
end

function getResult()
	return string.len( Result ), Result;
end


function simpleAI()
	local chosenOne = nil;
	local target = nil;
	local destination = nil;
	for i = 1, ActiveTeam.units.length() do
		local unit = ActiveTeam.units.get(i);
		if( unit.isAvailable() == false ) then print( unit.name .. " not avilable" ); goto cont end;
		
		-- choose a target
		target = chooseTarget( unit );
		if( target == nil ) then print( "no target for " .. unit.name ); goto cont end

		-- find a place to stand based on the weapon atk range
		destination = findFooting( unit, target );
		if( destination == nil ) then print( "no footing for " .. unit.name ); goto cont end
		
		chosenOne = unit;
		break;
		::cont::
	end

	if( chosenOne == nil ) then print( "No available unit" ); return nil; end
		
	print( chosenOne.name .. " will attack " .. target.name .. " at " .. Vec2_tostring( destination.address ) );
	
	local result = {};
	result.unit = chosenOne;
	result.target = target;
	result.destination = destination;
	return result;
end