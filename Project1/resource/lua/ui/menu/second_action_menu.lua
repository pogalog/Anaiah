-- second action menu overrides
require( "ui.main" );



function UI.actionMoveAndAttack()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	local tile = unit.ghostTile;
	unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
	LevelMap.singleAttackRange.build( unit.attackRange );
	LevelMap.singleAttackRange.setVisible( true );
	LevelMap.moveRange.setVisible( false );
	
	UI.open( "TargetSelect" );
end

function UI.actionMoveAndWait()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();

	LevelMap.moveRange.setVisible( false );
	LevelMap.attackRange.setVisible( false );
	LevelMap.singleAttackRange.setVisible( false );
	unit.setGhostVisible( false );
	
	cursor.selectedTile = nil;
	
	UI.open( "ActionAnimation" );
	Exec.commitUserActions();
end

function UI.actionMoveAndItem()
	UI.open( "ItemTargetSelect" );
end