-- Unit Inventory Menu UI

require( "ui.ui_register" );

function createInventoryMenuUI( menu )
	local ui = createUI( "UnitInventoryMenu", menu.control, menu );
	UIReg.registerUI( ui );
	
	ui.open = function()
		local cursor = LevelMap.cursor;
		
		-- destroy the old menu and create a new one
		ui.menu.dispose();
		ui.setMenu( createInventoryMenu( cursor.getSelectedUnit() ) );
		UIReg.controller.setScheme( ui.controlScheme );
		ui.menu.setVisible( true );
	end
	
	ui.cancel = function()
		ui.menu.setVisible( false );
	end
	
	ui.close = function()
		ui.menu.setVisible( false );
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitInventoryMenu", "unit_inventory_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	
	return ui;
end