-- Unit Action Menu UI

require( "ui.ui_register" );

function createActionMenuUI( menu )
	
	local ui = createUI( "UnitActionMenu", menu.control, menu );
	UIReg.registerUI( ui );
	
	ui.open = function()
		ui.menu.setVisible( true );
	end
	
	ui.cancel = function()
		LevelMap.cursor.deselectTile();
		ui.menu.setVisible( false );
	end
	
	ui.close = function()
		ui.menu.setVisible( false );
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitActionMenu", "unit_action_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	return ui;
end