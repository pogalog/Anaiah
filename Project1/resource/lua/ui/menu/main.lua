-- Menu
require( "math.vector" );
require( "ui.main" );



function UI.createGameMenu( userdata, font, controlScheme )
	local menu = {};
	menu.items = {};
	menu.userdata = userdata;
	menu.font = font;
	menu.cursor = 0;
	menu.selectedItem = nil;
	menu.visible = false;
	menu.size = Vec2_new( 0, 0 );
	menu.position = Vec2_new( 0, 0 );
	menu.shader = Shaders.solidShader;
	menu.itemShader = Shaders.textShader;
	menu.name = "UnlovedMenu";
	
	if( controlScheme == nil ) then
		menu.control = Input.createControlScheme( Controller );
	else
		menu.control = controlScheme;
	end
	menu.controller = Controller;
	
	-- set defaults
	Menu_setFont( userdata, font.userdata );
	Menu_setShader( userdata, menu.shader.userdata );
	Menu_setItemShader( userdata, menu.itemShader.userdata );
	
	
	-- Control Scheme
	menu.control.oldDigital = menu.control.digitalButton;
	menu.control.digitalButton = function( change )
		menu.control.oldDigital( change );
		
		-- Throw a warning if the menu isn't visible
		if( menu.visible == false ) then
			generateWarning( "Active control scheme points to inactive menu: " .. menu.name, "menu.lua::createGameMenu" );
--			menu.setVisible( true );
		end
		
		local controller = menu.control.controller;
		
		if( controller.isPressing( "Up" ) ) then
			menu.cursorUp();
		end
		
		if( controller.isPressing( "Down" ) ) then
			menu.cursorDown();
		end
		
		if( controller.isPressing( "B" ) ) then
			UI.close( 1 );
		end
		
		if( controller.isPressing( "A" ) ) then
			menu.executeOption();
		end
	end
	
	
	-- functions
	function menu.getItem( message )
		for k,v in pairs( menu.items ) do
			if v.message == message then
				return v;
			end
		end
	end
	
	function menu.cursorUp()
		menu.cursor = (menu.cursor - 1 + #menu.items) % #menu.items;
		if( menu.getSelected().visible == false ) then
			menu.cursorUp();
			return;
		end
		menu.updateCursor();
	end
	
	function menu.cursorDown()
		menu.cursor = (menu.cursor + 1) % #menu.items;
		if( menu.getSelected().visible == false ) then
			menu.cursorDown();
			return;
		end
		menu.updateCursor();
	end
	
	function menu.setAction( itemMessage, func )
		local item = menu.getItem( itemMessage );
		if( item == nil ) then
			generateWarning( "Attempted to set action for non-existent menu item '" .. itemMessage .. "'", "menu.lua::setAction" );
			return nil;
		end
		item.execute = func;
	end
	
	function menu.getSelected()
		return menu.items[menu.cursor+1];
	end
		
	
	function menu.close()
		menu.setVisible( false );
		menu.controller.revert();
	end
	
	function menu.hide()
		menu.setVisible( false );
	end
	
	function menu.executeOption()
		local item = menu.items[menu.cursor+1];
		item.execute( item );
	end
	
	-- binding functions
	function menu.addItem( message )
		local item = {};
		item.message = message;
		item.visible = true;
		
		-- must override this
		function item.execute() end
	
		function item.create()
			item.userdata = Menu_addItem( menu.userdata, message );
			menu.items[#menu.items+1] = item;
		end
		
		function item.setVisible( visible )
			item.visible = visible;
			-- make sure this item isn't currently selected
			if( menu.getSelected() == item ) then
				menu.cursorDown();
			end
			Menu_setItemVisible( menu.userdata, item.userdata, false );
		end
		
		item.create();
		return item;
	end
	
	function menu.addItems( ... )
		for k,v in pairs( {...} ) do
			menu.addItem( v );
		end
	end
	
	function menu.setShader( shader )
		Menu_setShader( menu.userdata, shader );
	end
	
	function menu.setItemShader( shader )
		Menu_setItemShader( menu.userdata, shader );
	end
	
	function menu.build()
		Menu_build( menu.userdata );
	end
	
	function menu.setSize( size )
		menu.size = size;
		Menu_setSize( menu.userdata, size );
	end
	
	function menu.setPosition( position )
		menu.position = position;
		Menu_setPosition( menu.userdata, position );
	end
	
	-- sets visibility for all items
	function menu.setItemsVisible( visible )
		for key,item in pairs( menu.items ) do
			item.setVisible( visible );
		end
	end
	
	function menu.setVisible( visible )
		menu.visible = visible;
		Menu_setVisible( menu.userdata, visible );
	end
	
	function menu.dispose()
		Menu_dispose( GameInstance, menu.userdata );
	end
		
	-- cursor positions run from 0..n-1, so indexing the items table must add one
	-- but indexing to C++ will use the unmodified values
	function menu.setCursorPosition( position )
		menu.cursor = position;
		menu.selectedItem = menu.items[position];
	end
	
	function menu.updateCursor()
		menu.selectedItem = menu.items[menu.cursor+1];
		Menu_setCursorPosition( menu.userdata, menu.cursor );
	end
	
	return menu;
end

