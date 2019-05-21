require( "game.event" );

-- trigger

-- Canonical event condition (cec)
TRIGGER_INIT	= 1;
TRIGGER_ADD		= 2;
TRIGGER_PERSIST = 3;
TRIGGER_REMOVE	= 4;
TRIGGER_DEPART	= 5;


function createTrigger( owner, targets, testFunc, data )
	local trigger = {};
	trigger.name = "Pointless trigger";
	trigger.owner = owner;
	trigger.targets = targets;
	if( trigger.targets == nil ) then
		trigger.targets = {};
	end
	trigger.data = data;
	trigger.activeTargets = {};
	trigger.triggerType = triggerType;
	trigger.testFunc = testFunc;

	-- event lists
	trigger.events = {};

	trigger.events.init = {};
	trigger.events[TRIGGER_INIT] = trigger.events.init;
	trigger.events.init.length = 0;

	trigger.events.add = {};
	trigger.events[TRIGGER_ADD] = trigger.events.add;
	trigger.events.add.length = 0;

	trigger.events.persist = {};
	trigger.events[TRIGGER_PERSIST] = trigger.events.persist;
	trigger.events.persist.length = 0;

	trigger.events.remove = {};
	trigger.events[TRIGGER_REMOVE] = trigger.events.remove;
	trigger.events.remove.length = 0;

	trigger.events.depart = {};
	trigger.events[TRIGGER_DEPART] = trigger.events.depart;
	trigger.events.depart.length = 0;



	-- FUNCTIONS
	function trigger.addEvent( event, cec )
		local num = trigger.events[cec].length;
		trigger.events[cec].length = num + 1;
		trigger.events[cec][num+1] = event;
	end

	function trigger.getAllEvents()
		local ret = {};
		for i = 1, #trigger.events.init do
			ret[#ret+1] = trigger.events.init[i];
		end
		for i = 1, #trigger.events.add do
			ret[#ret+1] = trigger.events.add[i];
		end
		for i = 1, #trigger.events.persist do
			ret[#ret+1] = trigger.events.persist[i];
		end
		for i = 1, #trigger.events.remove do
			ret[#ret+1] = trigger.events.remove[i];
		end
		for i = 1, #trigger.events.depart do
			ret[#ret+1] = trigger.events.depart[i];
		end
		return ret;
	end


	--[[ The triggers executes its testFunc which returns a list of acquired targets.
		 It is then responsible for comparing the returned list with the list of activeTargets
		 to determine which CECs have been satisfied.]]
	function trigger.test()
		local targs = trigger.testFunc( owner, targets, data );
		local initPossible = #trigger.activeTargets == 0;

		-- TODO: determine which CECs are satisfied, call fire for each one
		local added = getNewTargets( targs, trigger.activeTargets );

		-- check for init
		if( initPossible and #added > 0 ) then
			for k, v in pairs( added ) do
				trigger.fire( TRIGGER_INIT, v );
			end
		end
		-- check for add
		for k, v in pairs( added ) do
			trigger.fire( TRIGGER_ADD, v );
		end

		-- check for remove
		local removed = getRemovedTargets( targs, trigger.activeTargets );
		for k, v in pairs( removed ) do
			trigger.fire( TRIGGER_REMOVE, v );
		end

		-- check for depart
		if( #targs == 0 ) then
			for k, v in pairs( removed ) do
				trigger.fire( TRIGGER_DEPART, v );
			end
		end

		-- check for persist
		local persisted = getPeristentTargets( targs, trigger.activeTargets );
		for k, v in pairs( persisted ) do
			trigger.fire( TRIGGER_PERSIST, v );
		end

		-- set the current list of activeTargets to the returned list
		activeTargets = targs;
	end

	-- Fires the trigger and calls the associated events
	function trigger.fire( cec, target )
		for i = 1, trigger.events[cec].length do
			trigger.events[cec][i].execute( target );
		end
	end

	return trigger;
end

function getNewTargets( newList, oldList )
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

function getRemovedTargets( newList, oldList )
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

function getPeristentTargets( newList, oldList )
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

function contains( list, value )
	for k, v in pairs( list ) do
		if( v == value ) then return true; end
	end
	return false;
end
