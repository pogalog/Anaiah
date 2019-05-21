-- Asynchronous Task Sequence (ATS)
require( "game.list" );

_G.ats = {};

function ats.createTaskSequenceList()
	local sequenceList = createList();
	
	function sequenceList.addSequence( sequence )
		sequenceList.add( sequence );
	end
	
	function sequenceList.executeTasks()
		for i = sequenceList.length(), 1, -1 do
			local sequence = sequenceList.get(i);
			if( sequence.isFinished() ) then
				sequenceList.removeIndex(i);
				goto continue;
			end
			
			sequence.execute();
			::continue::
		end
	end
	
	return sequenceList;
end


function ats.createTaskSequence( ... )
	local sequence = createList();
	
	for k,v in pairs( {...} ) do
		if( v ~= nil and v.checkStatus ~= nil ) then
			sequence.add( v );
		end
	end
	
	function sequence.isFinished()
		return sequence.length() == 0;
	end
	
	function sequence.execute()
		local task = sequence.get(1);
		if( task.checkStatus() ) then
			task.cleanup();
			sequence.removeIndex(1);
			if( sequence.isFinished() ) then return; end
			task = sequence.get(1);
		end
		task.execute();
	end
	
	return sequence;
end


function ats.createTask( delay )
	local task = {};
	task.maxExecutions = 1;
	task.numExecutions = 0;
	task.delay = 0;
	if( delay ~= nil ) then
		task.delay = delay;
	end
	
	function task.execute()
		if( task.numExecutions >= task.maxExecutions ) then return; end
		if( task.delay > 0 ) then
			task.delay = task.delay - Global_dt;
			return;
		end
		
		task.numExecutions = task.numExecutions + 1;
		task.func();
	end
	
	-- to be overridden
	function task.checkStatus() return true; end
	function task.func() end
	function task.cleanup() end
	
	return task;
end


-- utility for scheduling a single task
function ats.scheduleTask( task, delay )
	task.delay = delay;
	local sequence = ats.createTaskSequence( task );
	ATS.addSequence( sequence );
end