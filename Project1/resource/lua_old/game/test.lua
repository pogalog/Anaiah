require( "trigger" );
require( "event" );
require( "grid" );
require( "tile" );
require( "unit" );
require( "levelmap" );

-- test
function mainLoop()
	mainLevelLoop();
end

function mainLevelLoop()
	print( "main loop" );
end

-- test function for trigger
function simpleProximityTest( owner, targets, range )
	newTargets = {};
	for i = 1, #targets do
		if( owner ~= targets[i] ) then
			-- check distnace between owner and target
			local dist = owner.location.getDistanceToTile( targets[i].location );
			if( dist <= range ) then
				newTargets[#newTargets+1] = targets[i];
			end
		end
	end
	return newTargets;
end

-- better test function for trigger
--[[NOTE: This function needs to use a generalized range function, not
	 the movement range function. There are two problems with using movement
	 range function: 1) it's based on movement range, not a specified range,
	 and 2) it needs to add tiles with other units (move range ignores these tiles).]]
function proximityTest( owner, targets, range )
	local proxTargets = {};
	local mvRange = level.grid.getTilesWithinRange( owner, range, true );
	for i = 1, #targets do
		if( owner ~= targets[i] ) then
			if( mvRange.contains( targets[i].location ) ) then
				proxTargets[#proxTargets+1] = targets[i];
			end
		end
	end
	return proxTargets;
end

-- execution function for event
function enbuffinate( target )
	local oldStat = target.stat.str;
	target.stat.str = target.stat.str + 2;
	print( "Buffed " .. target.name .. " from " .. oldStat .. " to " .. target.stat.str .. " str!" );
end

level = createLevelMap( mainLevelLoop, 25, 25 );
unit0 = createUnit( "Anaiah" );
unit1 = createUnit( "Simeon" );
level.grid.placeUnit( unit0, 13, 14 );
level.grid.placeUnit( unit1, 16, 12 );
targets = {unit0, unit1};
trigger = createTrigger( unit1, targets, proximityTest, 5 );
event = createEvent( enbuffinate );
trigger.addEvent( event, TRIGGER_ADD );
level.addTrigger( trigger );

trigger.test();


print( "Test done" );
