-- Action Event
--[[This structure provides a way to execute timed events within an action.
	It is intended primarily for use in animations for synchronizing an event
	with gestures within the animation.
]]

function createActionEvent( action, time, func, periodic )
	local event = {};
	event.action = action;
	event.time = time;
	event.func = func;
	event.periodic = (periodic == true) and true or false;
	event.period = time;
	event.executed = false;
	
	function event.execute( dt )
		if( event.executed ) then return true; end
		
		event.time = event.time - dt;
		if( event.time <= 0 ) then
			event.executed = true;
			event.func();
			return true;
		end
		
		return false;
	end
	
	function event.reset()
		if( event.periodic ) then
			event.time = event.period;
			event.executed = false;
		end
	end
	
	return event;
end