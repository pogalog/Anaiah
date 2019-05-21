-- Action Queue
require( "structure.list" );

function createQueue()
	local queue = {};
	queue.data = createList();
	
	
	function queue.enqueue( item )
		queue.data.add( item );
	end
	
	function queue.sortInsert( item, key )
		for i = 1, queue.length() do
			local ii = queue.data.get(i);
			if( item[key] < ii[key] ) then
				queue.data.insert( item, i );
				return i;
			end
		end
		queue.data.add( item );
		return queue.length();
	end
	
	function queue.insertAt( item, index )
		queue.data.insert( item, index );
	end
	
	function queue.dequeue()
		local temp = queue.data.get(1);
		queue.data.removeFirst();
		return temp;
	end
	
	function queue.removeLast()
		queue.data.removeLast();
	end
	
	
	function queue.peek()
		return queue.data.get(1);
	end
	
	function queue.peekAt( index )
		return queue.data.get( index );
	end
	
	function queue.peekLast()
		return queue.data.get( queue.data.length() );
	end
	
	function queue.clear()
		queue.data.clear();
	end
	
	function queue.length()
		return queue.data.length();
	end
	
	function queue.isEmpty()
		return queue.data.length() == 0;
	end
	
	
	return queue;
end






