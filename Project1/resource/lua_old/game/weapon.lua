require( "game.vector" );

-- weapon
function createWeapon( id )
	local weapon = {};
	weapon.name = "";
	weapon.description = "";
	weapon.id = id;
	weapon.type = nil;
	weapon.stat = {};
	weapon.stat.atk = 10;
	weapon.stat.wt = 4;
	weapon.stat.hit = 0.9;
	weapon.stat.crit = 0.05;
	weapon.range = createRange( 1, 1 );
  
	weapon.func = nil;

	return weapon;
end
