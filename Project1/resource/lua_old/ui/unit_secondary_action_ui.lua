-- Unit secondary action UI

require( "ui.ui_register" );

function createSecondaryActionMenuUI( menu )
	
	local ui = createUI( "UnitSecondActionMenu", menu.control, menu );
	UIReg.registerUI( ui );

	ui.open = function()
		ui.menu.setVisible( true );
	end
	
	ui.cancel = function()
		ui.menu.setVisible( false );
		
		-- dequeue the previously recorded move action
--		ActionQueue.dequeue();
		cancelMoveAction();
	end

	ui.close = function()
		ui.menu.setVisible( false );
--		ui.menu.restore();
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitSecondActionMenu", "unit_secondary_action_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	return ui;
end