-- list

function createList()
	
	local list = {};
	list.data = {};
	list.names = {};
	list.len = 0;

	-- FUNCTIONS
	function list.add( item, key )
    if( item == nil ) then return; end
		table.insert( list.data, item );
		if( key ~= nil ) then
			list.names[key] = item;
		end
		list.len = list.len + 1;
	end
  
	function list.forceAdd( item )
		list.data[list.len+1] = item;
		list.len = list.len + 1;
	end
	
	function list.key( key )
		if( key == nil ) then return nil; end
		return list.names[key];
	end
  
	-- truncates the list at the specified length
	function list.setLength( newLength )
		if( list.len <= newLength ) then return; end
		while list.len > newLength do
			list.removeIndex( newLength+1 );
		end
	end
	
	function list.first()
		return list.data[1];
	end
	
	function list.last()
		return list.data[list.len];
	end
	
	
	-- checks to make sure this item is not already in the list before adding
	function list.addUnique( item )
		if( list.contains( item ) ) then return; end
		list.add( item );
	end
  
	function list.addItems( ... )
		for i,v in ipairs( arg ) do
			list.add( v );
		end
	end
    
	function list.addList( alist )
		for i = 1, alist.len do
			list.add( alist.data[i] );
		end
	end
  
	function list.sortAddAscend( item, value )
		local length = list.len;
		for i = 1, length do
			local ii = list.get(i);
			if( value < ii._sortVal ) then
			item._sortVal = value;
			list.insert( item, i );
			return;
			end
		end
    
		-- add item to end of list
		item._sortVal = value;
		list.add( item );
	end
	
	function list.sortAddDescend( item, value )
		local length = list.len;
		for i = 1, length do
			local ii = list.get(i);
			if( value > ii._sortVal ) then
				item._sortVal = value;
				list.insert( item, i );
				return;
			end
		end

		-- add item to beginning of list
		item._sortVal = value;
		list.add( item );
	end
  
  
  function list.insert( item, index )
		table.insert( list.data, index, item );
		list.len = list.len + 1;
  end

	function list.clear()
		list.data = nil;
		list.data = {};
    list.len = 0;
	end
	
	function list.removeLast()
		list.removeIndex( list.length() );
	end
	
	function list.removeFirst()
		list.removeIndex( 1 );
	end
	
	function list.remove( item )
		for i = 1, list.len do
			if( list.data[i] == item ) then
				list.removeIndex( i );
			end
		end
	end
  
  function list.removeIndex( ind )
		table.remove( list.data, ind );
		list.len = list.len - 1;
  end
  
  function list.removeRange( start, fin )
    local dat = {};
    
    for i = 1, (start-1) do
      dat[i] = list.data[i];
    end
    
    local size = fin - start + 1;
    for i = (fin+1), list.len do
      dat[i-size] = list.data[i];
    end
    list.data = dat;
    list.len = list.len - (fin-start);
  end

	function list.get( index )
		return list.data[index];
	end
  
  function list.getIndex( value )
    for i = 1, list.len do
      if( list.data[i] == value ) then return i; end
    end
    return nil;
  end

	function list.print()
		for i = 1, list.len do
			print( i, list.data[i] );
		end
	end
	
	local function stdEqual( a, b )
		return a == b;
	end
	
	local function custEqual( a, b )
		return a.equals( b );
	end

	function list.contains( item )
		return list.find( item ) > 0;
	end
	
	-- TODO use metatables to override the equality operator
	function list.find( item )
		local equalFunc = item.equals ~= nil and custEqual or stdEqual;
		for i = 1, list.len do
			if( equalFunc( item, list.data[i] ) ) then
				return i;
			end
		end
		return 0;
	end

	function list.length()
		return list.len;
	end

	return list;
end
