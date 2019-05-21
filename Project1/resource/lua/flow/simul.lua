-- Simultaneous Action Flow Control
require( "flow.timer" );



-- Main Flow
function Flow.update()
	-- update timers
	ai_timer.step( Global_dt );
--	ap_timer.step( Global_dt );
	
	AI.fetchResult();
end

function Flow.incrementAP()
	if( ActionQueue.isBusy() ) then return; end
	
	local units = LevelMap.units;
	for i = 1, units.length() do
		local unit = units.get(i);
		if( unit.ko ) then goto cont; end
		unit.changeAP( 0.5 );
		::cont::
	end
	
	Overlay.updateUnitOverlay();
	LevelMap.updateVisibleRanges();
end

function Flow.runAI()
	print( "RUNNING AI" );
	-- TODO phase control will determine the teamID
	local teamID = 3;
	-- TODO shouldn't use this information to make this decision
	if( Network.isAIEligible() ) then
		local size, aiData = AI.packAIData( teamID );
		Game_startAI( GameInstance, size, aiData );
	end
end

-- Timers
ai_timer = Flow.createTimer( 8.0, Flow.runAI );
ap_timer = Flow.createTimer( 2.0, incrementAP );


-- Utility
function Flow.selectTile( tile )
	local cursor = LevelMap.cursor;
		
	local unit = tile.getOccupant();
	if( unit ~= nil and Player.team.containsUnit( unit ) and unit.isMoving == false and Flow.unitIsReady( unit ) ) then
		cursor.selectedTile = cursor.highlightedTile;
		cursor.selectedUnit = cursor.selectedTile.getOccupant();
		UI.open( "UnitActionMenu" );
	end
end

function Flow.unitIsReady( unit )
	-- check AP and thresholds (etc)
	if( unit.stat.ap < unit.stat.minAP ) then return false; end
	if( unit.stat.hp <= 0 ) then return false; end
	return true;
end


-- Replenishes some AP to all units
function Flow.unitActionPerformed( action )
--	local units = LevelMap.units;
--	for i = 1, units.length() do
--		local unit = units.get(i);
--		if( unit == action.unit ) then goto cont; end
--		if( unit.ko ) then goto cont; end
--		unit.changeAP( action.elapsedTime );
--		::cont::
--	end
end

