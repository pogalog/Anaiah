-- Invoked by the Executive System / Invokes Executive System
-- Communication is sent regarding scheduling and execution of unit actions
-- Forward remote communications to Executive System




-- Inbound invocation
function Network.requestApproval( actionList )
	print( "TX ACTION_REQUESTED" );
	writeByte( Network.Buffer, Network.ACTION_REQUESTED );
	Network.bufferActionList( actionList );
	Network.send();
	Exec.pause();
end


function Network.sendActionApproval( actionID, actionIndex )
	print( "TX ACTION_APPROVED" );
	writeByte( Network.Buffer, Network.ACTION_APPROVED );
	writeInt( Network.Buffer, actionID );
	writeInt( Network.Buffer, actionIndex );
	Network.send();
end


function Network.sendReady()
	print( "TX ACTION_READY" );
	
	Network.Buffer.reset();
	writeByte( Network.Buffer, Network.ACTION_READY );
	Network.send();
end


function Network.sendWait()
	print( "TX WAIT" );
	writeByte( Network.Buffer, Network.REMOTE_WAIT );
	Network.send();
end

function Network.sendReadyRequest()
	print( "TX READY_REQUEST" );
	writeByte( Network.Buffer, Network.ACTION_READY_REQUEST );
	Network.send();
end


function Network.sendScheduleCorrection( actionID, actionIndex )
	print( "TX SCHEDULE_CORRECTION" );
	writeByte( Network.Buffer, Network.SCHEDULE_CORRECTION );
	writeInt( Network.Buffer, actionID );
	writeInt( Network.Buffer, actionIndex );
	Network.send();
end

function Network.sendScheduleConfirmed( actionID, actionIndex )
	print( "TX SCHEDULE_CONFIRMED" );
	writeByte( Network.Buffer, Network.SCHEDULE_CONFIRMED );
	writeInt( Network.Buffer, actionID );
	writeInt( Network.Buffer, actionIndex );
end

function Network.sendActionFinished( actionID )
	-- TODO make this function
end





-- Outbound Invocation (Exec)
function Network.remoteReady()
	Exec.remoteReady();
end


function Network.remoteWait()
	Exec.remoteWait();
end


function Network.remoteReadyRequest()
	Exec.remoteReadyRequest();
end


function Network.scheduleCorrection( actionID, actionIndex )
	Exec.scheduleCorrection( actionID, actionIndex );
end


function Network.actionApproved( actionID, remoteIndex )
	Exec.actionApproved( actionID, remoteIndex );
end

function Network.remoteRequest( buffer )
	local remoteActionList = Network.constructActionList( buffer );
	Exec.remoteRequest( remoteActionList );
end

function Network.scheduleConfirmed( buffer )
	local actionID = readInt( buffer );
	local index = readInt( buffer );
	Exec.scheduleConfirmed( actionID, index );
end



function Network.constructActionList( buffer )
	local actions = createList();
	local numActions = readInt( buffer );
	for i = 1, numActions do
		local action = Network.readAction( buffer );
		actions.add( action );
	end
	
	Network.linkActions( actions );
	return actions;
end


function Network.linkActions( actions )
	Exec.linkActions( actions );
end


function Network.readAction( buffer )
	local action = nil;
	local actionID = readInt( buffer );
	local timestamp = readFloat( buffer );
	local actionType = readByte( buffer );
	if( actionType == Exec.ACTION_MOVE ) then
		action = Network.readMoveAction( buffer );
	elseif( actionType == Exec.ACTION_ABILITY ) then
		action = Network.readHealAction( buffer );
	elseif( actionType == Exec.ACTION_ATTACK ) then
		action = Network.readAttackAction( buffer );
	elseif( actionType == Exec.ACTION_ITEM ) then
		action = Network.readItemAction( buffer );
	else
		-- this will not happen, ever... unless data corruption
		print( "Unknown action type!" );
	end
	action.actionID = actionID;
	action.timestamp = timestamp;
	
	return action;
end


function Network.readMoveAction( buffer )
	
	
	local unitID = readInt( buffer );
	local delay = readInt( buffer );
	local unit = LevelMap.getUnitByID( unitID );
	
	local path = Game.createPath();
	unit.path = path;
	
	local numTiles = readInt( buffer );
	for i = 1, numTiles do
		local address = readVec2i( buffer );
		local pvd = readInt( buffer );
		local tile = LevelMap.grid.getTile( address );
		path.addTileRemote( tile, pvd );
	end
	
	local unitPath = Game.createUnitPath( unit, path );
	local action = Exec.createRemoteMoveAction( unitPath );
	action.delay = delay;
	return action;
end


-- TODO
function Network.readAbilityAction( buffer )
	
end


function Network.readAttackAction( buffer )
	local unitID = readInt( buffer );
	local targetID = readInt( buffer );
	
	local unit = LevelMap.getUnitByID( unitID );
	local target = LevelMap.getUnitByID( targetID );
	
	local action = Exec.createRemoteAttackAction( unit, target );
	action.delay = readInt( buffer );
	
	-- encounter
	local hit = readBool( buffer );
	local crit = readBool( buffer );
	local dmg = readInt( buffer );
	local time = readFloat( buffer );
	action.setEncounterData( hit, crit, dmg, time );
	return action;
end


function Network.readItemAction( buffer )
	local unitID = readInt( buffer );
	local targetID = readInt( buffer );
	local itemID = readInt( buffer );
	
	local unit = LevelMap.getUnitByID( unitID );
	local target = LevelMap.getUnitByID( targetID );
	
	unit.heldItem = Items[itemID];
	
	local action = Exec.createRemoteItemAction( unit, target );
	action.delay = readInt( buffer );
	return action;
end


function Network.bufferActionList( actionList )
	local buffer = Network.Buffer;
	
	writeInt( buffer, actionList.length() );
	for i = 1, actionList.length() do
		local action = actionList.get(i);
		
		writeInt( buffer, action.actionID );
		writeFloat( buffer, action.timestamp );
		
		if( action.type == Exec.ACTION_MOVE ) then
			Network.writeMoveAction( buffer, action );
		elseif( action.type == Exec.ACTION_ABILITY ) then
			Network.writeAbilityAction( buffer, action );
		elseif( action.type == Exec.ACTION_ATTACK ) then
			Network.writeAttackAction( buffer, action );
		elseif( action.type == Exec.ACTION_ITEM ) then
			Network.writeItemAction( buffer, action );
		else
			-- just whine
			print( "Invalid action type!!" );
		end
	end
end


function Network.writeMoveAction( buffer, action )
	writeByte( buffer, Exec.ACTION_MOVE );
	writeInt( buffer, action.unit.unitID );
	writeInt( buffer, action.delay );
	writeInt( buffer, action.unitPath.path.path.length() );
	for i = 1, action.unitPath.path.path.length() do
		local tile = action.unitPath.path.path.get(i);
		writeVec2i( buffer, tile.address );
		writeInt( buffer, tile.pathValDir );
	end
end


function Network.writeAbilityAction( buffer, action )
	
end


function Network.writeAttackAction( buffer, action )
	writeByte( buffer, Exec.ACTION_ATTACK );
	writeInt( buffer, action.unit.unitID );
	writeInt( buffer, action.targetUnit.unitID );
	writeInt( buffer, action.delay );
	-- encounter
	local data = action.data;
	writeBool( buffer, data.success );
	writeBool( buffer, data.critical );
	writeInt( buffer, data.damage );
	writeFloat( buffer, data.timeConsumed );
end


function Network.writeItemAction( buffer, action )
	writeByte( buffer, Exec.ACTION_ITEM );
	writeInt( buffer, action.unit.unitID );
	writeInt( buffer, action.targetUnit.unitID );
	writeInt( buffer, action.unit.heldItem.id );
	writeInt( buffer, action.delay );
end

