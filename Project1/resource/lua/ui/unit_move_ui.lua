-- Unit Move UI
require( "ui.main" );
require( "input.main" );




function UI.createUnitMoveUI()
	
	local ui = UI.createUI( "MoveUnit", Input.createControlScheme( Controller ) );
	UI.registerUI( ui );
	Input.overrideDigital( ui.controlScheme );
	
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
			unit.setGhostVisible( false );
			
			
			-- reset attack range
			unit.attackRange = LevelMap.grid.getAttackRange( unit );
			LevelMap.attackRange.build( unit.attackRange );
			LevelMap.singleAttackRange.setVisible( false );
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
				if( tile.getOccupant() == unit ) then
					-- cancel back out to previous menu
					UI.close( 1 );
					return;
				end
				unit.setGhostTile( tile );
				unit.setGhostVisible( true );
				
				-- find the path to this location, queue up the action
				local grid = LevelMap.grid;
				grid.clearPathFinding();
				grid.addPathFindingTarget( unit.ghostTile );
				grid.findPath();
				unit.path = grid.getPathForUnit( cursor.getSelectedUnit() );
				local unitPath = Game.createUnitPath( unit, unit.path );
				
				local action = Exec.createMoveAction( unitPath );
				Exec.submitAction( action );
				
				UI.open( "UnitSecondActionMenu" );
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
			unit.setGhostTile( tile );
			unit.setGhostVisible( true );
		else
			LevelMap.setSingleAttackRangeVisible( false );
			unit.setGhostVisible( false );
		end
	end
	
	function ui.actionFinished()
		LevelMap.updateRanges();
		local cursor = LevelMap.cursor;
		local unit = cursor.getSelectedUnit();
		if( unit == nil ) then return; end
		
		if( unit.moveRange.contains( cursor.highlightedTile ) == false ) then
			LevelMap.setSingleAttackRangeVisible( false );
			unit.setGhostVisible( false );
		else
			LevelMap.setSingleAttackRangeVisible( true );
			unit.setGhostVisible( true );
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