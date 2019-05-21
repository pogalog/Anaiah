-- Input

Input = {};

function Input.createController( port )
	local controller = {};
	controller.userdata = port;
	controller.button = {};
	controller.state = Input.createControllerState();
	controller.scheme = Input.createControlScheme( controller );
	controller.previousScheme = nil;
	controller.ANALOG_MAX = 32767.0;
	
	-- utility structures
	controller.directions = {"Up", "Down", "Left", "Right"};
	controller.shoulders = {"LeftShoulder", "RightShoulder"};
	controller.analogLeft = {"LeftX", "LeftY"};
	controller.analogRight = {"RightX", "RightY"};
	controller.analogs = {"LeftX", "LeftY", "RightX", "RightY"};
	controller.sticks = {"LeftThumb", "RightThumb"};
	controller.letters = {"A", "B", "X", "Y"};
	controller.triggers = {"LeftTrigger", "RightTrigger"};
	
	
	function controller.setScheme( scheme )
		controller.previousScheme = controller.scheme;
		controller.scheme = scheme;
	end
	
	function controller.revert()
		controller.scheme = controller.previousScheme;
	end
	
	function controller.softRevert()
		local temp = controller.scheme;
		controller.scheme = controller.previousScheme;
		controller.previousScheme = temp;
	end
	
	-- check if the button is being pressed
	function controller.isPressing( buttonKey )
		if( controller.state.change < 0 ) then return false; end
		return (controller.state.change & controller.button[buttonKey]) > 0;
	end
	
	function controller.areAnyPressing( keys )
		for index,key in pairs( keys ) do
			if( controller.isPressing( key ) ) then
				return true;
			end
		end
		return false;
	end
	
	function controller.areAllPressing( keys )
		for index,key in pairs( keys ) do
			if( ~controller.isPressing( key ) ) then
				return false;
			end
		end
		return true;
	end
	
	-- is button being released?
	function controller.isReleasing( buttonKey )
		if( controller.state.change > 0 ) then return false; end
		return (-controller.state.change & controller.button[buttonKey]) > 0;
	end
	
	-- is button currently pressed?
	function controller.isPressed( buttonKey )
		return controller.state[buttonKey];
	end
	
	function controller.areAnyPressed( keys )
		for index,key in pairs( keys ) do
			if( controller.isPressed( key ) ) then
				return true;
			end
		end
		return false;
	end
	
	function controller.areAllPressed( keys )
		for index,key in pairs( keys ) do
			if( ~controller.isPressed( key ) ) then
				return false;
			end
		end
		return true;
	end
	
	
	function controller.setDigitalButtons()
		-- global controller setting (digital button IDs)
		local A,B,X,Y,START,BACK,LS,RS,UP,DOWN,LEFT,RIGHT,LT,RT = Controller_setDigitalButtonIDs();
		controller.button = {};
		controller.button.A = A;
		controller.button.B = B;
		controller.button.X = X;
		controller.button.Y = Y;
		controller.button.Start = START;
		controller.button.Back = BACK;
		controller.button.LeftShoulder = LS;
		controller.button.RightShoulder = RS;
		controller.button.Up = UP;
		controller.button.Down = DOWN;
		controller.button.Left = LEFT;
		controller.button.Right = RIGHT;
		controller.button.LeftThumb = LT;
		controller.button.RightThumb = RT;
	end
	
	return controller;
end

function Input.createControllerState()
	local state = {}
	state.buttons = 0;
	state.change = 0;
	state.A = false;
	state.B = false;
	state.X = false;
	state.Y = false;
	state.Start = false;
	state.Back = false;
	state.LeftShoulder = false;
	state.RightShoulder = false;
	state.Up = false;
	state.Down = false;
	state.Left = false;
	state.Right = false;
	state.LeftThumb = false;
	state.RightThumb = false;
	state.LeftTrigger = 0;
	state.RightTrigger = 0;
	state.LeftX = 0;
	state.LeftY = 0;
	state.RightX = 0;
	state.RightY = 0;
	state.connected = false;
	
	return state;
end


function Input.createControlScheme( controller )
	local state = controller.state;
	local scheme = {};
	scheme.controller = controller;
	
	function scheme.checkButton( change, key )
		if( change > 0 ) then
			if( change & controller.button[key] > 0 ) then
				controller.state[key] = true;
				controller.state.buttons = controller.state.buttons & controller.button[key];
			end
		else
			if( -change & controller.button[key] > 0 ) then
				controller.state[key] = false;
				controller.state.buttons = controller.state.buttons & (~controller.button[key]);
			end
		end
	end
	
	function scheme.controllerConnected() state.connected = true; end
	function scheme.controllerDisconnected() state.connected = false; end
	
	function scheme.leftTrigger( value ) state.LeftTrigger = value; end
	function scheme.rightTrigger( value ) state.RightTrigger = value; end
	function scheme.leftStickX( value ) state.LeftX = value; end
	function scheme.leftStickY( value ) state.LeftY = value; end
	function scheme.rightStickX( value ) state.RightX = value; end
	function scheme.rightStickY( value ) state.RightY = value; end
	function scheme.digitalButton( change )
		local b = controller.button;
		state.change = change;
		
		scheme.checkButton( change, "Up" );
		scheme.checkButton( change, "Down" );
		scheme.checkButton( change, "Left" );
		scheme.checkButton( change, "Right" );
		scheme.checkButton( change, "RightShoulder" );
		scheme.checkButton( change, "LeftShoulder" );
		scheme.checkButton( change, "RightThumb" );
		scheme.checkButton( change, "LeftThumb" );
		scheme.checkButton( change, "A" );
		scheme.checkButton( change, "B" );
		scheme.checkButton( change, "X" );
		scheme.checkButton( change, "Y" );
		scheme.checkButton( change, "Start" );
		scheme.checkButton( change, "Back" );
				
	end
	
	return scheme;
end

function Input.createKeyboard( port )
	local kb = {};
	kb.port = port;
	
	kb.listener = Input.createKeyboardListener( kb );
	function kb.setListener( listener )
		kb.listener = listener;
	end
	
	
	
	return kb;
end

function Input.createKeyboardListener( keyboard )
	local kbl = {};
	kbl.keyboard = keyboard;
	
	function kbl.grabFocus()
		kbl.keyboard.listener = kbl;
	end
	
	function kbl.keyPressed( key )
	end
	
	function kbl.keyReleased( key )
	end
	
	return kbl;
end


-- Keep global access to the ControllerPort (Xbox) and the AudioManager
-- These are required in order to build a new GameInstance
ControllerPort, AudioManager = Main_getControllerAndAudio();
Controller = Input.createController( ControllerPort );
Controller.setDigitalButtons();

Keyboard = Input.createKeyboard( ControllerPort );


-- global functions for controller callbacks
function controllerConnected( contr )
	Controller.scheme.controllerConnected();
end

function controllerDisconnected( contr )
	Controller.scheme.controllerDisconnected();
end

function digitalButton( contr, change )
	Controller.scheme.digitalButton( change );
	
end

function leftTrigger( contr, value )
	Controller.scheme.leftTrigger( value );
end

function rightTrigger( contr, value )
	Controller.scheme.rightTrigger( value );
end

function leftStickX( contr, value )
	Controller.scheme.leftStickX( value );
end

function leftStickY( contr, value )
	Controller.scheme.leftStickY( value );
end

function rightStickX( contr, value )
	Controller.scheme.rightStickX( value );
end

function rightStickY( contr, value )
	Controller.scheme.rightStickY( value );
end

-- global functions for Keyboard callbacks
function keyPressed( key )
	Keyboard.listener.keyPressed( key );
end

function keyReleased( key )
	Keyboard.listener.keyReleased( key );
end

function keyTyped( key )
end