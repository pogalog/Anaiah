-- second action menu overrides

function actionMoveAndAttack()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	local tile = unit.ghostTile;
	unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
	LevelMap.singleAttackRange.build( unit.attackRange );
	LevelMap.singleAttackRange.setVisible( true );
	LevelMap.moveRange.setVisible( false );
	
	UIReg.open( "TargetSelect" );
end

function actionMoveAndWait()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();

	LevelMap.moveRange.setVisible( false );
	LevelMap.attackRange.setVisible( false );
	LevelMap.singleAttackRange.setVisible( false );
	Unit_setGhostVisible( unit.userdata, false );
	
	cursor.selectedTile = nil;

	PendingAction.commit();
end

function actionMoveAndItem()
	UIReg.open( "ItemTargetSelect" );
end