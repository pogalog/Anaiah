-- Latency Fabricator

require( "flow.timer" );

function createDelay( data )
	local delay = {};
	delay.data = data;
	delay.timer = Flow.createTimer( 0.125, Network.processString );
	delay.timer.manual = true;
	
	function delay.update()
		delay.timer.step( Global_dt, delay.data );
	end
	
	function delay.finished()
		return delay.timer.finished();
	end
	
	return delay;
end