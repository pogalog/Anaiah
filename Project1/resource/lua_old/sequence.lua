-- control sequence
require( "game.list" );

MANUAL_CONTROL = 1;
AUTOMATED_CONTROL = 2;

-- The Control Stack
function createControlStack( controller )
	local cs = {};
	cs.controller = controller;
	cs.data = createList();
	
	-- push a new CP to the stack, and give it control
	function cs.push( controlType, controlScheme )
		print( "PUSH" );
		local controlPoint = createControlPoint( controlType, controlScheme );
		cs.data.add( controlPoint );
		controller.setScheme( controlPoint.controlScheme );
		print( "len: " .. cs.data.length() );
	end
	
	function cs.pushCP( controlPoint )
		cs.data.add( controlPoint );
		controller.setScheme( controlPoint.controlScheme );
	end
		
	
	function cs.top()
		print( cs.data.length() );
		return cs.data.last();
	end
	
	-- pop a number (count) of CPs from the stack, and give control to the new "top" CP
	function cs.pop( count )
		if( cs.data.length() == 1 ) then return; end
		if( cs.data.length() <= count ) then
			generateWarning( "Attempted to pop " .. count .. " elements from stack of size " .. cs.data.length(), "Sequence.lua::createControlStack::pop" );
			cs.clear();
			return;
		end
		
		for i = cs.data.length(), cs.data.length()-(count-1), -1 do
			print( 'popping' );
			local cp = cs.data.get(i);
			cp.popAction();
			cs.data.removeIndex(i);
		end
		
		controller.setScheme( cs.top().controlScheme );
	end
	
	function cs.clear()
		cs.pop( cs.data.length()-1 );
	end
	
	
	
	-- add the default Control Point
	cs.defaultControlPoint = createControlPoint( MANUAL_CONTROL, ControlSchemes['SelectUnit'] );
	cs.pushCP( cs.defaultControlPoint );
	
	
	return cs;
end


function createControlPoint( controlType, controlScheme )
	local cp = {};
	cp.controlType = controlType;
	cp.controlScheme = controlScheme;
	cp.finished = false;
	
	function cp.isFinished()
		return finished;
	end
	
	-- a function to be called by the stack when this control point is popped
	function cp.popAction() end
	
	
	return cp;
end





-- create the stack
ControlStack = createControlStack( Controller );
