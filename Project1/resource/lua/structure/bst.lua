-- Binary Search Tree

function createBST( criteria )
	local bst = {};
	bst.root = nil;
	bst.criteria = criteria;
	
	
	-- insert
	local function insert( node, data )
		if( node == nil ) then return createBSTNode( data ); end
		
		if( data[criteria] < node.data[criteria] ) then
			node.left = insert( node.left, data );
			node.left.parent = node;
		else
			node.right = insert( node.right, data );
			node.right.parent = node;
		end
		
		return node;
	end
	
	function bst.insert( data )
		bst.root = insert( root, data );
	end
	
	
	-- remove
	local function remove( node, data )
		local n = nil;
		
		if( data[criteria] < node.data[criteria] ) then
			n = remove( node.left, data );
			node.left = n;
			if( n ~= nil ) then n.parent = node; end
		elseif( data[criteria] > node.data[criteria] ) then
			n = remove( node.right, data );
			node.right = n;
			if( n ~= nil ) then n.parent = node; end
		else
			if( node.left == nil and node.right == nil ) then return nil; end
			if( node.left == nil ) then return node.right; end
			if( node.right == nil ) then return node.left end
			
			local temp = node.right;
			while( temp.left ~= nil ) do
				temp = temp.left;
			end
			temp.left = node.left;
			node.left.parent = temp;
			return node.right;
		end
	end
	
	function bst.remove( data )
		bst.root = remove( root, data );
	end
	
	
	-- count
	local function count( node )
		if( node == nil ) then return 0; end
		local num = 1;
		num = num + count( node.left );
		num = num + count( node.right );
		
		return num;
	end
	
	function bst.count()
		return count( root );
	end
	
	
	-- has
	local function has( node, data )
		if( node == nil ) then return false; end
		if( node.data[criteria] == data[criteria] ) then return true; end
		if( data[criteria] < node.data[criteria] ) then return has( node.left, data ); end
		if( data[criteria] > node.data[criteria] ) then return has( node.right, data ); end
		
		return false;
	end
	
	function bst.has( value )
		return has( root, value );
	end
	
	
	-- min
	function bst.getMinValue()
		local node = root;
		while( node.left ~= nil ) do
			node = node.left;
		end
		
		return node.data;
	end
	
	-- max
	function bst.getMaxValue()
		local node = root;
		while( node.right ~= nil ) do
			node = node.right;
		end
		
		return node.data;
	end
	
	
	return bst;
end


function createBSTNode( data )
	local node = {};
	node.data = data;
	node.parent = nil;
	node.left = nil;
	node.right = nil;
	
	return node;
end