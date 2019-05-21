-- Network System Internal
-- Communicates bi-directionally with the host program



-- Processing constants
Network.LATENCY = 1;
Network.LATENCY_RESPONSE = 2;
Network.LATENCY_REPORT = 3;
Network.TIMER_RESET = 4;
Network.ACTION_REQUESTED = 5;
Network.ACTION_APPROVED = 6;
Network.ACTION_READY = 7;
Network.ACTION_READY_REQUEST = 8;
Network.REMOTE_WAIT = 9;
Network.SCHEDULE_CORRECTION = 10;
Network.SCHEDULE_CONFIRMED = 11;
Network.PHASE_CHANGE = 12;



function Network.processString( string )
	if( string == nil ) then return; end
	if( string.len( string ) == 0 ) then return; end
	
	Network.Buffer.setData( string );
	local messageType = readByte( Network.Buffer );
	if( messageType == Network.LATENCY ) then
		Network.sendLatencyResponse();
		return;
	elseif( messageType == Network.LATENCY_RESPONSE ) then
		Network.responded = true;
		return;
	elseif( messageType == Network.LATENCY_REPORT ) then
		Network.reported = true;
		return;
	elseif( messageType == Network.TIMER_RESET ) then
		Network.timerReset(0);
		return;
	elseif( messageType == Network.ACTION_REQUESTED ) then
		Network.remoteRequest( Network.Buffer );
		return;
	elseif( messageType == Network.ACTION_APPROVED ) then
		local actionID = readInt( Network.Buffer );
		local remoteIndex = readInt( Network.Buffer );
		Network.actionApproved( actionID, remoteIndex );
		return;
	elseif( messageType == Network.ACTION_READY ) then
		Network.remoteReady();
		return;
	elseif( messageType == Network.ACTION_READY_REQUEST ) then
		Network.remoteReadyRequest();
		return;
	elseif( messageType == Network.REMOTE_WAIT ) then
		Network.remoteWait();
		return;
	elseif( messageType == Network.SCHEDULE_CORRECTION ) then
		local actionID = readByte( Network.Buffer );
		local actionIndex = readInt( Network.Buffer );
		Network.scheduleCorrection( actionID, actionIndex );
		return;
	elseif( messageType == Network.PHASE_CHANGE ) then
		Network.processPhaseChange( string );
		return;
	elseif( messageType == Network.SCHEDULE_CONFIRMED ) then
		Network.scheduleConfirmed( Network.Buffer );
		return;
	end
end