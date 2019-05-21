-- Controller processing
require( "input.main" );




-- main control
function hexCursorDigital( change )
	local cursor = LevelMap.cursor;
	
	Controller.scheme.digitalOld( change );
	local state = Controller.state;
	local button = Controller.button;
	local grid = LevelMap.grid;
	
	if( Controller.isPressing( "Up" ) ) then
		local cf = Vec3_new( Camera.forward.x, 0, Camera.forward.y );
		local mv = grid.getGridDirectionFromWorldVector( cf );
		
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Down" ) ) then
		local cb = Vec3_new( -Camera.forward.x, 0, -Camera.forward.y );
		local mv = grid.getGridDirectionFromWorldVector( cb );
		
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Left" ) ) then
		local cl = Vec3_new( -Camera.right.x, 0, -Camera.right.y );
		local mv = grid.getGridDirectionFromWorldVector( cl );
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	if( Controller.isPressing( "Right" ) ) then
		local cr = Vec3_new( Camera.right.x, 0, Camera.right.y );
		local mv = grid.getGridDirectionFromWorldVector( cr );
		LevelMap.cursor.useDigitalControl();
		LevelMap.moveCursor( mv );
	end
	
	
	if( Controller.isPressing( "A" ) ) then
		if( cursor.highlightedTile.exists == false ) then return; end
		if( cursor.highlightedTile.getOccupant() ~= nil ) then
			cursor.useDigitalControl();
		end
		cursor.selectTile();
	end
	
	if( Controller.isPressing( "B" ) ) then
		UI.close( 1 );
	end
	
	if( Controller.isPressing( "Y" ) ) then
		UI.callback( "tileOption", cursor.highlightedTile );
	end
	
end


function hexCursorLeftX( value )
--	Controller.scheme.analogLeftXOld();
	Controller.state.LeftX = value;
	local cursor = LevelMap.cursor;
	
	LevelMap.cursor.useAnalogControl();
	local norm = value / Controller.ANALOG_MAX;
	local x = norm;
	local y = Controller.state.LeftY / Controller.ANALOG_MAX;
	cursor.setForce( x, y );
	
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
	cursor.setForce( x, y );
	
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

function Input.overrideDigital( scheme )
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



