-- animation

-- unit constants
ANIMATE_UNIT_IDLE = 0;
ANIMATE_UNIT_MOVE = 1;
ANIMATE_UNIT_ATTACK = 2;
ANIMATE_UNIT_USE_ITEM = 3;
ANIMATE_UNIT_TAKE_DAMAGE = 4;

-- prop constants
ANIMATE_DEFAULT_STATE = 5;
ANIMATE_ACTIVE_STATE = 6;
ANIMATE_OTHER_STATE = 7;


-- 'state' is specified by one of the constants defined above
function createUnitAnimation( filename, unit, state )
	local animation = {};
	animation.unit = unit;
	animation.state = state;
	animation.userdata = nil;
	animation.loop = false;
	animation.elapsedTime = 0;
	local loop, endTime = Unit_loadAnimation( unit.userdata, filename, state );
	animation.endTime = endTime;
	animation.loop = loop;
	
	
	function animation.callback_finished() end
	function animation.callback_looped( overage ) end
	
	function animation.update( dt )
		animation.elapsedTime = animation.elapsedTime + dt;
		if( animation.loop ) then
			local over = animation.elapsedTime - animation.endTime;
			if( over > 0 ) then
				animation.callback_looped( over );
				animation.elapsedTime = over;
			end
		else
			if( animation.elapsedTime > animation.endTime ) then
				animation.callback_finished();
			end
		end
	end
	
	function animation.isFinished()
		if( animation.loop == true ) then return false; end
		return animation.elapsedTime > animation.endTime;
	end
	
	function animation.reset()
		animation.elapsedTime = 0;
	end
	
	return animation;
end


function createPropAnimation( prop, state )
	local animation = {};
	animation.prop = prop;
	animation.state = state;
	animation.userdata = nil;
	animation.elapsedTime = 0;
	animation.loop = false;
	
	return animation;
end
