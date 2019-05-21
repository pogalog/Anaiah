-- Executive System
-- Maintains core Executive structures
Exec = {};


require( "executive.action_event" );
require( "executive.communication" );
require( "executive.task_sequence" );
require( "executive.unit_action" );
require( "executive.local" );
require( "structure.queue" );
require( "structure.collection" );
require( "flow.timer" );
require( "network.main" );





Exec.ActionQueue = createQueue();
Exec.TempQueue = createQueue();
Exec.ActionPool = createCollection();
Exec.InitLatencyDelay = Flow.createTimer(0);
Exec.RemoteIsReady = true;
Exec.WaitingForRemote = false;
Exec.ScheduleHold = false;
Exec.ApprovalFreeze = false;
Exec.ChainFinished = false;
local aq = Exec.ActionQueue;
local tq = Exec.TempQueue;


function Exec.initTaskSequence()
	Exec.ats = Exec.createTaskSequenceList();
end


function Exec.isBusy()
	return Exec.ActionQueue.length() > 0 and
		   Exec.ActionQueue.peek().initialized;
end


function Exec.setRemoteReady()
	Exec.RemoteIsReady = true;
end

function Exec.getQueuedAction()
	return Exec.TempQueue.peek();
end

function Exec.pause()
	Exec.ScheduleHold = true;
end

function Exec.resume()
	Exec.ScheduleHold = false;
end


function Exec.executeCurrentAction()
	if( aq.length() == 0 ) then return; end
	
	local action = aq.peek();
	if( action.delay > 0 ) then
		action.delay = action.delay - 1;
		return;
	end
	
	if( action.initialized == false ) then
		if( Exec.ScheduleHold )then print( "SCHEDULE HOLD" ); return; end
		
		-- synchronize between local and remote (do not start action until both ends are ready)
		if( Exec.checkRemoteStatus() == false ) then return; end
		
		-- synchronize execution for connection latency
		Exec.InitLatencyDelay.step( Global_dt );
		if( Exec.InitLatencyDelay.finished() == false ) then return; end
		
		action.validate();
		print( action.name .. " valid? " .. tostring( action.valid ) );
		
		-- is the action valid?
		if( action.valid == false ) then
			-- TODO Will need to provide some audio/visual feedback to the user
			action.callback();
			action.cleanup();
			aq.dequeue();
			return;
		end
		action.init();
		print( action.name .. " INITIALIZED" );
		
		-- reset at time of initialization in order to avoid race conditions for remote readiness
		Exec.resetRemote();
		Exec.ChainFinished = false;
	end
	
	local finished = action.execute();
	if( finished ) then
		print( action.name .. " FINISHED" );
		action.callback();
		Flow.unitActionPerformed( action );
		Network.sendActionFinished( action.actionID );
		action.cleanup();
				
		aq.dequeue();
	end
end


function Exec.checkRemoteStatus()
	if( Exec.ChainFinished == false ) then return true; end
	print( "CHECKING REMOTE: " .. tostring( Exec.RemoteIsReady ) );
	if( Exec.RemoteIsReady ) then return true; end
	if( Exec.WaitingForRemote ) then return false; end
--	if( Exec.RemoteIsReady == false ) then
--		Network.sendReadyRequest();
--		Exec.WaitingForRemote = true;
--	end
	
	return false;
end

function Exec.resetRemote()
	print( "RESET REMOTE" );
	Exec.RemoteIsReady = false;
end


-- Moves the indicated action to the indicated location in the queue, and shifts any
-- linked actions along with it.
function Exec.correctActionSchedule( actionID, newIndex )
	print( "CORRECT SCHEDULE LOCALLY" );
	local actions = {};
	for i = Exec.ActionQueue.length(), 1, -1 do
		local action = Exec.ActionQueue.data.get(i);
		if( action.actionID == actionID  or  action.getLinkedID() == actionID ) then
			actions[#actions+1] = action;
			Exec.ActionQueue.data.removeIndex(i);
		end
	end
	
	-- insert in reverse order
	for i, action in pairs(actions) do
		Exec.ActionQueue.insertAt( action, newIndex );
	end
end
