-- AI Controller


function Game.createAIController( team )
	local aic = {};
	aic.team = team;
	team.aiControlled = true;
	team.controller = aic;
	
	
	function aic.selectUnit()
		for i = 1, aic.team.units.length() do
			local unit = aic.team.units.get(i);
			if( unit.isAvailable() ) then
				return unit;
			end
		end
	end
	
	
	function aic.computeActionForUnit( unit )
		local action = {};
		
		
		return action;
	end
	
	return aic;
end