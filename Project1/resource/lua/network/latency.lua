-- Network System Internal
-- Perform latency measurements



-- constants
Network.NUM_TESTS = 3;

-- set initial latency to 10 seconds (or no connection)
Network.latency = 10000;
Network.latencySum = 0;
Network.latencyMin = 0;
Network.latencyMax = 0;
Network.latencyT0 = 0;
Network.responded = false;
Network.reported = false;

function Network.measureLatency( delay, resetTimer )
	local ping1Task = Exec.createTask( delay );
	ping1Task.checkStatus = Network.latencyResponseReceived;
	ping1Task.func = Network.requestLatency;
	ping1Task.cleanup = Network.resetResponse;
	ping1Task.name = "Ping 1";
	
	local ping2Task = Exec.createTask();
	ping2Task.checkStatus = Network.latencyResponseReceived;
	ping2Task.func = Network.requestLatency;
	ping2Task.cleanup = Network.resetResponse;
	ping2Task.name = "Ping 2";
	
	local ping3Task = Exec.createTask();
	ping3Task.checkStatus = Network.latencyResponseReceived;
	ping3Task.func = Network.requestLatency;
	ping3Task.cleanup = Network.resetResponse;
	ping3Task.name = "Ping 3";
	
	local computeTask = Exec.createTask();
	computeTask.func = Network.computeAverageLatency;
	computeTask.cleanup = Network.resetLatencyMeasurement;
	computeTask.name = "Compute";
	
	local resetTask = nil;
	if( resetTimer ) then
		resetTask = Exec.createTask();
		resetTask.func = Network.syncTimers;
		resetTask.name = "Reset";
	end
	
	local restartTask = Exec.createTask();
	restartTask.func = Network.restartMeasurement;
	restartTask.name = "Restart";
	
	Exec.ats.addSequence( Exec.createTaskSequence( ping1Task, ping2Task, ping3Task, computeTask, resetTask, restartTask ) );
end

function Network.computeAverageLatency()
	-- divide by 2 to get the one-way trip time
	Network.latency = Network.latencySum / (2 * Network.NUM_TESTS);
	Global_Latency_Offset = Network.latency;
	print( "latency: " .. Network.latency );
end

function Network.latencyResponseReceived()
	if( Network.responded ) then
		local currentLatency = (Global_time - Network.latencyT0);
		Network.latencySum = Network.latencySum + currentLatency;
		
		if( currentLatency > Network.latencyMax ) then
			Network.latencyMax = currentLatency;
		elseif( currentLatency < Network.latencyMin ) then
			Network.latencyMin = currentLatency;
		end
	end
	return Network.responded;
end

function Network.resetLatencyMeasurement()
	Network.latencySum = 0;
	Network.latencyMin = 100000;
	Network.latencyMax = 0;
	Network.responded = false;
end

function Network.restartMeasurement()
	Network.measureLatency( 5.0, false );
end

function Network.resetResponse()
	Network.responded = false;
end

function Network.resetLatencyReport()
	Network.reported = false;
end

function Network.isLatencyReported()
	return Network.reported;
end

function Network.requestLatency()
	Network.latencyT0 = Global_time;
	Network.sendLatencyRequest();
end

function Network.syncTimers()
	Network.sendTimerReset();
	Network.timerReset( Network.latency );
end

function Network.sendTimerReset()
	local buffer = Binary.createBuffer();
	writeByte( buffer, Network.TIMER_RESET );
	Network.sendString( buffer );
end

function Network.sendLatencyRequest()
	local buffer = Binary.createBuffer();
	writeByte( buffer, Network.LATENCY );
	Network.sendString( buffer );
end

function Network.sendLatencyResponse()
	local buffer = Binary.createBuffer();
	writeByte( buffer, Network.LATENCY_RESPONSE );
	Network.sendString( buffer );
end


function Network.timerReset( latencyOffset )
	Global_T0 = Global_clock;
	Global_time = Global_clock - latencyOffset;
end
