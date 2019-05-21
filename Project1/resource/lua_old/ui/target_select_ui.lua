-- Target Selection UI

function createTargetSelectUI()
	
	local ui = createUI( "TargetSelect", createControlScheme( Controller ) );
	UIReg.registerUI( ui );
	overrideDigital( ui.controlScheme );

	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
		cursor.useDigitalControl();
		LevelMap.markRangesForUnit( LevelMap.cursor.getSelectedUnit(), Player.team );
	end
	
	ui.close = function()
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		LevelMap.moveRange.setVisible( false );
		Unit_setGhostVisible( unit.userdata, false );
	end
	
	ui.selectTile = function( tile )
		if( ActionInProgress ) then return; end
		
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		if( unit.attackRange.contains( tile ) and tile.occupant ~= nil and tile.occupant ~= unit ) then
			local cursor = LevelMap.cursor;
			LevelMap.moveRange.setVisible( false );
			LevelMap.attackRange.setVisible( false );
			LevelMap.singleAttackRange.setVisible( false );
			
			-- queue up the attack action, then commit
			submitAttackAction( createAttackAction( unit, tile.occupant ) );
			PendingAction.commit();
			
			cursor.selectedTile = nil;
			UIReg.open( "ActionAnimation" );
		end
	end
	
	ui.cursorMoved = function( tile )
	end
	
	ui.cursorOnUnit = function( unit )
	end
	
	ui.moveFinished = function( unit )
	end
	
	ui.deselectTile = function()
	end

	
	return ui;
end