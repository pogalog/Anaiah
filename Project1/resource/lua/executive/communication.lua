-- Invoke the Network
-- Unit actions are submitted to the Network System for transmission
local remoteActions = createList();


function Exec.requestApproval( actionList )
	Network.requestApproval( actionList );
end


-- There is no longer any reason to deny the request. Timestamp comparisons are performed
-- implicitly within the scheduling system (see Exec.actionApproved()).
function Exec.remoteRequest( remoteActionList )
	print( "rx ACTION_REQUEST" );
	if( remoteActionList.length() == 0 ) then return; end
	
	if( Exec.ScheduleHold and Network.isServer() ) then
		print( "HOLD UP!!! POTENTIAL SCHEDULE CONFLICT!!!" );
		Exec.ApprovalFreeze = true;
		remoteActions = remoteActionList;
		return;
	end
	
	Exec.approveRequest( remoteActionList );
end

function Exec.resumeApproval()
	Exec.approveRequest( remoteActions );
end

function Exec.approveRequest( remoteActionList )
	-- schedule the action in our own queue
	local primaryIndex = Exec.scheduleActions( remoteActionList );
	local primary = remoteActionList.get(1);
	
	print( "action id: " .. primary.actionID );
	-- transmit a greenlight to the remote
	Network.sendActionApproval( primary.actionID, primaryIndex );
end


function Exec.actionApproved( actionID, remoteIndex )
	print( "rx ACTION_APPROVED" );
	
	local ready = true;
	
	-- Transfer actions from ActionPool to ActionQueue
	local localIndex = Exec.scheduleActionsFromPool( actionID );
	print( "ID MATCH: " .. localIndex .. ", " .. remoteIndex );
	if( localIndex ~= remoteIndex and remoteIndex > 0 ) then
		ready = Exec.resolveScheduleConflict( {localIndex, actionID}, {remoteIndex, actionID} );
	end
	
	if( Exec.ApprovalFreeze ) then
		print( "REMOVING APPROVAL FREEZE" );
		Exec.ApprovalFreeze = false;
		Exec.resumeApproval();
	end
	
	if( ready ) then
		Exec.resume();
	end
end



function Exec.scheduleCorrection( actionID, newIndex )
	print( "rx SCHEDULE_CORRECTION" );
	
	-- correct the schedule
	Exec.correctActionSchedule( actionID, newIndex );
	Network.sendScheduleConfirmed( actionID, newIndex );
	Exec.resume();
end


function Exec.remoteReady()
	print( "rx ACTION_READY" );
	
	Exec.RemoteIsReady = true;
	Exec.WaitingForRemote = false;
end


function Exec.remoteReadyRequest()
	print( "rx READY_REQUEST" );
	
	if( Exec.isBusy() == false ) then
		Network.sendReady();
	else
		Network.sendWait();
	end
end


function Exec.remoteWait()
	print( "rx WAIT" );
	
	Exec.ResetRemote();
	Exec.WaitingForRemote = true;
end


function Exec.scheduleConfirmed( actionID, index )
	print( "rx SCHEDULE_CONFIRMED: " .. actionID .. " at " .. index );
	Exec.resume();
end



-- Contacts the remote to notify of the conflict, and resolves it
-- Returns whether the local node is ready for execution
function Exec.resolveScheduleConflict( localData, remoteData )
	print( "RESOLVING SCHEDULE CONFLICT" );
	local localIndex = localData[1];
	local localID = localData[2];
	local remoteIndex = remoteData[1];
	local remoteID = remoteData[2];
	
	local toss = Exec.coinToss();
	if( Network.isServer() ) then
		-- send SCHEDULE_CORRECTION
		Network.sendScheduleCorrection( toss and localID or remoteID, toss and localIndex or remoteIndex );
		return false;
	else
		-- correct the local schedule
		Exec.correctActionSchedule( toss and localID or remoteID, toss and localIndex or remoteIndex );
		return true;
	end
end


function Exec.coinToss()
	math.randomseed( os.time() );
	local val = math.random( 100 );
	return val > 50;
end
