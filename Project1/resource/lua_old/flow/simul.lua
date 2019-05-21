-- Simultaneous Action Flow Control
require( "game.encounter" );
require( "game.ai.data" );
require( "flow.timer" );


-- Main Flow
function updateFlow()
	-- update timers
	ai_timer.step( Global_dt );
	ap_timer.step( Global_dt );
	
	fetchAIResult();
end

function incrementAP()
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

function runAI()
	-- TODO phase control will determine the teamID
	local teamID = 3;
	-- TODO shouldn't use this information to make this decision
	if( Network.isAIEligible() ) then
		local size, aiData = packAIData( teamID );
		Game_startAI( GameInstance, size, aiData );
	end
end

-- Timers
ai_timer = createTimer( 5.0, runAI );
ap_timer = createTimer( 2.0, incrementAP );


-- Utility
function fetchAIResult()
	if( ActionQueue.isBusy() ) then return; end
	
	local ai_data = Game_fetchAIResult( GameInstance );
	local result = interpretAIResult( ai_data );
	if( result == nil ) then return; end
	
	-- do we need a move action?
	if( result.unit.tile ~= result.destination ) then
		local grid = LevelMap.grid;
		grid.clearPathFinding();
		grid.addPathFindingTarget( result.destination );
		grid.findPath();
		result.unit.path = grid.getPathForUnit( result.unit );
		local unitPath = createUnitPath( result.unit, result.unit.path );

		submitAIMoveAction( createAIMoveAction( unitPath ) );
	end
	submitAIAttackAction( createAIAttackAction( result.unit, result.target ) );
	PendingAIAction.commit();
end



function selectTile( tile )
	local cursor = LevelMap.cursor;
		
		local unit = tile.occupant;
		if( unit ~= nil and Player.team.containsUnit( unit ) and unit.isMoving == false and unitIsReady( unit ) ) then
			cursor.selectedTile = cursor.highlightedTile;
			cursor.selectedUnit = cursor.selectedTile.occupant;
			UIReg.open( "UnitActionMenu" );
		end
end

function unitIsReady( unit )
	-- check AP and thresholds (etc)
	if( unit.stat.ap < unit.stat.minAP ) then return false; end
	if( unit.stat.hp <= 0 ) then return false; end
	return true;
end


-- Replenishes some AP to all units
function unitActionPerformed( action )
--	local units = LevelMap.units;
--	for i = 1, units.length() do
--		local unit = units.get(i);
--		if( unit == action.unit ) then goto cont; end
--		if( unit.ko ) then goto cont; end
--		unit.changeAP( action.elapsedTime );
--		::cont::
--	end
end

