-- Unit Action Menu UI
require( "ui.main" );


function UI.createActionMenuUI( menu )
	
	local ui = UI.createUI( "UnitActionMenu", menu.control, menu );
	UI.registerUI( ui );
	
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
	
	function ui.cursorMoved() end
	
	function ui.actionFinished()
		
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitActionMenu", "unit_action_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	return ui;
end