-- Move Animation UI

function createActionAnimUI()
	
	local ui = createUI( "ActionAnimation", createControlScheme( Controller ) );
	UIReg.registerUI( ui );
	
	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
	end
	
	
	ui.close = function()
	end
	
	ui.moveFinished = function( unitPath )
		local path = unitPath.path;
		
		LevelMap.moveUnit( unitPath.unit, unitPath.getDestination() );
		LevelMap.markRangesForUnit( unitPath.unit, Player.team );

		-- reset animation to idle
		unitPath.unit.setAnimation( -1 );
		LevelMap.cursor.selectedUnit = nil;
	end
	
	function ui.attackFinished( unit )
		local cursorUnit = LevelMap.cursor.getHighlightedUnit();
		if( cursorUnit ~= nil ) then
			LevelMap.markRangesForUnit( cursorUnit, Player.team );
			LevelMap.cursor.moveTo( cursorUnit.tile.address );
		end
		LevelMap.cursor.selectedUnit = nil;
	end
	
end