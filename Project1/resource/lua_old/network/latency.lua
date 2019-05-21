-- Latency measurements
require( "network.net_proc" );


-- constants
net.NUM_TESTS = 3;

-- set initial latency to 10 seconds (or no connection)
net.latency = 10000;
net.latencySum = 0;
net.latencyMin = 0;
net.latencyMax = 0;
net.latencyT0 = 0;
net.responded = false;
net.reported = false;

function net.measureLatency( delay, resetTimer )
	local ping1Task = ats.createTask( delay );
	ping1Task.checkStatus = net.latencyResponseReceived;
	ping1Task.func = net.requestLatency;
	ping1Task.cleanup = net.resetResponse;
	
	local ping2Task = ats.createTask();
	ping2Task.checkStatus = net.latencyResponseReceived;
	ping2Task.func = net.requestLatency;
	ping2Task.cleanup = net.resetResponse;
	
	local ping3Task = ats.createTask();
	ping3Task.checkStatus = net.latencyResponseReceived;
	ping3Task.func = net.requestLatency;
	ping3Task.cleanup = net.resetResponse;
	
	local computeTask = ats.createTask();
	computeTask.func = net.computeAverageLatency;
	computeTask.cleanup = net.resetLatencyMeasurement;
	
	local resetTask = nil;
	if( resetTimer ) then
		resetTask = ats.createTask();
		resetTask.func = net.syncTimers;
	end
	
	ATS.addSequence( ats.createTaskSequence( ping1Task, ping2Task, ping3Task, computeTask, resetTask ) );
end

function net.computeAverageLatency()
	-- divide by 2 to get the one-way trip time
	net.latency = net.latencySum / (2 * net.NUM_TESTS);
	net.measureLatency( 5.0 );
	Global_Latency_Offset = net.latency;
end

function net.latencyResponseReceived()
	if( net.responded ) then
		local currentLatency = (Global_time - net.latencyT0)*1e-6;
		net.latencySum = net.latencySum + currentLatency;
		
		if( currentLatency > net.latencyMax ) then
			net.latencyMax = currentLatency;
		elseif( currentLatency < net.latencyMin ) then
			net.latencyMin = currentLatency;
		end
	end
	return net.responded;
end

function net.resetLatencyMeasurement()
	net.latencySum = 0;
	net.latencyMin = 100000;
	net.latencyMax = 0;
	net.responded = false;
end

function net.resetResponse()
	net.responded = false;
end

function net.resetLatencyReport()
	net.reported = false;
end

function net.isLatencyReported()
	return net.reported;
end

function net.requestLatency()
	net.latencyT0 = Global_time;
	net.sentLatencyRequest()
end

function net.syncTimers()
	net.sendTimerReset();
	net.timerReset( net.latency );
end

function net.sendTimerReset()
	local buffer = net.createBuffer();
	writeByte( buffer, net.TIMER_RESET );
	net.sendString( buffer );
end

