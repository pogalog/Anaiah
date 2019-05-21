-- Unit Selection UI
require( "ui.ui_register" );

function createUnitSelectionUI()

	local ui = createUI( "SelectUnit", createControlScheme( Controller ) );
	UIReg.registerUI( ui, true );
	overrideDigital( ui.controlScheme );

	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
		cursor.useDigitalControl();
	end
	
	ui.close = function()
	end
	
	ui.selectTile = function( tile )
		selectTile( tile );
	end
	
	ui.cursorMoved = function( tile )
		local cursor = LevelMap.cursor;
		local haveSelectedUnit = cursor.getSelectedUnit() ~= nil;
		LevelMap.setRangesVisible( haveSelectedUnit );
	end
	
	
	ui.cursorOnUnit = function( unit )
		LevelMap.markRangesForUnit( unit, Player.team );
	end
	
	
	ui.deselectTile = function()
	end
	
	return ui;
end