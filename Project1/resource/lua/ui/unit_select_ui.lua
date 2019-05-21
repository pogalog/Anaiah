-- Unit Selection UI
require( "ui.main" );



function UI.createUnitSelectionUI()

	local ui = UI.createUI( "SelectUnit", Input.createControlScheme( Controller ) );
	UI.registerUI( ui, true );
	Input.overrideDigital( ui.controlScheme );

	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
		cursor.useDigitalControl();
	end
	
	ui.close = function()
	end
	
	
	ui.selectTile = function( tile )
		Flow.selectTile( tile );
		
		local unit = tile.getOccupant();
		if( unit == nil ) then return; end
		if( unit.tile ~= tile ) then
			LevelMap.moveUnit( unit, tile );
--			unit.moveToTile( tile );
		end
	end
	
	
	-- TODO also need to change maps for non-local connections
	ui.tileOption = function( tile )
		if( tile.coexist ~= nil ) then
			LevelMap.cursor.moveToTile( tile.coexist );
		end
	end
	
	
	ui.cursorMoved = function( tile )
		local cursor = LevelMap.cursor;
		local haveSelectedUnit = cursor.getSelectedUnit() ~= nil;
		LevelMap.setRangesVisible( haveSelectedUnit );
	end
	
	
	function ui.actionFinished()
	end
	
	
	ui.cursorOnUnit = function( unit )
		LevelMap.markRangesForUnit( unit, Player.team );
	end
	
	
	ui.deselectTile = function()
	end
	
	return ui;
end