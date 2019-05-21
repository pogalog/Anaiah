-- Item Target Selection UI

function createItemTargetSelectUI()
	
	local ui = createUI( "ItemTargetSelect", createControlScheme( Controller ) );
	UIReg.registerUI( ui );
	overrideDigital( ui.controlScheme );

	ui.open = function()
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		
		LevelMap.setRangesVisible( false );
		-- build a range for item use based on its usage range
		local tile = unit.ghostTile == nil and cursor.highlightedTile or unit.ghostTile;
		LevelMap.markItemRangeForUnit( unit, tile );
		LevelMap.setItemRangeVisible( true );
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
		cursor.useDigitalControl();
		LevelMap.setItemRangeVisible( false );
		LevelMap.markRangesForUnit( LevelMap.cursor.getSelectedUnit(), Player.team );
	end
	
	ui.close = function()
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		LevelMap.setItemRangeVisible( false );
		Unit_setGhostVisible( unit.userdata, false );
	end
	
	ui.selectTile = function( tile )
		if( ActionInProgress ) then return; end
		
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		local target = tile.occupant ~= nil and tile.occupant or unit.ghostTile == tile and unit or nil;
		if( unit.itemRange.contains( tile ) and target ~= nil ) then
			local cursor = LevelMap.cursor;
			LevelMap.setRangesVisible( false );
			
			-- queue up the attack action, then commit
			-- TODO change this to an item action and animation
			local itemAction = createItemAction( unit, target );
			itemAction.events.add( createActionEvent( itemAction, 2.8, itemAction.useFunc ) );
			submitItemAction( itemAction );
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