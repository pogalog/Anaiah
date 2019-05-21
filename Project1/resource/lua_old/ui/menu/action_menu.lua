-- action menu

function actionMenuMove()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	if( unit == nil ) then return; end
	unit.attackRange = LevelMap.grid.getAttackRange( unit );
	LevelMap.attackRange.build( unit.attackRange );
	LevelMap.attackRange.setVisible( true );
	
	UIReg.open( "MoveUnit" );
end

function actionAttack()
	local cursor = LevelMap.cursor;
	local unit = cursor.getSelectedUnit();
	local tile = unit.tile;
	unit.attackRange = LevelMap.grid.getSingleAttackRange( unit, tile );
	LevelMap.attackRange.setVisible( false );
	LevelMap.singleAttackRange.build( unit.attackRange );
	LevelMap.singleAttackRange.setVisible( true );
	LevelMap.moveRange.setVisible( false );
	
	UIReg.open( "TargetSelect" );
end

function actionItems()
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
		Unit_setGhostVisible( unit.userdata, false );
	end
	
	UIReg.open( "ItemTargetSelect" );
end

