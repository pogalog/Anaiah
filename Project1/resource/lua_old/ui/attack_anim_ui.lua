-- Attack Animation UI


function createAttackAnimUI()
	
	local ui = createUI( "AttackAnimation", createControlScheme( Controller ) );
	UIReg.registerUI( ui );
	
	ui.open = function()
	end
	
	
	ui.cancel = function()
		local cursor = LevelMap.cursor;
	end
	
	
	ui.close = function()
	end
	
	ui.attackFinished = function( unit )
--		UIReg.clear();
	end
	
end