-- Game Phase

--[[ Game phases will determine which players are allowed to control their units.
A phase may allow for one or more players to act simultaneously. In code, the Game
Phase is responsible for assigning control schemes (through UI elements).
]]


function createGameFlow()
	local flow = {};
	flow.phases = createList();
	flow.activePhase = nil;
	flow.activeIndex = 1;
	
	function flow.addPhase( phase )
		flow.phases.add( phase );
	end
	
	function flow.nextPhase()
		-- shutdown previous phase
		flow.activePhase.yield();
		
		-- enter new phase
		flow.activeIndex = flow.activeIndex % flow.phases.length() + 1;
		flow.activePhase = flow.phases.get( flow.activeIndex );
		flow.activePhase.makeActive();
	end
	
	
	return flow;
end


function createPhase()
	local phase = {};
	phase.activePlayers = createList();
	phase.UIstack = nil;
	
	-- phase setup
	function phase.makeActive()
		
	end
	
	
	-- clean up once phase is finished
	function phase.yield()
		
	end
	
	return phase;
end
