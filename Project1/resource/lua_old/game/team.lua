-- team
require( "game.unit" );
require( "game.list" );
require( "game.ai.tactical_strategy" );

function createTeam( name )
	local team = {};
	team.desc = "Team";
	team.units = createList();
	team.id = 0;
	team.name = name;
	team.userdata = nil;
	team.friendlyTeams = createList();
	team.hostileTeams = createList();
	team.aiControlled = false;
	team.ai = {};
	team.ai.strategy = createTacticalStrategy();
	
	-- conditions
	team.conditions = {};
	team.conditions.success = {};
	team.conditions.success.description = "";
	team.conditions.success.func = nil;
	team.conditions.failure = {};
	team.conditions.failure.description = "";
	team.conditions.failure.func = nil;
	
	-- FUNCTIONS
	function team.addUnitByName( unit, name )
		team.units[name] = unit;
	end
	
	function team.addUnit( unit )
		team.units[unit.name] = unit;
		team.units.add( unit );
		unit.team = team;
	end
	
	function team.getUnit( name )
		return team.units[name];
	end
	
	function team.containsUnit( unit )
		if( unit == nil ) then return false; end
		
		for i = 1, team.units.length() do
			local u = team.units.get(i);
			if( u.name == unit.name ) then return true; end
		end
		return false;
	end
	
	function team.getUnitByID( id )
		for i = 1, team.units.length() do
			local unit = team.units.get(i);
			if( unit.unitID == id ) then return unit; end
		end
		return nil;
	end
	
	function team.clearUnits()
		team.units = {};
	end
	
	function team.nextUnit( start )
		local num = team.units.length();
		for i = start, start+num do
			local j = i;
			if( i > num ) then j = j - num; end
			local u = team.units.get(j);
			if( u ~= nil and u.available() ) then return u; end
		end
		return nil;
	end
	
	return team;
end

function loadTeam( teamName )
	local inp = assert( io.open( './resource/team/'..teamName..'.team', "r" ) );
	local team = createTeam( inp:read( "*l" ) );
	local colorString = inp:read( "*l" );
	team.id = tonumber( inp:read( "*l" ) );
  
	-- team members
	while( true ) do
		local unitName = inp:read( "*l" );
		if( unitName == nil ) then break; end
		local unit = PF.readUnitFromDisk( unitName );
		team.units.add( unit );
		unit.team = team;
	end
  
	assert( inp:close() );
	return team;
end
