-- Flow Timer

function createTimer( t0, callback )
	local timer = {};
	timer.t0 = t0;
	timer.time = t0;
	timer.callback = callback;
	timer.paused = false;
	timer.manual = false;
	
	
	function timer.reset()
		timer.time = timer.t0;
		timer.paused = false;
	end
	
	function timer.step( dt, ... )
		if( timer.paused ) then return; end
		timer.time = timer.time - dt;
		
		if( timer.time < 0 ) then
			if( timer.manual ) then
				timer.paused = true;
			end
			timer.callback( ... );
			timer.reset();
		end
	end
	
	
	return timer;
end