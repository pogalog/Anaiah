-- Target Selection UI
require( "ui.main" );
require( "input.main" );



function UI.createTargetSelectUI()
	
	local ui = UI.createUI( "TargetSelect", Input.createControlScheme( Controller ) );
	UI.registerUI( ui );
	Input.overrideDigital( ui.controlScheme );

	function ui.open()
	end
	
	
	function ui.cancel()
		local cursor = LevelMap.cursor;
		cursor.useDigitalControl();
		LevelMap.markRangesForUnit( LevelMap.cursor.getSelectedUnit(), Player.team );
	end
	
	function ui.close()
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		LevelMap.moveRange.setVisible( false );
		unit.setGhostVisible( false );
	end
	
	function ui.selectTile( tile )
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		if( unit.attackRange.contains( tile ) and tile.getOccupant() ~= nil and tile.getOccupant() ~= unit ) then
			local cursor = LevelMap.cursor;
			LevelMap.moveRange.setVisible( false );
			LevelMap.attackRange.setVisible( false );
			LevelMap.singleAttackRange.setVisible( false );
			
			-- queue up the attack action, then commit
			local action = Exec.createAttackAction( unit, tile.getOccupant(), Exec.getQueuedAction() );
			Exec.submitAction( action );
			Exec.commitUserActions();
			
			cursor.selectedTile = nil;
			UI.open( "ActionAnimation" );
		end
	end
	
	function ui.cursorMoved( tile )
	end
	
	function ui.actionFinisehd()
		
	end
	
	function ui.cursorOnUnit( unit )
	end
	
	function ui.moveFinished( unit )
	end
	
	function ui.deselectTile()
	end

	
	return ui;
end