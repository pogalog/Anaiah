-- main control

function hexCursorDigital( change )
	local cursor = LevelMap.cursor;
	
	Controller.scheme.digitalOld( change );
	local state = Controller.state;
	local button = Controller.button;
	
	if( Controller.isPressing( "Up" ) ) then
		local mv = createVec2( 0, 1 );
		
		if( Controller.isPressed( "RightShoulder" ) ) then
			mv.addLocal( createVec2( 1, 0 ) );
		end
		
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Down" ) ) then
		local mv = createVec2( 0, -1 );
		
		if( Controller.isPressed( "RightShoulder" ) ) then
			mv.addLocal( createVec2( -1, 0 ) );
		end
		
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Left" ) ) then
		local mv = createVec2( -1, 0 );
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Right" ) ) then
		local mv = createVec2( 1, 0 );
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	
	if( Controller.isPressing( "A" ) ) then
		if( cursor.highlightedTile.exists == false ) then return; end
		if( cursor.highlightedTile.occupant ~= nil ) then
			cursor.useDigitalControl();
		end
		cursor.selectTile();
	end
	
	if( Controller.isPressing( "B" ) ) then
		UIReg.close( 1 );
	end
	
end

-- TODO: Sometimes the cursor will get stuck if the stick doesn't continuously move.

function hexCursorLeftX( value )
--	Controller.scheme.analogLeftXOld();
	Controller.state.LeftX = value;
	local cursor = LevelMap.cursor;
	
	LevelMap.cursor.useAnalogControl();
	local norm = value / Controller.ANALOG_MAX;
	local x = norm;
	local y = Controller.state.LeftY / Controller.ANALOG_MAX;
	cursor.externalForce.set( x, 0, -y );
	cursor.externalForce.mulLocal( cursor.MAX_EXTERNAL_FORCE );
	
	if( x == 0 and y == 0 ) then
		cursor.useDigitalControl();
	end
end

function hexCursorLeftY( value )
--	Controller.scheme.analogLeftYOld();
	Controller.state.LeftY = value;
	local cursor = LevelMap.cursor;
	
	cursor.useAnalogControl();
	local norm = value / Controller.ANALOG_MAX;
	local x = Controller.state.LeftX / Controller.ANALOG_MAX;
	local y = norm;
	cursor.externalForce.set( x, 0, -y );
	cursor.externalForce.mulLocal( cursor.MAX_EXTERNAL_FORCE );
	
	if( x == 0 and y == 0 ) then
		cursor.useDigitalControl();
	end
end


-- camera control
function cameraX( value )
	Controller.state.RightX = value;
end

function cameraY( value )
	Controller.state.RightY = value;
end

function overrideDigital( scheme )
	scheme.digitalOld = scheme.digitalButton;
	scheme.digitalButton = hexCursorDigital;
	scheme.analogLeftXOld = scheme.leftStickX;
	scheme.analogLeftYOld = scheme.leftStickY;
	scheme.leftStickX = hexCursorLeftX;
	scheme.leftStickY = hexCursorLeftY;
	scheme.analogRightXOld = scheme.rightStickX;
	scheme.analogRightYOld = scheme.rightStickY;
	scheme.rightStickX = cameraX;
	scheme.rightStickY = cameraY;
end



