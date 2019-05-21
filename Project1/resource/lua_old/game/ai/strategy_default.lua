-- default strategy
-- The default unit strategy for AI-based units. This strategy will be
-- used if no other strategy is specified for the unit.

require( "game.ai.strategy" );

function createDefaultStrategy()
  local ds = createStrategy();
  
  -- select actions for this unit, return them in a list
  function ds.chooseActions( unit )
    local t0 = j_System:currentTimeMillis();
    local actions = createList();
    
    local team = unit.team;
    local grid = _G.currentMap.grid;
    
    local t1 = j_System:currentTimeMillis();
    
    -- MOVE ACTION
    local moveActions = ds.generateMove( unit );
    actions.addList( moveActions );
    
    local t2 = j_System:currentTimeMillis();
    
    -- special action
    
    -- buff action
    
    -- debuff action
    
    -- HEALING ACTIONS (self only)
    local healActions = ds.generateHeal( unit );
    actions.addList( healActions );
    
    local t3 = j_System:currentTimeMillis();
    
    -- ATTACK ACTION (one for each unit in range)
    -- do this last since we need to get rid of enemy attack range data
    local attackActions = ds.generateAttack( unit );
    actions.addList( attackActions );
    
    -- explore
    local t4 = j_System:currentTimeMillis();
    local dt1 = t1-t0;
    local dt2 = t2-t1;
    local dt3 = t3-t2;
    local dt4 = t4-t3;
    local dt = t4-t0;
    print( 'performed in '..tostring( dt1 )..'ms : '..tostring( dt2 )..'ms : '..tostring( dt3 )..'ms : '..tostring( dt4 )..'ms...'..tostring(dt)..'ms' );
    
    return actions;
  end
  
  --[[ consider two types: advancement toward a target, single-unit strategic placement
  1) Advancement toward a target will be largely based on simple path finding which is
     truncated at the end of the movement range.
  2) Single-unit strategic placement will search for relevant choke points which limit
     enemy movement.
  Multi-unit strategic placement will be handled by danger avoidance and collaboration
  brought on by actions of opportunity. Retreating from a target will be handled by
  danger avoidance.
  ]]
  function ds.generateMove( unit )
    print( 'gen move' );
    local actions = createList();
    local map = _G.currentMap;
    local grid = map.grid;
    local team = unit.team;
    
    ---------------------------------
    --       targeted move        --
    ---------------------------------
    -- path find to target/goal
    if( team.goal ~= nil and team.goal.isExpired() == false ) then
      local moveAction = createAction( unit );
      moveAction.actionType = ACTION_MOVE_TARGET;
      moveAction.name = "Target Move";
      moveAction.hint = team.goal;
      
      print( 'goal: '..team.goal.tiles.get(1).toString() );
      grid.pathFindTargets.add( team.goal.tiles.get(1) ); -- team.goal does not exist yet!!
      grid.findPath();
      local path = grid.getPathForUnit( unit );
      grid.clearPathFinding();
    
      -- can we reach the goal in one move?
      if( path.length <= unit.getMoveRange() ) then
        -- how much damage will be sustained?
        -- will the unit die? is that still ok, weighed against benefits?
        local terminus = path.path.get( path.length );
        moveAction.path = path;
        --terminus.address.print();
        local damage = ds.computeDamageAtTile( unit, terminus );
        if( damage > unit.stat.hp ) then
          -- for now, set this to zero, but we really need to consider this in more detail!!
          moveAction.priority = 0;
          moveAction.terminus = terminus;
          print( 'gonna die probably '..terminus.address.toString() );
        else
          local priority = team.goal.priority; -- this needs to actually exist also!!
          priority = priority * (unit.stat.hp - damage) / unit.stat.hp;
          moveAction.priority = priority;
          moveAction.terminus = terminus;
          print( 'should be ok '..terminus.address.toString() );
        end
        
        -- if we're already at our target, then ruin this action's priority
        if( path.length <= 1 ) then
          print( 'WE ARE ALREADY HOME!!' );
          moveAction.priority = -1000;
        end
        
      else
        -- consider how many units can attack the prospective location, should we back up a bit?
        local length = unit.getMoveRange();
        print( 'TEST 1: '..tostring( length ) );
        local terminus = path.path.get( length );
        print( 'TEST 2: '..tostring( path.length ) );
        if( terminus.attackIndex > 0 ) then
          print( 'TEST 3' );
          
          -- how much damage might be done?
          print( 'apparently '..terminus.address.toString()..' is reachable: '..tostring( terminus.attackIndex ) );
          local termIndex = length;
          local damage = 0;
          for i = length, 1, -1 do
            termIndex = i;
            terminus = path.path.get( termIndex );
            damage = ds.computeDamageAtTile( unit, terminus );
            if( damage < unit.stat.hp ) then
              -- would it still be ok if the unit backed up once?
              -- would it avoid unnecessary damage?
              if( i > 1 ) then
                local alt = path.path.get( i-1 );
                local remLen = path.length - (i-1);
                local mod = remLen % unit.stat.mv;
                if( alt.attackIndex < terminus.attackIndex and mod ~= 1 ) then
                  -- it's fine to back up one
                  termIndex = termIndex - 1;
                  terminus = path.path.get( termIndex );
                  break;
                else
                  -- it's best if we don't back up
                  break;
                end
              end
            end
          end
          path.path.setLength( termIndex );
          path.vpath.setLength( termIndex );
          moveAction.path = path;
          -- compute priority
          -- if AP is not at max, priority takes a hit
          print( 'total damage '..tostring( damage ) );
          local priority = team.goal.priority; -- this needs to actually exist also!!
          local dmgDiff = unit.stat.hp - damage;
          if( dmgDiff < 0 ) then dmgDiff = 0; end
          priority = priority * dmgDiff / unit.stat.hp;
          priority = priority * (unit.stat.maxAP - unit.stat.ap)/unit.stat.maxAP;
          priority = priority * termIndex / unit.getMoveRange();
          moveAction.priority = priority;
          moveAction.terminus = terminus;
          print( 'might take some hits at '..terminus.address.toString() );
        else
          local priority = team.goal.priority; -- this needs to actually exist also!!
          priority = priority * unit.stat.ap/unit.stat.maxAP;
          moveAction.priority = priority;
          moveAction.terminus = terminus;
          path.path.setLength( unit.getMoveRange() );
          path.vpath.setLength( unit.getMoveRange() );
          moveAction.path = path;
          print( 'doing ok, I guess '..terminus.address.toString() );
        end
      end
      actions.add( moveAction );
    end
    
    ---------------------------------
    -- strategic placement (CHOKE) --
    ---------------------------------
    local strategicAction = createAction( unit );
    strategicAction.name = "Choke";
    strategicAction.targets = createList();
    strategicAction.actionType = ACTION_CHOKE;
    -- Ask the question: is there anything (at all) that we might want to keep enemies away from?
    -- Might we keep them from: teammates, items of interest on the map, targets of interest?
    -- The latter two would be specified by AI hints within the editor.
    -- Search in the vicinity of the current unit for teammates that might need shielding.
    local nearbyAllies = createList();
    for i = 1, team.units.length() do
      local ally = team.units.get(i);
      local addy = ally.tile.address;
      local dist = addy.hexDistanceTo( unit.tile.address );
      if( dist < unit.stat.mv ) then
        nearbyAllies.add( ally );
        strategicAction.targets.add( ally.tile );
      end
    end
    -- Compute a priority for protecting these units based on how vulnerable they are.
    -- how much pdamage?
    -- how many units can attack?
    -- unit importance (general or special)?
    local prioSum = 0;
    local avgNum = 0;
    local avgImp = 0;
    local attackers = createList();
    for i = 1, nearbyAllies.length() do
      local ally = nearbyAllies.get(i);
      local data = ds.computeDamage( ally, ally.tile.attackers );
      for j = 1, ally.tile.attackers.length() do
        attackers.addUnique( ally.tile.attackers.get(j) );
      end
      prioSum = prioSum + (data.pdamage - ally.stat.hp*0.75)/5;
      avgImp = avgImp + ally.stat.rating / 10.0;
      avgNum = data.numAttacks;
    end
    prioSum = prioSum / nearbyAllies.length();
    avgNum = avgNum / nearbyAllies.length();
    avgImp = avgImp / nearbyAllies.length();
    prioSum = prioSum * avgNum + avgImp;
    
    -- Scaled based on unit stats (This unit is likely to take punishment. Can it handle it?)
    local unitData = ds.computeDamage( unit, attackers );
    --prioSum = prioSum * (unit.stat.hp - unitData.pdamage);
    strategicAction.priority = prioSum;
    strategicAction.nearbyAllies = nearbyAllies;
    strategicAction.attackers = attackers;
    actions.add( strategicAction );
    
    -----------------------------------
    -- strategic placement (PROVOKE) --
    -----------------------------------
    
    return actions;
  end
  
  --[[ consider three cases:
  1) Unit could use some more HP, but is not in danger of dying
  2) Unit is in danger of dying, and healing will help the situation
  3) Unit is in danger of dying, and healing will not help
  In the case of 1, the priority will be significantly lower than case 2.
  In the case of 3, action type will be changed to AVOID_DANGER
  ]]
  function ds.generateHeal( unit )
    print( 'gen heal' );
    local actions = createList();
    
    -- For now, let's make sure that the unit actually has an item in its inventory to facilitate the healing.
    -- Eventually, we should also check if nearby allies has an item.
    local item = unit.getItemOfType( ITEM_HEALING );
    if( item == nil ) then
      return actions;
    end
    
    local selfAction = createAction( unit );
    selfAction.item = item;
    selfAction.name = "Heal";
    local priority = 0;
    selfAction.target = unit;
    selfAction.actionType = ACTION_HEAL;
    -- current HP
    local potentialDmg = ds.computeDamage( unit, unit.tile.attackers );
    local remHP = unit.stat.hp - potentialDmg.pdamage;
    if( remHP <= 0 ) then
      local diff = unit.stat.maxHP - potentialDmg.pdamage;
      if( diff < 0 ) then
        -- healing won't help
        -- use some type of influence map to determine level of danger
        selfAction.actionType = ACTION_AVOID_DANGER;
        selfAction.name = "Danger Avoid";
        priority = priority + 0; -- need to actually do this !!!!!!!!!!!!
      else
        -- healing will help
        priority = priority - remHP * unit.stat.priorityRank;
        
        -- HP gap (do you really need to be healed?)
        -- scale priority up/down if unit is missing more/less than 1/4 of max HP
        priority = priority * (unit.stat.maxHP - unit.stat.hp)/(0.25*unit.stat.maxHP);
      end
    else
      -- no emergency to heal (scale down by some factor)
      priority = priority + (unit.stat.maxHP - unit.stat.hp)/2;
    end
    
    selfAction.priority = priority;
    actions.add( selfAction );
    
    return actions;
  end
  
  function ds.generateAttack( unit )
    print( 'gen atk' );
    local team = unit.team;
    local actions = createList();
    
    -- find target units which are in range
    local targets = ds.findTargetUnits( unit );
    if( targets == false ) then return actions; end
    for i = 1, targets.length() do
      local target = targets.get(i);
      local attAction = ds.generateAttackOn( unit, target );
      actions.add( attAction );
    end
    
    -- consider targets which are barely out of range
    -- (move in to provoke attack)
    
    return actions;
  end
  
  -- generate a single attack
  function ds.generateAttackOn( unit, target )
    print( 'gen atk on '..unit.name );
    local team = unit.team;
    local ts = team.ai.strategy;
    local us = unit.ai.strategy;
    local up = unit.ai.parameters;
    
    local priority = 0;
    local attAction = createAction( unit );
    attAction.name = "Attack";
    
    local atkData = unit.simulateAttack( target );
    attAction.target = target;
    attAction.actionType = ACTION_ATTACK;
    local violence = (ts.violence + up.violence)*0.5;
    
    -- compute attack effectiveness
    local atkEff = atkData.damage * atkData.acc/100;
    local cntData = target.simulateAttack( unit );
    local cntEff = 0;
    if( atkData.kill == false ) then
      cntEff = cntData.damage * cntData.acc/100;
    else
      -- if the target unit is going to die, consider the effect of the change in enemy presence
      -- units whose attack burden has been lightened
      -- increased ally mobility
    end
    
    priority = (unit.stat.rating - target.stat.rating + atkEff - cntEff)*(1 + violence * up.synergy/100.0);
    
    -- does this action help with the team's goal?
    local goal = 0;
    if( goal == GOAL_ROUT ) then goal = 10; end
    if( goal == GOAL_SURVIVE ) then
      -- will the target die?
      local targetImp = target.computeAttackPower();
      goal = targetImp + 0.5*violence;
      if( atkData.kill ) then goal = goal + violence; end
    end
    
    priority = priority + ts.goal * up.synergy * goal;
    attAction.priority = priority;
    attAction.atkData = atkData;
    attAction.cntData = cntData;
    return attAction;
  end
  
  -- analysis plugs
  --[[ Returns an action, chosen based on unit capability, which is most beneficial
    to perform after a move action. This is for edge cases in which a move action has
    been chosen, but there may be more to do than simply move. This function considers
    if there is some benefit to making use of the rest of the move, rather than simply
    ending after the move.
  ]]
  function ds.secondaryAction( primaryAction )
    print( 'sec action' );
    local unit = primaryAction.unit;
    local map = _G.currentMap;
    local grid = map.grid;
    local team = unit.team;
    local ts = team.ai.strategy;
    local us = unit.ai.strategy;
      
    -- temporarily move unit to new location to get its 0-move attack range
    unit.prevLocation = unit.location;
    unit.prevTile = unit.tile;
    unit.tile = primaryAction.terminus;
    unit.location = unit.tile.address;
    local atkRange = grid.getAttackRange( unit, 0 );
    local enemies = createList();
    for i = 1, atkRange.length() do
      local tile = atkRange.get(i);
      if( tile.occupant ~= nil and tile.occupant.team ~= unit.team ) then
        enemies.add( tile.occupant );
      end
    end
    
    -- simulate the attack
    -- pick enemy with highest priority, if target is null, then none of them were good
    local bestTarget = nil;
    local atkPriority = 0;
    for i = 1, enemies.length() do
      local target = enemies.get(i);
      local atkData = unit.simulateAttack( target );
      -- compute attack effectiveness
      local violence = (ts.violence + us.violence)*0.5;
      local atkEff = atkData.damage * atkData.acc/100;
      local cntData = target.simulateAttack( unit );
      local cntEff = 0;
      local priority = 0;
      if( atkData.kill ) then
        priority = atkEff*(1 + violence * us.synergy/100.0 + target.stat.priorityRank);
      else
        cntEff = cntData.damage * cntData.acc/100;
        if( cntData.kill ) then
          cntEff = cntEff * 100;
        end
        priority = (atkEff - cntEff)*(1 + violence * us.synergy/100.0);
      end
      
      -- compare priorities
      if( priority > atkPriority ) then
        atkPriority = priority;
        bestTarget = target;
      end
    end
    
    -- choose best target, if there is one
    local attackPair = {};
    attackPair.priority = 0;
    if( bestTarget ~= nil ) then
      local action = createAction();
      action.actionType = ACTION_ATTACK;
      action.unit = unit;
      action.target = bestTarget;
      attackPair.action = action;
      attackPair.priority = atkPriority;
    end
    
    
    -- Heal ourselves with an item?
    -- need to choose most appropriate healing item, if there is more than one type
    local healItem = unit.getItemOfType( ITEM_HEALING );
    local healPair = {};
    healPair.priority = 0;
    if( healItem ~= nil ) then
      local action = createAction();
      action.actionType = ACTION_HEAL;
      action.unit = unit;
      action.target = unit;
      healPair.action = action;
      healPair.priority = unit.stat.maxHP - unit.stat.hp;
    end
    
    -- Buff ourselves or someone else within range?
    local buffItem = unit.getItemOfType( ITEM_BUFF );
    local buffPair = {};
    buffPair.priority = 0;
    if( buffItem ~= nil ) then
      -- need to implement once specific buff items exist
      local action = createAction();
      action.unit = unit;
      -- choose a target
      buffPair.action = action;
      buffPair.priority = 0; -- dummy value
    end
    
    -- Debuff a nearby enemy?
    local debuffItem = unit.getItemOfType( ITEM_DEBUFF );
    local debuffPair = {};
    debuffPair.priority = 0;
    if( debuffItem ~= nil ) then
      -- need to implement once specific debuff items exist
      local action = createAction();
      action.unit = unit;
      -- choose a target
      debuffPair.action = action;
      debuffPair.priority = 0; -- dummy value
    end
    
    -- create a list of (action,priority) pairs
    local actions = createList();
    actions.add( attackPair );
    actions.add( healPair );
    actions.add( buffPair );
    actions.add( debuffPair );
    
    -- choose the action with the highest non-zero priority
    local bestPair = {};
    bestPair.action = nil;
    bestPair.priority = 0;
    local bestIndex = 0;
    for i = 1, actions.length() do
      local pair = actions.get(i);
      if( pair.priority > bestPair.priority ) then
        bestPair = pair;
      end
    end
    
    -- move unit back to where it actually is, movement must be done via animation
    unit.tile = unit.prevTile;
    unit.location = unit.prevLocation;
    
    return bestPair.action;
  end
  
  -- utility
  function ds.computeDamage( unit )
    local map = _G.currentMap;
    local grid = map.grid;
    
    -- check all hostile units' attack range, simulate attacks
    -- for those that can reach this unit
    local damage = 0;
    for i = 1, unit.tile.attackers.length() do
      local hunit = unit.tile.attackers.get(i);
      if( unit.tile.attack ) then
        local data = hunit.simulateAttack( unit );
        damage = damage + data.damage * data.acc/100.0;
      end
    end
    return damage;
  end
  
  function ds.computeDamageAtTile( unit, tile )
    local damage = 0;
    
    for i = 1, tile.attackers.length() do
      local hunit = tile.attackers.get(i);
      local data = hunit.simulateAttack( unit );
      damage = damage + data.damage * data.acc/100.0;
    end
    
    return damage;
  end
  
  function ds.computeDamage( unit, attackers )
  local map = _G.currentMap;
  local grid = map.grid;
  local atkData = {};
  atkData.pdamage = 0;
  atkData.damage = 0;
  atkData.hit = 1.0;
  atkData.numAttacks = 0;
    
  -- check all hostile units' attack range, simulate attacks
  -- for those that can reach this unit
  for i = 1, attackers.length() do
    local hunit = attackers.get(i);
    local data = hunit.simulateAttack( unit );
    atkData.pdamage = atkData.pdamage + data.damage * data.acc/100.0;
    atkData.damage = atkData.damage + data.damage;
    atkData.hit = atkData.hit * data.acc/100.0;
    atkData.numAttacks = atkData.numAttacks + 1;
  end
  
  return atkData;
end
  
  
  function ds.findTargetUnits( unit )
    local targets = createList();
    
    local map = _G.currentMap;
    local grid = map.grid;
    local atkRange = unit.range.attack;
    
    -- scan tiles for a unit to attack
    for i = 1, atkRange.length() do
      local tile = atkRange.get(i);
      local target = tile.occupant;
      if( target ~= nil and target.team ~= unit.team ) then
        targets.add( target );
      end
    end
    
    grid.clearTilesAlt( atkRange );
    return targets;
  end

  
  return ds;
end

