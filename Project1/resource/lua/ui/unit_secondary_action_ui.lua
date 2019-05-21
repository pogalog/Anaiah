-- Unit secondary action UI

require( "ui.main" );



function UI.createSecondaryActionMenuUI( menu )
	
	local ui = UI.createUI( "UnitSecondActionMenu", menu.control, menu );
	UI.registerUI( ui );

	ui.open = function()
		ui.menu.setVisible( true );
	end
	
	ui.cancel = function()
		ui.menu.setVisible( false );
		
		-- remove the previously recorded move action
		Exec.cancel();
	end

	ui.close = function()
		ui.menu.setVisible( false );
--		ui.menu.restore();
	end
	
	function ui.cursorMoved( tile )
		UI.close( 1 );
		UI.getActiveUI().cursorMoved( tile );
	end
	
	function ui.actionFinished()
		LevelMap.updateRanges();
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		if( unit == nil ) then return; end
		
		unit.moveRange = LevelMap.findMovementRange( unit );
		
		if( unit.moveRange.contains( cursor.highlightedTile ) == false ) then
			LevelMap.setSingleAttackRangeVisible( false );
			unit.setGhostVisible( false );
		else
			LevelMap.setSingleAttackRangeVisible( true );
			unit.setGhostVisible( true );
		end
	end
	
	function ui.moveFinished()
		generateWarning( "Called moveFinished on menu-based UI UnitSecondActionMenu", "unit_secondary_action_menu_ui.lua::createActionMenuUI::moveFinished" );
	end
	
	ui.selectTile = function()
		generateWarning( "Called selectTile on menu-based UI UnitSecondActionMenu", "unit_secondary_action_menu_ui.lua::createActionMenuUI::selectTile" );
	end
	
	return ui;
end