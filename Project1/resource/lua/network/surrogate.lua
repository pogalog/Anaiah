-- Surrogate Networking (for single player)
Network = {};
Network.Established = false;


Network.processString = function( string )
end

function Network.createNetwork( userdata )
	local netwk = {};
	netwk.userdata = userdata;
	netwk.type = -1;
	
	return netwk;
end
	
function Network.isServer()
	return true;
end

function Network.measureLatency() end

function Network.receive() end
function Network.isAIEligible() return true; end


-- SEND Functions
function Network.sendActionFinished() end
function Network.sendReady()
	Network.remoteReady();
end

function Network.remoteReady()
	Exec.remoteReady();
end

function Network.requestApproval( actionList )
	if( actionList.length() == 0 ) then return; end
	local action = actionList.get(1);
	Exec.actionApproved( action.actionID, 0 );
	Exec.RemoteIsReady = true;
end

Network.sendLatencyRequest = function()
	Network.responded = true;
end

Network.sendActionRequest = function( id, timestamp )
	actionApproved( id );
end

Network.sendActionStart = function( actionSet )
end

Network.sendActionCompleted = function()
end
