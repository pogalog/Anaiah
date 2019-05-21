-- Invoked by UI
-- Unit actions are submitted to the Executive System
-- Provides definitions for the various unit actions


-- Unit Action Constants
Exec.ACTION_MOVE = 0;
Exec.ACTION_ABILITY = 1;
Exec.ACTION_ATTACK = 2;
Exec.ACTION_ITEM = 3;



function Exec.submitAction( action )
	Exec.TempQueue.enqueue( action );
end

function Exec.cancel()
	Exec.TempQueue.removeLast();
end

function Exec.commitUserActions()
	Exec.commitActions( Exec.TempQueue.data );
	Exec.TempQueue.data = createList();
	Exec.userActionStart();
end

function Exec.storeActions( actionList )
	local primary = actionList.first();
	print( "STORING ACTIONS: " .. primary.actionID );
	Exec.ActionPool.store( primary.actionID, actionList );
end


function Exec.commitActions( actionList )
	if( actionList == nil or actionList.length() == 0 ) then return; end
	
	-- Set the isLast flag to 'true' for the last action in the queue
	actionList.last().isLast = true;
	
	-- Set timestamp for actions, they will be scheduled on receipt of approval
	for i = 1, actionList.length() do
		local action = actionList.get(i);
		action.timestamp = Global_time;
	end
	
	-- Store actions in global action pool
	Exec.storeActions( actionList );
	
	-- Request approval from remote
	Exec.requestApproval( actionList );
end


function Exec.linkActions( actionList )
	actionList.last().isLast = true;
	
	if( actionList.length() < 2 ) then return; end
	
	local primary = actionList.first();
	
	for i = 2, actionList.length() do
		local action = actionList.get(i);
		action.linkedAction = primary;
	end
end



function Exec.scheduleAction( action )
	return Exec.ActionQueue.sortInsert( action, "timestamp" );
end


function Exec.scheduleActionsFromPool( actionID )
	local actionList = Exec.ActionPool.get( actionID );
	print( "scheduleActionsFromPool ".. actionID );
	if( actionList == nil ) then return; end
	
	return Exec.scheduleActions( actionList );
end

--function Exec.scheduleTempQueue()
--	local primary = Exec.TempQueue.peek();
--	local primaryIndex = Exec.scheduleAction( primary );
--	Exec.TempQueue.dequeue();
--	
--	while( Exec.TempQueue.length() > 0 ) do
--		local action = Exec.TempQueue.peek();
--		Exec.scheduleAction( action );
--		Exec.TempQueue.dequeue();
--	end
--	
--	return primaryIndex;
--end


function Exec.scheduleActions( actionList )
	if( actionList.length() == 0 ) then return 0; end
	
	local primary = actionList.get(1);
	local index = Exec.scheduleAction( primary );
	for i = 2, actionList.length() do
		local action = actionList.get(i);
		Exec.ActionQueue.insertAt( action, index + (i - 1) );
	end
	
	return index;
end


function Exec.generateActionID()
	math.randomseed( os.time() );
	return math.random( 1, 1000000000 );
end


-- Action constructors
function Exec.createAction()
	local action = {};
	action.name = "Action";
	action.isAI = false;
	action.isRemote = false;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.elapsedTime = 0;
	action.isLast = false;
	action.actionID = Exec.generateActionID();
	
	function action.validate()
		action.valid = false;
	end
	
	function action.getLinkedID()
		return action.linkedAction == nil and 0 or action.linkedAction.actionID;
	end
	
	function action.init() end
	function action.execute() return true; end
	function action.callback() end
	function action.animationFinished() end
	function action.animationLooped( overage ) end
	
	function action.cleanup()
		if( action.isLast ) then
			Network.sendReady();
			UI.actionFinished();
			Exec.ChainFinished = true;
		end
		
		if( action.isAI or action.isRemote ) then return; end
		if( action.isLast ) then
			UI.clear();
		end
	end
	
	return action;
end


function Exec.createMoveAction( unitPath, linkedAction )
	local action = Exec.createAction();
	action.name = "Move Action";
	action.unit = unitPath.unit;
	action.unitPath = unitPath;
	action.linkedAction = linkedAction;
	action.type = Exec.ACTION_MOVE;
	
	function action.validate()
		local unit = action.unit;
		local path = action.unitPath.path.path;
		local destination = action.unitPath.getDestination();
		
		if( unit.ko ) then
			action.valid = false;
			return;
		end
		
		-- if the destination tile is blocked, nothing can be done
		if( destination.getOccupant() ~= nil ) then
			action.valid = false;
			return;
		end
		
		for i = 1, path.length() do
			local tile = path.get(i);
			if( tile.getOccupant() ~= nil and tile.getOccupant() ~= unit ) then
				action.valid = false;
				return;
			end
		end
		
		action.valid = true;
	end
	
	function action.animationFinished() end
	
	function action.init()
		action.unit.setAnimation( Anim.ANIMATE_UNIT_MOVE );
		action.initialized = true;
		
		action.unit.currentAnimation.callback_finished = action.animationFinished;
		action.unit.currentAnimation.callback_looped = action.animationLooped;
	end
	
	function action.execute()
		-- TODO need to write a Camera 'frame()' function, and feed it the start and endpoints of the path
		if( Exec.isLocalCommitted() ) then
			Camera.lookDownAtPosition( action.unit.position );
		end
		return unitPath.update();
	end
	
	function action.callback()
		if( action.valid ) then
			action.elapsedTime = action.unitPath.getAssociatedAP();
			action.unit.changeAP( -action.elapsedTime );
			LevelMap.moveUnit( action.unit, action.unitPath.getDestination() );
		end
		UI.getActiveUI().moveFinished( action.unitPath );
		action.unit.setAnimation( -1 );
		action.unit.ghostTile = nil;
		Exec.userActionFinished();
	end
	
	return action;
end

-- remote move
function Exec.createRemoteMoveAction( unit, targetUnit )
	local action = Exec.createMoveAction( unit, targetUnit );
	action.name = "Remote Move Action";
	action.isRemote = true;
	
	function action.callback()
		if( action.valid ) then
			action.elapsedTime = action.unitPath.getAssociatedAP();
			action.unit.changeAP( -action.elapsedTime );
			LevelMap.moveUnit( action.unit, action.unitPath.getDestination() );
		end
		action.unit.setAnimation( -1 );
	end
	
	return action;
end

-- AI move
function Exec.createAIMoveAction( unit, targetUnit )
	local action = Exec.createMoveAction( unit, targetUnit );
	action.name = "AI Move Action";
	action.isAI = true;
	
	function action.callback()
		if( action.valid ) then
			action.elapsedTime = action.unitPath.getAssociatedAP();
			action.unit.changeAP( -action.elapsedTime );
			LevelMap.moveUnit( action.unit, action.unitPath.getDestination() );
		end
		action.unit.setAnimation( -1 );
	end
	
	return action;
end


function Exec.createAttackAction( unit, targetUnit, linkedAction )
	local action = Exec.createAction();
	action.name = "Attack Action";
	action.unit = unit;
	action.targetUnit = targetUnit;
	action.linkedAction = linkedAction;
	action.data = Game.Encounter.computeAttack( unit, targetUnit );
	action.elapsedTime = action.data.timeConsumed;
	action.type = Exec.ACTION_ATTACK;
	
	-- TODO Figure out why the tile.unit is nil, and also figure out why the attacking unit rotates ccw!
	------------------------------------------------------------------------------------------------------
	function action.validate()
		if( action.unit.ko or action.targetUnit.ko ) then
			action.valid = false;
			return;
		end
		-- check the single attack range
		local tile = unit.hasGhost() and unit.ghostTile or unit.tile;
		local sar = LevelMap.grid.getSingleAttackRange( unit, tile );
		action.valid = false;
		for i = 1, sar.length() do
			local ti = sar.get(i);
			if( targetUnit.occupiesTile( ti ) ) then
				action.valid = true;
				break;
			end
		end
	end
	
	function action.init()
		action.unit.setAnimation( Anim.ANIMATE_UNIT_ATTACK );
		action.unit.currentAnimation.reset();
		action.unit.lookAtPoint( targetUnit.position );
		action.initialized = true;
	end
	
	function action.execute()
		return action.unit.currentAnimation.isFinished();
	end
	
	function action.callback()
		if( action.valid ) then
			Game.Encounter.processAttack( action.data );
			action.unit.setAnimation( -1 );
		end
		
		UI.getActiveUI().attackFinished( unit );
		action.unit.alignToOrientation();
		Exec.userActionFinished();
	end
	
	return action;
end

-- remote attack
function Exec.createRemoteAttackAction( unit, targetUnit )
	local action = Exec.createAttackAction( unit, targetUnit );
	action.name = "Remote Attack Action";
	action.isRemote = true;
	
	function action.callback()
		if( action.valid ) then
			Game.Encounter.processAttack( action.data );
			action.unit.setAnimation( -1 );
		end
		
		action.unit.alignToOrientation();
	end
	
	function action.setEncounterData( success, critical, damage, time )
		action.data = {};
		action.data.unit = action.unit;
		action.data.target = action.targetUnit;
		action.data.success = success;
		action.data.critical = critical;
		action.data.damage = damage;
		action.data.timeConsumed = time;
	end
	
	return action;
end

-- AI attack
function Exec.createAIAttackAction( unit, targetUnit )
	local action = Exec.createAttackAction( unit, targetUnit );
	action.name = "AI Attack Action";
	action.isAI = true;
	
	function action.callback()
		if( action.valid ) then
			Game.Encounter.processAttack( action.data );
			action.unit.setAnimation( -1 );
		end
		
		action.unit.alignToOrientation();
	end
	
	function action.setEncounterData( success, critical, damage, time )
		action.data = {};
		action.data.unit = action.unit;
		action.data.target = action.targetUnit;
		action.data.success = success;
		action.data.critical = critical;
		action.data.damage = damage;
		action.data.timeConsumed = time;
	end
	
	return action;
end


function Exec.createItemAction( unit, targetUnit, linkedAction )
	local action = Exec.createAction();
	action.name = "Item Action";
	action.unit = unit;
	action.targetUnit = targetUnit;
	action.item = unit.heldItem;
	action.linkedAction = linkedAction;
	action.data = Game.Encounter.computeItemUsage( unit, targetUnit );
	action.elapsedTime = action.data.timeConsumed;
	action.type = Exec.ACTION_ITEM;
	
	
	-- TODO Need to perform some item-specific tests (i.e. some items may have different conditions for use).
	function action.validate()
		-- is target unit still alive?
		if( targetUnit.ko or targetUnit.ko ) then
			action.valid = false;
			return;
		end
		
		-- is target within range?
		action.valid = LevelMap.grid.isTileWithinRange( unit.tile, targetUnit.tile, unit.stat.itemRange, true );
	end
	
	function action.init()
		if( unit == targetUnit ) then
			action.unit.setAnimation( Anim.ANIMATE_UNIT_USE_ITEM );
		else
			action.unit.setAnimation( Anim.ANIMATE_UNIT_USE_ITEM );
			action.unit.lookAtPoint( targetUnit.position );
		end
		
		action.unit.currentAnimation.reset();
		action.initialized = true;
		
		action.unit.currentAnimation.callback_finished = action.animationFinished;
		action.unit.currentAnimation.callback_looped = action.animationLooped;
		
		-- TODO do this here?
		action.events.add( Exec.createActionEvent( action, 2.8, action.useFunc ) );
	end
	
	function action.execute()
		for i = 1, action.events.length() do
			local event = action.events.get(i);
			event.execute( Global_dt );
		end
		
		local finished = action.unit.currentAnimation.isFinished();
		return finished;
	end
	
	function action.useFunc()
		Game.Encounter.processItemUsage( action.data );
	end
	
	function action.callback()
		action.unit.setAnimation( -1 );
		UI.getActiveUI().attackFinished( unit );
		action.unit.alignToOrientation();
		Exec.userActionFinished();
	end
	
	function action.animationFinished()
	end
	
	function action.animationLooped( overage )
	end
	
	return action;
end

-- remote item
function Exec.createRemoteItemAction( unit, targetUnit )
	local action = Exec.createItemAction( unit, targetUnit );
	action.name = "Remote Item Action";
	action.isRemote = true;
	
	function action.callback()
		action.unit.setAnimation( -1 );
		action.unit.alignToOrientation();
	end
	
	return action;
end

-- AI item
function Exec.createAIItemAction( unit, targetUnit )
	local action = Exec.createItemAction( unit, targetUnit );
	action.name = "AI Item Action";
	action.isAI = true;
	
	function action.callback()
		action.unit.setAnimation( -1 );
		action.unit.alignToOrientation();
	end
	
	return action;
end
