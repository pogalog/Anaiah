
-- event
function createEvent( execFunc )
	local event = {};
	event.prereqs = {};
	event.name = "Unloved event";
	event.maxExec = 0;	-- a value of 0 means no limit
	event.numExec = 0;
	event.alive = true;
	event.executed = false;
	event.execFunc = execFunc;
	event.conditionFunc = nil;

	function event.execute( target )
		if( event.alive == false ) then return; end
		if( event.numExec > event.maxExec ) then return; end
		-- check prerequisite conditions
		if( event.conditionFunc == false ) then
			return false;
		end
		event.executed = true;
		event.execFunc( target );
		return true;
	end

	function event.defaultPrereqFunc()
		for i = 1, #event.prereqs do
			if( event.prereqs[i].executed == false ) then
				return false;
			end
		end
		return true;
	end

	event.conditionFunc = event.defaultPrereqFunc;

	return event;
end
