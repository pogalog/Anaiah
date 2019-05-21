-- UI System
require( "structure.list" );

UI = {};


-- UI Register Utility
function UI.open( name )
	UI.Reg.open( name );
end

function UI.close( count )
	UI.Reg.close( count );
end

function UI.clear()
	UI.Reg.clear();
end

function UI.registerUI( ui, makeDefault )
	UI.Reg.registerUI( ui, makeDefault );
end

function UI.getController()
	return UI.Reg.controller;
end

function UI.actionFinished()
	local active = UI.getActiveUI();
	if( active.actionFinished == nil ) then return; end
	active.actionFinished();
end



function UI.initializeUIRegister( controller )
	local uir = {};
	uir.UITable = {};
	uir.UIstack = createList();
	uir.defaultUI = nil;
	uir.activeUI = nil;
	uir.controller = controller;
	uir.active = false;
	
	function uir.top()
		return uir.UIstack.last();
	end
	
	function uir.sleep()
		uir.active = false;
		uir.activeUI.sleep();
	end
	
	function uir.resume()
		uir.active = true;
		uir.activeUI.resume();
	end
	
	-- add a UI to the table
	function uir.registerUI( ui, makeDefault )
		uir.UITable[ui.name] = ui;
		
		if( makeDefault == true ) then
			uir.defaultUI = makeDefault;
			uir.UIstack.add( ui );
			uir.controller.setScheme( ui.controlScheme );
			uir.activeUI = ui;
			ui.open();
		end
	end

	
	-- hold the parameter ui as the default
	-- if it is ever found that the stack is completely empty, the default will be pushed
	function uir.setDefaultUI( ui )
		uir.defaultUI = ui;
	end
	
	
	function uir.getUI( name )
		return uir.UITable[name];
	end
	

	-- push a UI to the stack, searched by its name
	function uir.open( name )
		local ui = uir.getUI( name );
		if( ui == nil ) then
			generateWarning( "Attempted to open non-existent UI '" .. name .. "'", "ui_register.lua::initializeRegister::open" );
			return;
		end
		uir.UIstack.add( ui );
		uir.controller.setScheme( ui.controlScheme );
		
		-- close the active UI, and open the new one
		uir.activeUI.close();
		uir.activeUI = ui;
		ui.open();
	end
	

	-- pop the top 'count' UI objects from the stack
	function uir.close( count )
		if( uir.UIstack.length() == 1 ) then return; end
		if( uir.UIstack.length() <= count ) then
			generateWarning( "Attempted to pop " .. count .. " elements from stack of size " .. uir.UIstack.length(), "ui_register.lua::initializeRegister::close" );
			uir.clear();
			return;
		end
		
		-- call cancel() for the UI on top only
		uir.top().cancel();
		
		for i = uir.UIstack.length(), uir.UIstack.length()-(count-1), -1 do
			local top = uir.UIstack.get(i);
			uir.UIstack.removeIndex(i);
		end
		
		-- open the new top UI
		uir.activeUI = uir.top();
		uir.controller.setScheme( uir.activeUI.controlScheme );
		uir.activeUI.open();
	end

	
	-- clear all UI from the stack, execpt for the default
	function uir.clear()
		uir.close( uir.UIstack.length()-1 );
	end

	
	UI.Reg = uir;
	
end





-- the third parameter is optional
function UI.createUI( name, controlScheme, menu )
	if( name == nil ) then
		generateWarning( "ui_register.lua::createUI", "Attempted to create UI without a name" );
		return nil;
	end
	
	local ui = {};
	ui.name = name;
	ui.controlScheme = controlScheme;
	ui.menu = menu;
	ui.active = true;
	
	if( menu ~= nil ) then
		menu.name = name;
		ui.menu.ui = ui;
	end
	
	function ui.setMenu( menu )
		ui.menu = menu;
		ui.menu.name = ui.name;
		ui.controlScheme = menu.control;
	end
	
	function ui.sleep()
		ui.active = false;
		ui.inactiveScheme = ui.controlScheme;
		ui.controlScheme = {};
		if( ui.menu ~= nil ) then
			ui.menu.controlScheme = {};
		end
	end
	
	function ui.resume()
		ui.active = true;
		ui.controlScheme = ui.inactiveScheme;
		if( ui.menu ~= nil ) then
			ui.menu.controlScheme = ui.inactiveScheme;
		end
	end
	
	
	-- to be overridden
	function ui.open() end
	function ui.close() end
	
	return ui;
end


function UI.getActiveUI()
	return UI.Reg.activeUI;
end


function UI.getActiveMenu()
	if( UI.Reg.activeUI == nil ) then return nil; end
	return UI.Reg.activeUI.menu;
end


function UI.checkField( name )
	if( UI.Reg.activeUI == nil ) then return false; end
	return UI.Reg.activeUI[name] ~= nil;
end


function UI.callback( name, ... )
	if( UI.checkField( name ) == false ) then return false; end
	UI.Reg.activeUI[name]( ... );
	return true;
end