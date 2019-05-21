-- Animation System


Anim = {};


-- unit constants
Anim.ANIMATE_UNIT_IDLE = 0;
Anim.ANIMATE_UNIT_MOVE = 1;
Anim.ANIMATE_UNIT_ATTACK = 2;
Anim.ANIMATE_UNIT_USE_ITEM = 3;
Anim.ANIMATE_UNIT_TAKE_DAMAGE = 4;

-- prop constants
Anim.ANIMATE_DEFAULT_STATE = 5;
Anim.ANIMATE_ACTIVE_STATE = 6;
Anim.ANIMATE_OTHER_STATE = 7;


-- 'state' is specified by one of the constants defined above
function Anim.createUnitAnimation( filename, unit, state )
	local animation = {};
	animation.filename = filename;
	animation.unit = unit;
	animation.state = state;
	animation.userdata = nil;
	animation.loop = false;
	animation.elapsedTime = 0;
	local loop, endTime = Unit_loadAnimation( unit.userdata, filename, state );
	animation.endTime = endTime;
	animation.loop = loop;
	unit.addAnimation( animation );
	
	
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


function Anim.createPropAnimation( prop, state )
	local animation = {};
	animation.prop = prop;
	animation.state = state;
	animation.userdata = nil;
	animation.elapsedTime = 0;
	animation.loop = false;
	
	return animation;
end