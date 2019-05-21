-- Collection
-- A collection is a key-value stored objects

function createCollection()
	local col = {};
	col.data = {};
	
	function col.store( key, value )
		col.data[key] = value;
	end
	
	function col.get( key )
		return col.data[key];
	end
	
	return col;
end
