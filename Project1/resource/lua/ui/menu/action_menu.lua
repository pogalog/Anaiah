-- action menu
require( "ui.main" );

function UI.actionMenuMove()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	if( unit == nil ) then return; end
	unit.attackRange = LevelMap.grid.getAttackRange( unit );
	LevelMap.attackRange.build( unit.attackRange );
	LevelMap.attackRange.setVisible( true );
	
	UI.open( "MoveUnit" );
end

function UI.actionAttack()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	local tile = unit.tile;
	unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
	LevelMap.attackRange.setVisible( false );
	LevelMap.singleAttackRange.build( unit.attackRange );
	LevelMap.singleAttackRange.setVisible( true );
	LevelMap.moveRange.setVisible( false );
	
	UI.open( "TargetSelect" );
end

function UI.actionItems()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	local tile = cursor.highlightedTile;
	if( unit.moveRange.contains( tile ) ) then
		unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
		LevelMap.attackRange.setVisible( false );
		LevelMap.singleAttackRange.build( unit.attackRange );
		LevelMap.singleAttackRange.setVisible( true );
		LevelMap.moveRange.setVisible( false );
	else
		LevelMap.singleAttackRange.setVisible( false );
		unit.setGhostVisible( false );
	end
	
	UI.open( "ItemTargetSelect" );
end

