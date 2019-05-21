-- Attack Animation UI
require( "ui.main" );
require( "input.main" );


function UI.createAttackAnimUI()
	
	local ui = UI.createUI( "AttackAnimation", Input.createControlScheme( Controller ) );
	UI.registerUI( ui );
	
	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
	end
	
	function ui.cursorMoved() end
	
	function ui.actionFinished()
		
	end
	
	ui.close = function()
	end
	
	ui.attackFinished = function( unit )
	end
	
end