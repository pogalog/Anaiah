-- Flow Timer
require("flow.main");



function Flow.createTimer(t0, callback)
	local timer = {};
	timer.t0 = t0;
	timer.time = t0;
	
	local function f() end
	
	if( callback == nil ) then
		timer.callback = f;
	else
		timer.callback = callback;
	end
	
	timer.paused = false;
	timer.manual = false;
	
	
	function timer.set(t0)
		timer.t0 = t0;
	end
	
	function timer.reset()
		timer.time = timer.t0;
		timer.paused = false;
	end
	
	function timer.step(dt, ...)
		if( timer.paused ) then return; end
		timer.time = timer.time - dt;
		
		if( timer.time < 0 ) then
			timer.callback(...);
			
			if( timer.manual ) then
				timer.paused = true;
				return;
			end
			
			timer.reset();
		end
	end
	
	function timer.finished()
		return timer.time <= 0;
	end
	
	
	return timer;
end
