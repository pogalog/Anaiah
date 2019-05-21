-- contract
function createContract( event, option, func )
	local contract = {}
	contract.event = event;



	-- Utility functions
	local function getNewTargets( newList, oldList )
		local added = {};
		local n = 0;
		for k, v in pairs( newList ) do
			if( contains( oldList, v ) == false ) then
				n = n + 1;
				added[n] = v;
			end
		end
		return added;
	end

	local function getRemovedTargets( newList, oldList )
		local removed = {};
		local n = 0;
		for k, v in pairs( oldList ) do
			if( contains( newList, v ) == false ) then
				n = n + 1;
				removed[n] = v;
			end
		end
		return removed;
	end

	local function getPeristentTargets( newList, oldList )
		local persisted = {};
		local n = 0;
		for k, v in pairs( oldList ) do
			if( contains( newList, v ) ) then
				n = n + 1;
				persisted[n] = v;
			end
		end
		return persisted;
	end

	local function contains( list, value )
		for k, v in pairs( list ) do
			if( v == value ) then return true; end
		end
		return false;
	end

	-- Pre-defined test functions
	function contract.initTest( oldTargets, newTargets )
		return true;
	end

	function contract.addTest( oldTargets, newTargets )
		return true;
	end

	function contract.removeTest( oldTargets, newTargets )
		return true;
	end

	function contract.departTest( oldTargets, newTargets )
		return true;
	end

	function contract.persistTest( oldTargets, newTargets )
		return true;
	end


	return contract;
end
