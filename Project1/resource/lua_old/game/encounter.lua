-- encounter

ENCOUNTER_ATTACK = 1;
ENCOUNTER_HEAL = 2;
ENCOUNTER_SABOTAGE = 3;
ENCOUNTER_BUFF = 4;

_G.encounter = {};

function encounter.computeAttack( unit, target )
	local wpn = unit.equipped;
	local as = unit.stat;
	
	local data = {};
	data.totalTime = 0;
	data.unit = unit;
	data.target = target;
	data.timeConsumed = 1 + wpn.stat.wt/(2*as.spd);
	
	local accuracy = wpn.stat.hit * 100 + 2 * as.skill + as.luck;
	local eva = target.stat.luck;
	-- penalize target unit, if AP is low
	if( target.stat.ap > 0 ) then
		eva = eva + target.stat.skill/2;
	end
	if( target.stat.ap > target.stat.minAP ) then
		eva = eva + 2 * target.computeAttackSpeed() + target.stat.skill/2;
	end
	
	local acc = math.clamp( accuracy - eva, 0, 100 );
	math.randomseed( os.time() );
	local hitTest = math.random( 100 );
	
	-- test hit
	data.success = hitTest <= acc;
	if( hitTest > acc ) then -- miss
		data.critical = false;
		data.damage = 0;
		return data;
	end
	
	-- check for critical hit
	local baseCrit = wpn.stat.crit * 100 + (as.skill+as.luck)/2.0;
	local dodge = target.stat.luck;
	local critPercent = baseCrit - dodge;
	local critTest = math.random( 100 );
	data.critical = critTest <= critPercent;
	local critBonus = 1.0;
	if( data.critical ) then critBonus = 3; end
	
	-- compute damage
	local effectiveness = 1; -- used for bonus damage
	local terrainAtkBonus = unit.tile.modifiers.atk;
	local terrainDefBonus = target.tile.modifiers.def;
	local baseDamage = as.str + wpn.stat.atk * effectiveness + terrainAtkBonus;
	local totalDef = target.stat.def + terrainDefBonus;
	data.damage = (baseDamage * critBonus - totalDef);
	if( data.damage < 0 ) then data.damage = 0; end
	data.success = true;
	
	return data;
end


function encounter.processAttack( data )
	data.unit.changeAP( -data.timeConsumed );
--	data.unit.checkAPStatus();
	
	if( data.success ) then
		data.target.changeHP( -data.damage );
		Overlay.createDamageDisplay( data.target, -math.round( data.damage ) );
		
		if( data.target.ko ) then
			LevelMap.hideUnit( data.target );
		end
	else
		Overlay.createDamageDisplay( data.target, "Miss!" );
	end
	
	Overlay.updateUnitOverlay();
end


function encounter.computeItemUsage( unit, target )
	local data = {};
	data.unit = unit;
	data.target = target;
	data.item = unit.heldItem;
	data.timeConsumed = 2;
	
	-- success/failure?
	data.success = true;
	
	return data;
end

function encounter.processItemUsage( data )
	data.unit.changeAP( -data.timeConsumed );
	data.item.use( data.unit, data.target );
	Overlay.updateUnitOverlay();
end

