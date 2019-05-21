-- Unit Actions

ACTION_MOVE = 0;
ACTION_HEAL = 1;
ACTION_ATTACK = 2;
ACTION_ITEM = 3;

-- The Pending Action
--[[This action slot is used if the local player has requested to perform an action
	while a remote action is in progress.]]
_G.PendingAction = nil;
_G.PndingAIAction = nil;
_G.ActionInProgress = false;

-- Action Submission
function submitMoveAction( moveAction )
	ActionQueue.enqueue( moveAction );
	PendingAction = createActionSet( moveAction.unit );
	PendingAction.move = moveAction;
end

function cancelMoveAction()
	ActionQueue.dequeue();
	PendingAction = nil;
end

function submitAIMoveAction( moveAction )
	AIQueue.enqueue( moveAction );
	PendingAIAction = createActionSet( moveAction.unit );
	PendingAIAction.move = moveAction;
	PendingAIAction.isAI = true;
end

function submitAttackAction( attackAction )
	ActionQueue.enqueue( attackAction );
	if( PendingAction == nil ) then
		PendingAction = createActionSet( attackAction.unit );
	end
	
	PendingAction.action = attackAction;
end

function submitAIAttackAction( attackAction )
	AIQueue.enqueue( attackAction );
	if( PendingAIAction == nil ) then
		PendingAIAction = createActionSet( attackAction.unit );
	end
	
	PendingAIAction.isAI = true;
	PendingAIAction.action = attackAction;
end

function submitItemAction( itemAction )
	ActionQueue.enqueue( itemAction );
	if( PendingAction == nil ) then
		PendingAction = createActionSet( itemAction.unit );
	end
	
	PendingAction.action = itemAction;
end

function submitAIItemAction( itemAction )
	AIQueue.enqueue( itemAction );
	if( PendingAIAction == nil ) then
		PendingAIAction = createActionSet( itemAction.unit );
	end
	
	PendingAIAction.action = itemAction;
	PendingAIAction.isAI = true;
end


-- Remote Action Processing
function processRequest( actionID, timestamp )
	print( "rx ACTION_REQUEST" );
	if( PendingAction == nil or PendingAction.committed == false ) then
		ActionInProgress = true;
		net.sendActionApproval( actionID );
	else
		print( PendingAction.timestamp .. ", " .. timestamp );
		if( PendingAction.timestamp < timestamp ) then
			net.sendActionDenial( actionID );
		else
			print( "I AM TIMESTAMPY, AND I APPROVE THIS ACTION" );
			net.sendActionApproval( actionID );
		end
	end
end

-- need to be able to distinguish between user-based and AI-based action approvals
-- perhaps some kind of an ID system could be used?
function actionApproved( actionID )
	print( "rx ACTION_APPROVED" );
	if( PendingAction ~= nil and PendingAction.id == actionID ) then
--	if( PendingAction ~= nil and PendingAction.committed ) then
		PendingAction.checkValidity();
		if( PendingAction.move == nil or (PendingAction.move ~= nil and PendingAction.move.valid) ) then
			PendingAction.execute();
		else
--			if( PendingAction.isAI == false ) then
				UIReg.clear();
--			end
			PendingAction = nil;
		end
	elseif( PendingAIAction ~= nil and PendingAIAction.id == actionID ) then
		PendingAIAction.checkValidity();
		print( "AI ACTION VALID? " .. tostring(PendingAIAction.action.valid) );
		if( (PendingAIAction.move ~= nil and PendingAIAction.move.valid == false) or PendingAIAction.action.valid == false ) then
			PendingAIAction = nil;
			return;
		end
		PendingAIAction.execute();
		PendingAIAction = nil;
	else
		print( "Everything sucks. I'm going home." );
		return;
	end
end

function actionDenied( actionID )
	print( "rx ACTION_DENIED" );
	-- do nothing, because the pending action can just be left,
	-- and it will execute when the ACTION_COMPLETED signal arrives
end

function remoteActionStarted()
	print( "rx ACTION_START" );
	ActionInProgress = true;
end

function remoteActionFinished()
	print( "rx ACTION_COMPLETED" );
	ActionInProgress = false;
	LevelMap.updateRanges();
	
	-- do we have a committed pending action?
	if( PendingAction ~= nil and PendingAction.committed ) then
		PendingAction.checkValidity();
		if( PendingAction.move.valid ) then
			PendingAction.execute();
		else
			if( PendingAction.isAI == false ) then
				UIReg.clear();
			end
			ActionQueue.clear();
			PendingAction = nil;
		end
	end
end

-- Constructors
function createActionSet( unit )
	local set = {};
	set.move = nil;
	set.action = nil;
	set.committed = false;
	set.isAI = false;
	set.timestamp = 1e20;
	set.id = math.random( 100000 );
	
	function set.commit()
		set.committed = true;
		set.timestamp = Global_time;
		
		-- make sure that the move hasn't become invalid while the player was putting it together
		set.checkValidity();
		if( set.isValid() == false ) then
			print( "Move is invalid upon commit" );
						
			if( set.isAI ) then
				PendingAIAction = nil;
				AIQueue.clear();
				
			else
				PendingAction = nil;
				UIReg.clear();
				ActionQueue.clear();
			end
			
			
			return;
		end
		-- TODO get rid of cludge RemoteActionInProgress, replace with a centralized system that takes AI and remote into account
		if( ActionInProgress == false ) then
			net.sendActionRequest( set.id, set.timestamp );
		else
			print( "Remote action is in progress, not transmitting..." );
		end
	end
	
	function set.execute()
		if( ActionInProgress == true ) then
			return;
		end
		net.sendActionStart( set );
		
		if( set.isAI ) then
			PendingAIAction = nil;
			AIQueue.commit();
		else
			PendingAction = nil;
			UIReg.open( "ActionAnimation" );
			ActionQueue.commit();
		end
		
		
	end
	
	function set.isValid()
		if( set.move ~= nil and set.move.valid == false ) then
			return false;
		end
	end
	
	
	-- Check if the move is still valid:
	-- check move path for obstructions
	-- if obstructions exist, check if we can re-route
	-- check if the target of 'action' is still available
	function set.checkValidity()
		-- check move
		if( set.move ~= nil ) then
			-- check unit
			if( unit.isAvailable() == false ) then
				set.move.valid = false;
				return;
			end
			
			local path = set.move.unitPath.path.path;
			set.move.valid = set.move.isRouteValid();
			if( set.move.valid == false ) then
				set.findNewRoute();
				set.move.valid = set.move.isRouteValid();
			end
		end
		
		-- check action
		if( set.action ~= nil ) then
			-- check unit
			if( unit.isAvailable() == false ) then
				set.action.valid = false;
				return;
			end
			
			local target = set.action.targetUnit;
			if( target ~= nil and unit.equipped ~= nil ) then
				-- should not assume that this is an attack action!
				local attackRange = unit.equipped.range;
				local distance = unit.tile.address.hexDistanceTo( target.tile.address );
				if( target.ko or attackRange.withinRangeInclusive( distance ) == false ) then
					set.action.valid = false;
				end
			end
		end
	end
	
	function set.findNewRoute()
		local newRoute = set.reroute( unit, set.move.unitPath.getDestination() );
		if( newRoute.complete == false or newRoute.path.length() > unit.getMoveRange() ) then
			set.move.valid = false;
		else
			set.move.valid = true;
			set.move.unitPath.path = newRoute;
		end
	end
	
	function set.reroute( unit, destination )
		local grid = LevelMap.grid;
		grid.clearPathFinding();
		grid.addPathFindingTarget( destination );
		grid.findPath();
		return grid.getPathForUnit( unit );
	end
	
	return set;
end

function createRemoteMoveAction( unitPath )
	local action = {};
	action.unit = unitPath.unit;
	action.unitPath = unitPath;
	action.isAI = false;
	action.delay = 0;
	action.initialized = false;
	action.type = ACTION_MOVE;
	action.elapsedTime = 0;
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_MOVE );
		action.initialized = true;
	end
	
	function action.execute()
		return unitPath.update();
	end
	
	
	function action.callback()
		action.elapsedTime = action.unitPath.getAssociatedAP();
		action.unit.changeAP( -action.elapsedTime );
		LevelMap.moveUnit( action.unit, action.unitPath.getDestination() );
		action.unit.setAnimation( -1 );
	end
	
	return action;
end

function createAIMoveAction( unitPath )
	local action = {};
	action.unit = unitPath.unit;
	action.unitPath = unitPath;
	action.isAI = true;
	action.delay = 0;
	action.initialized = false;
	action.type = ACTION_MOVE;
	action.elapsedTime = 0;
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_MOVE );
		action.initialized = true;
		ActionInProgress = true;
	end
	
	function action.execute()
		return unitPath.update();
	end
	
	function action.isRouteValid()
		local unit = action.unit;
		local path = action.unitPath.path.path;
		local destination = action.unitPath.getDestination();
		
		-- if the destination tile is blocked, nothing can be done
		if( destination.occupant ~= nil ) then
			return false;
		end
		
		for i = 1, path.length() do
			local tile = path.get(i);
			if( tile.occupant ~= nil and tile.occupant ~= unit ) then
				return false;
			end
		end
		
		return true;
	end
	
	function action.callback()
		action.elapsedTime = action.unitPath.getAssociatedAP();
		action.unit.changeAP( -action.elapsedTime );
		LevelMap.moveUnit( action.unit, action.unitPath.getDestination() );
		action.unit.setAnimation( -1 );
		ActionInProgress = false;
	end
	
	return action;
end

function createMoveAction( unitPath )
	local action = {};
	action.unit = unitPath.unit;
	action.unitPath = unitPath;
	action.isAI = false;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_MOVE;
	action.elapsedTime = 0;
	
	function action.isRouteValid()
		local unit = action.unit;
		local path = action.unitPath.path.path;
		local destination = action.unitPath.getDestination();
		
		-- if the destination tile is blocked, nothing can be done
		if( destination.occupant ~= nil ) then
			return false;
		end
		
		for i = 1, path.length() do
			local tile = path.get(i);
			if( tile.occupant ~= nil and tile.occupant ~= unit ) then
				return false;
			end
		end
		
		return true;
	end
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_MOVE );
		action.initialized = true;
		
		action.unit.currentAnimation.callback_finished = action.animationFinished;
		action.unit.currentAnimation.callback_looped = action.animationLooped;
	end
	
	function action.execute()
		-- TODO need to write a Camera "frame" function, and feed it the start and endpoints of the path
		Camera_lookDownAtPosition( GameInstance, action.unit.position );
		return unitPath.update();
	end
	
	function action.callback()
		action.elapsedTime = action.unitPath.getAssociatedAP();
		action.unit.changeAP( -action.elapsedTime );
		UIReg.activeUI.moveFinished( action.unitPath );
		action.unit.ghostTile = nil;
	end
	
	function action.animationFinished()
	end
	
	function action.animationLooped( overage )
	end
	
	return action;
end


function createAttackAction( unit, targetUnit )
	local action = {};
	action.unit = unit;
	action.targetUnit = targetUnit;
	action.data = encounter.computeAttack( unit, targetUnit );
	action.elapsedTime = action.data.timeConsumed;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_ATTACK;
	action.elapsedTime = 0;
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_ATTACK );
		action.unit.currentAnimation.reset();
		action.unit.lookAtPoint( targetUnit.position );
		action.initialized = true;
	end
	
	function action.execute()
		return action.unit.currentAnimation.isFinished();
	end
	
	function action.callback()
		encounter.processAttack( action.data );
		action.unit.setAnimation( -1 );
		UIReg.activeUI.attackFinished( unit );
		action.unit.alignToOrientation();
	end
	
	return action;
end

function createAIAttackAction( unit, targetUnit )
	local action = {};
	action.unit = unit;
	action.targetUnit = targetUnit;
	action.data = encounter.computeAttack( unit, targetUnit );
	action.elapsedTime = action.data.timeConsumed;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_ATTACK;
	action.elapsedTime = 0;
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_ATTACK );
		action.unit.currentAnimation.reset();
		action.unit.lookAtPoint( targetUnit.position );
		action.initialized = true;
		ActionInProgress = true;
	end
	
	function action.execute()
		return action.unit.currentAnimation.isFinished();
	end
	
	function action.callback()
		encounter.processAttack( action.data );
		action.unit.setAnimation( -1 );
--		UIReg.activeUI.attackFinished( unit );
		action.unit.alignToOrientation();
		ActionInProgress = false;
	end
	
	return action;
end

function createRemoteAttackAction( attackData )
	local action = {};
	action.unit = attackData.unit;
	action.targetUnit = attackData.target;
	action.data = attackData;
	action.elapsedTime = action.data.timeConsumed;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_ATTACK;
	action.elapsedTime = 0;
	
	function action.init()
		action.unit.setAnimation( ANIMATE_UNIT_ATTACK );
		action.unit.currentAnimation.reset();
		action.unit.lookAtPoint( action.targetUnit.position );
		action.initialized = true;
	end
	
	function action.execute()
		return action.unit.currentAnimation.isFinished();
	end
	
	function action.callback()
		encounter.processAttack( action.data );
		
		action.unit.setAnimation( -1 );
		action.unit.alignToOrientation();
	end
	
	return action;
end

function createItemAction( unit, targetUnit )
	local action = {};
	action.unit = unit;
	action.targetUnit = targetUnit;
	action.item = unit.heldItem;
	action.data = encounter.computeItemUsage( unit, targetUnit );
	action.elapsedTime = action.data.timeConsumed;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_ITEM;
	action.elapsedTime = 0;
	
	function action.init()
		if( unit == targetUnit ) then
			action.unit.setAnimation( ANIMATE_UNIT_USE_ITEM );
		else
			action.unit.setAnimation( ANIMATE_UNIT_USE_ITEM );
			action.unit.lookAtPoint( targetUnit.position );
		end
		
		action.unit.currentAnimation.reset();
		action.initialized = true;
		
		action.unit.currentAnimation.callback_finished = action.animationFinished;
		action.unit.currentAnimation.callback_looped = action.animationLooped;
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
		encounter.processItemUsage( action.data );
	end
	
	function action.callback()
		action.unit.setAnimation( -1 );
		UIReg.activeUI.attackFinished( unit );
		action.unit.alignToOrientation();
	end
	
	function action.animationFinished()
	end
	
	function action.animationLooped( overage )
	end
	
	return action;
end

function createRemoteItemAction( itemData )
	local action = {};
	action.unit = itemData.unit;
	action.targetUnit = itemData.targetUnit;
	action.item = itemData.item;
	action.elapsedTime = itemData.timeConsumed;
	action.data = itemData;
	action.delay = 0;
	action.valid = true;
	action.initialized = false;
	action.events = createList();
	action.type = ACTION_ITEM;
	action.elapsedTime = 0;
	
	function action.init()
		if( unit == action.targetUnit ) then
			action.unit.setAnimation( ANIMATE_UNIT_USE_ITEM );
		else
			action.unit.setAnimation( ANIMATE_UNIT_USE_ITEM );
			action.unit.lookAtPoint( action.targetUnit.position );
		end
		
		action.unit.currentAnimation.reset();
		action.initialized = true;
		
		action.unit.currentAnimation.callback_finished = action.animationFinished;
		action.unit.currentAnimation.callback_looped = action.animationLooped;
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
		encounter.processItemUsage( action.data );
	end
	
	function action.callback()
		action.unit.setAnimation( -1 );
		action.unit.alignToOrientation();
	end
	
	function action.animationFinished()
	end
	
	function action.animationLooped( overage )
	end
	
	return action;
end

