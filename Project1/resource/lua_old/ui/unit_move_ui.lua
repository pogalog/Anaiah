-- Unit Move UI
require( "ui.ui_register" );


function createUnitMoveUI()
	
	local ui = createUI( "MoveUnit", createControlScheme( Controller ) );
	UIReg.registerUI( ui );
	overrideDigital( ui.controlScheme );
	
	ui.open = function()
		LevelMap.moveRange.setVisible( true );
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		cursor.useDigitalControl();
		if( unit ~= nil ) then
			-- ghost
			cursor.moveToSelectedUnit();
			Unit_setGhostVisible( unit.userdata, false );
			
			-- reset attack range
			unit.attackRange = LevelMap.grid.getAttackRange( unit );
			LevelMap.attackRange.build( unit.attackRange );
		end
	end
	
	ui.close = function()
		LevelMap.moveRange.setVisible( false );
	end
	
	
	ui.selectTile = function( tile )
		local cursor = LevelMap.cursor;
		
		-- move a selected unit to new highlighted tile
		if( cursor.getSelectedUnit() ~= nil ) then
			local grid = LevelMap.grid;
			local unit = cursor.getSelectedUnit();
			if( unit.moveRange.contains( tile ) ) then
				-- trying to self move (not move)
				if( tile.occupant == unit ) then
					-- cancel back out to previous menu
					UIReg.close( 1 );
					return;
				end
				unit.ghostTile = tile;
				Unit_setGhostTile( unit.userdata, tile.userdata );
				Unit_setGhostVisible( unit.userdata, true );
				
				-- find the path to this location, queue up the action
				local grid = LevelMap.grid;
				grid.clearPathFinding();
				grid.addPathFindingTarget( unit.ghostTile );
				grid.findPath();
				unit.path = grid.getPathForUnit( cursor.getSelectedUnit() );
				local unitPath = createUnitPath( unit, unit.path );
				
				submitMoveAction( createMoveAction( unitPath ) );
				
				UIReg.open( "UnitSecondActionMenu" );
			end
		end
	end
	
	ui.cursorMoved = function( tile )
		local cursor = LevelMap.cursor;
		local haveSelectedUnit = cursor.getSelectedUnit() ~= nil;
		LevelMap.moveRange.setVisible( haveSelectedUnit );
		LevelMap.singleAttackRange.setVisible( haveSelectedUnit );
		LevelMap.attackRange.setVisible( false );
		
		-- single attack range
		local unit = cursor.getSelectedUnit();
		if( unit.moveRange.contains( tile ) ) then
			unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
			LevelMap.singleAttackRange.build( unit.attackRange );
			LevelMap.singleAttackRange.setVisible( true );
			unit.ghostTile = tile;
			Unit_setGhostTile( unit.userdata, tile.userdata );
			Unit_setGhostVisible( unit.userdata, true );
		else
			LevelMap.setAttackRangeVisible( false );
			Unit_setGhostVisible( unit.userdata, false );
		end
	end
	
	ui.cursorOnUnit = function( unit )
	end
	
	ui.moveFinished = function( unit )
	end
	
	ui.deselectTile = function()
	end

	
	return ui;
end