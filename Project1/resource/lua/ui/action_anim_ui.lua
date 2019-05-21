-- Move Animation UI
require( "ui.main" );
require( "input.main" );

function UI.createActionAnimUI()
	
	local ui = UI.createUI( "ActionAnimation", Input.createControlScheme( Controller ) );
	UI.registerUI( ui );
	
	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
	end
	
	function ui.cursorMoved() end
	
	ui.close = function()
	end
	
	ui.moveFinished = function( unitPath )
		local path = unitPath.path;
		
		LevelMap.markRangesForUnit( unitPath.unit, Player.team );
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
	
	function ui.actionFinished()
		
	end
	
end