-- Unit Inventory Menu UI

require( "ui.main" );

function UI.createInventoryMenuUI( menu )
	local ui = UI.createUI( "UnitInventoryMenu", menu.control, menu );
	UI.registerUI( ui );
	
	ui.open = function()
		local cursor = LevelMap.cursor;
		
		-- destroy the old menu and create a new one
		ui.menu.dispose();
		ui.setMenu( UI.createInventoryMenu( cursor.getSelectedUnit() ) );
		UI.getController().setScheme( ui.controlScheme );
		ui.menu.setVisible( true );
	end
	
	ui.cancel = function()
		ui.menu.setVisible( false );
	end
	
	ui.close = function()
		ui.menu.setVisible( false );
	end
	
	function ui.cursorMoved() end
	
	function ui.actionFinished()
		
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitInventoryMenu", "unit_inventory_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	
	return ui;
end