-- Action Queue
require( "action.unit_action" );


-- A queue intended to provide an order for executing player actions,
-- once they are committed. The queue.temp list is used to store actions
-- while players are still deciding. The temp list is then fed into
-- queue.data for processing upon committal.
function createActionQueue()
	local queue = {};
	queue.data = createList();
	queue.temp = createList();
	
	-- custom functions
	function queue.finished() end
	
	
	function queue.enqueue( action )
		queue.temp.add( action );
	end
	
	function queue.dequeue()
		queue.temp.removeFirst();
	end
	
	function queue.clear()
		queue.temp.clear();
	end
	
	function queue.commit()
		queue.data.addList( queue.temp );
		queue.temp = createList();
	end
	
	function queue.isBusy()
		return queue.data.length() > 0;
	end
	
	
	function queue.execute()
		if( queue.data.length() == 0 ) then return; end
		
		local action = queue.data.first();
		if( action.delay > 0 ) then
			action.delay = action.delay - 1;
			return;
		end
		
		if( action.initialized == false ) then
			action.init();
		end
		
		local finished = action.execute();
		if( finished ) then
			-- perform callback
			action.callback();
			unitActionPerformed( action );
			
			-- remove from queue
			queue.data.removeIndex( 1 );
			
			if( queue.data.length() == 0 ) then
				queue.finished();
			end
		end
	end
	
	
	return queue;
end






