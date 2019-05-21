-- ai logic control
AIControl = createControlRegime();

function AIControl.activate()
  
  -- Only control the NPC units if the local machine is the server
  -- the client side will receive instructions to animate NPC units
  -- in the usual fashion, and no AI computation is to be performed.
  if( Local_Server == false ) then return end;
  PrimaryControl = AIControl;
  
  -- process main AI loop
  AIControl.main();
  
end

function AIControl.main()
  
  if( GameState.activePlayer.remainingMoves == 0 ) then
    GameState.switchTeams();
    return;
  end
  
  local player = GameState.activePlayer;
  local team = player.team;
  
  -- mark attack for current team and its hostile teams
  local t0 = j_System:currentTimeMillis();
  local grid = _G.currentMap.grid;
  for i = 1, team.hostileTeams.length() do
    local hteam = team.hostileTeams.get(i);
    grid.markAttackForTeam( hteam );
  end
  grid.markAttackForTeam2( team );
  local t1 = j_System:currentTimeMillis();
  local dt = t1-t0;
  print( 'ranges marked in '..tostring( dt )..'ms' );
  
  -- prepare actions for each available unit on the team
  Action_Queue.clear();
  for i = 1, team.units.length() do
    local unit = team.units.get(i);
    if( unit.available() == false ) then goto unitCont; end
    if( unit.stat.ap < unit.stat.minAP ) then goto unitCont; end
    -- consider the best action for each unit
    local actions = unit.ai.strategy.chooseActions( unit );
    for j = 1, actions.length() do
      Action_Queue.queueItem( actions.get(j) );
    end
    ::unitCont::
  end
  
  -- if the queue is empty, then there's nothing to do
  if( Action_Queue.length() == 0 ) then
    GameState.endTurn();
    GameState.switchTeams();
    return;
  end
  
  -- debug
  for i = 1, Action_Queue.length() do
    local action = Action_Queue.get(i);
    action.print();
  end
  
  -- verify that top priority move can and should be executed
  local action = AIControl.verifyAction( Action_Queue.top() );
  
  -- cleanup
  -- clear grid markings
  grid.clearMarkings();
  
  -- iterate through the queue, executing actions
  -- Java returns from animation calls immediately
  -- The game state needs to be handed over to a separate set of functions to execute
  -- these actions. The flow should be as follows:
  -- call action.execute() for the top item in the queue
  -- wait for AIControl.animationFinished() to be called by Java
  -- perform any necessary cleanup, then call the next action in the queue (until no more moves)
  -- if executed action is final action to be performed, set a flag to be used by animation callback to yield control back to player
  print( 'executing action' );
  GameState.activePlayer.activeUnit = action.unit;
  action.execute();
end


--[[ Assess the given action, adjust its priority, then
  check if it is still the highest priority action. If its
  score has fallen lower than other actions in the queue, then
  requeue it, and assess the next action in the queue. This
  function will return the first assessed function that lands
  on the top of the priority queue.
]]
function AIControl.verifyAction( action )
  print( 'verify action' );
  -- Has this action already been assessed? If so, then have it executed.
  if( action.assessed ) then
    AIControl.constructAction( action );
    return action;
  end
  local retAction = action;
  
  AIControl.assessAction( action );
  -- does this action now consider collaboration?
  if( action.collaboraitve ) then
    Action_Queue.pop();
    for i = 1, action.collabList.length() do
      Action_Queue.list.insert( action.collabList.get(i), 1 );
    end
    
  end
  
  -- check the adjusted priority
  if( Action_Queue.length() >=2 and action.priority < Action_Queue.get(2).priority ) then
    print( 'demoting action' );
    Action_Queue.pop();
    Action_Queue.queueItem( action );
    retAction = Action_Queue.top();
    return AIControl.verifyAction( retAction );
  end
  
  AIControl.constructAction( action );
  return retAction;
end

--[[ Construct actions based on their type. Add action items to the action so that each item can
  be executed in order.
]]
function AIControl.constructAction( action )
  print( 'construct action' );
  local actionType = action.actionType;
  
  -- restructure action if there is a secondary action within
  if( action.secondaryAction ~= nil ) then
    AIControl.compileAction( action );
  end
  
  if( actionType == ACTION_MOVE_TARGET ) then
    -- If we have no secondary action, we really just have a MOVE action. Otherwise, we should compile the action
    -- and relabel it as what its secondary action type is.
    local camItem = createActionItem( AIControl.camExec );
    local moveItem = createActionItem( AIControl.moveExec );
    local waitItem = createActionItem( AIControl.waitExec );
    action.addItem( camItem );
    action.addItem( moveItem );
    action.addItem( waitItem );
    
  elseif( actionType == ACTION_ATTACK ) then
    local camItem = createActionItem( AIControl.camExec );
    if( action.terminus ~= nil ) then
      local moveItem = createActionItem( AIControl.moveExec );
      action.addItem( camItem );
      action.addItem( moveItem );
    end
    action.addItem( camItem );
    local attackItem = createActionItem( AIControl.attackExec );
    action.addItem( attackItem );
    
  elseif( actionType == ACTION_HEAL ) then
    local camItem = createActionItem( AIControl.camExec );
    if( action.terminus ~= nil ) then
      local moveItem = createActionItem( AIControl.moveExec );
      action.addItem( camItem );
      action.addItem( moveItem );
    end
    local healItem = createActionItem( AIControl.healExec );
    action.addItem( camItem );
    action.addItem( healItem );
    
  elseif( actionType == ACTION_ACTIVATE ) then
    local camItem = createActionItem( AIControl.camExec );
    if( action.terminus ~= nil ) then
      local moveItem = createActionItem( AIControl.moveExec );
      action.addItem( camItem );
      action.addItem( moveItem );
    end
    local activateItem = createActionItem( AIControl.activateExec );
    action.addItem( camItem );
    action.addItem( activateItem );
  end
    
end

--[[ Used for compound actions. This generally occurs when a secondary action is added to
  a move action. This function will 
]]
function AIControl.compileAction( action )
  local sa = action.secondaryAction;
  local actionType = sa.actionType;
  action.actionType = actionType;
  if( actionType == ACTION_ATTACK ) then
    action.target = sa.target;
  elseif( actionType == ACTION_HEAL ) then
    action.target = sa.target;
  end
  
end

-- EXECUTION ACTIONS
function AIControl.waitExec( action )
  local map = _G.currentMap;
  
  -- send
  local data = {};
  data.id = NET_CONFIRM_ACTION;
  data.unitID = action.unit.id;
  data.totalAP = GameState.currentAP;
  PF.sendData( data );
  
  -- reset
  map.selectedUnit = nil;
  PF.clearMovePath();
  PF.clearRanges();
  PF.markRanges();
  
  -- confirm
  PF.confirmUnit();
  GameState.executeAction( false );
  PF.syncActionPoints( GameState.activePlayer.activeUnit );
  GameState.activePlayer.activeUnit = nil;
  
  updateUnitDisplay();
  
  action.execute();
end

function AIControl.camExec( action )
  local target = action.unit.tile;
  if( target ~= nil ) then
    PF.moveCursorToTile( target );
    local data = {};
    data.id = NET_MOVE_CURSOR;
    data.location = target.address;
    PF.sendData( data );
  else
    action.execute();
  end
end

function AIControl.moveExec( action )
  print( 'moving a dude '..tostring( action.path.path.length()-1 )..' tiles' );
  if( action.path.length < 2 ) then
    print( 'ZERO PATH LEN. WTF OBAMA?' );
    action.execute();
    return;
  end
  
  moveUnitRemote( action.unit, action.path.vpath );
  local data = {};
  data.id = NET_UNIT_PATH;
  PF.sendData( data );
  
  GameState.addAP( action.path.length );
end

function AIControl.activateExec( action )
  print( 'activating some kind of thing!' );
  action.hint.activate( action.unit );
  print( 'finished activating it' );
  action.execute();
end

function AIControl.attackExec( action )
  print( 'attacking a dude' );
  local map = _G.currentMap;
  local grid = map.grid;
  
  local data = encounter( action.unit, action.target, ENCOUNTER_ATTACK );
  -- display damage
  displayDamage( data );
  
  -- confirm
  PF.syncActionPoints( action.unit );
  
  -- send attack
  data.id = NET_ATTACK;
  data.attackerID = data.attacker.id;
  data.targetID = data.target.id;
  PF.sendData( data );
  
  -- send confirm for move
  local data0 = {};
  data0.id = NET_CONFIRM_ACTION;
  data0.unitID = action.unit.id;
  data0.totalAP = GameState.currentAP + data.totalTime;
  PF.sendData( data0 );
  
  GameState.addAP( data.totalTime );
  GameState.executeAction( false );
end

function AIControl.healExec( action )
  print( 'healing a dude...' );
  
  action.item.func( action.unit, action.item, false );
end


-- MAIN LOGIC
function AIControl.assessAction( action )
  print( 'assess action' );
  -- check that the action can be carried out
  if( AIControl.validateAction( action ) ) then
    -- if action can be executed, assess risks, and adjust priority
    AIControl.analyzeAction( action );
  else
    -- if it cannot, assess using collaborative action
    -- if it still cannot be executed, then throw it out
    action.priority = 0;
  end
  
end

--[[ Validates actions by checking to make sure that
  the execution is possible.
]]
function AIControl.validateAction( action )
  print( 'validate action' );
  local actionType = action.actionType;
  if( actionType == ACTION_MOVE_TARGET ) then
    return true;
  elseif( actionType == ACTION_HEAL ) then -- also need to consider the case of healer, eventually
    -- does this unit have healing items?
    return action.unit.getItemOfType( ITEM_HEALING ) ~= nil;
  elseif( actionType == ACTION_ATTACK ) then
    return true;
  elseif( actionType == ACTION_AVOID_DANGER ) then
    -- Assume it's true. The analysis function will consider collaborative action. If it's impossible,
    -- then the priority will be set to zero.
    return true;
  elseif( actionType == ACTION_CHOKE ) then
    -- probably need to actually do something here
    return true;
  end
  
  return false;
end

--[[ Considers details of action, analyzes risks and
  field conditions to further specify the action, and
  adjusts the priority of the action.
]]
function AIControl.analyzeAction( action )
  print( 'analyze action' );
  local actionType = action.actionType;
  if( actionType == ACTION_MOVE_TARGET ) then
    AIControl.analyzeMove( action );
    -- check surroundings for droppings
    -- eat as much as you can stomach
    -- leave happy or not at all
  elseif( actionType == ACTION_HEAL ) then
    AIControl.analyzeHeal( action );
    -- drive to Publix
    -- purchase three cases of beer
    -- throw cans at cars in the lot
  elseif( actionType == ACTION_ATTACK ) then
    AIControl.analyzeAttack( action );
    -- open four large cans of pinto beans
    -- consume contents of all four cans
    -- climb Mount Firetop
    -- unleash your wrath upon the world below
  elseif( actionType == ACTION_AVOID_DANGER ) then
    AIControl.analyzeAvoid( action );
    -- pour three spoonfuls of Metamucil into a glass
    -- fill glass with water, and stir vigorously
    -- proceed to restroom
  elseif( actionType == ACTION_CHOKE ) then
    AIControl.analyzeChoke( action );
  end
end

function AIControl.analyzeMove( action )
  print( 'analyze move' );
  -- General risks have already been taken into account
  -- Consider the possibility of making use of another type of action before the action ends.
  -- These considerations must only be used if they are feasible and yield a net positive result.
  -- After moving, would it be beneficial to: (AP considerations need also be made)
  -- Attack someone/something?
  -- Compute priorities for each of these actions, and choose the best one, if any can be done.
  local unit = action.unit;
  -- These actions are to be determined by the unit strategy. If no secondaryAction() is specified,
  -- then no actions will be chosen.
  local hint = action.hint;
  local secondAction = nil;
  if( hint.tiles.contains( action.terminus ) ) then
    secondAction = createAction( unit );
    secondAction.actionType = ACTION_ACTIVATE;
  else
    secondAction = unit.ai.strategy.secondaryAction( action );
    if( secondAction == nil ) then return; end
  end
  
  -- If an action was chosen as a beneficial post-move, then incorporate it into the original action.
  -- Change original action from "move" type to the type chosen, and add priorities
  action.actionType = secondAction.actionType;
  action.priority = action.priority + secondAction.priority;
  
  if( secondAction.actionType == ACTION_ATTACK ) then
    action.target = secondAction.target;
  elseif( secondAction.actionType == ACTION_HEAL ) then
    action.target = action.unit;
    action.item = secondAction.item;
  elseif( secondAction.actionType == ACTION_BUFF ) then
    -- to do
  elseif( secondAction.actionType == ACTION_DEBUFF ) then
    -- to do
  elseif( secondAction.actionType == ACTION_ACTIVATE ) then
    -- anything to do?
  end
  
  
end


function AIControl.analyzeAttack( action )
  print( 'analyze attack on '..action.target.name );
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  local team = unit.team;
  -- Where is the optimal place for the unit to stand to launch the attack?
  -- Find the best place to stand, and then evaluate its quality, adjusting the priority score of the original action.
  -- collect a list of tiles this unit can stand on whilst attacking (large attack ranges mean more valid tiles)
  local tiles = grid.getAttackPlacement( unit, action.target.tile );
  tiles.remove( action.target.tile );
  print( 'in order to launch an attack against '..action.target.name..', we have '..tostring( tiles.len )..' tiles.' );
  if( tiles.length() == 0 ) then
    action.priority = 0;
    return;
  elseif( tiles.length() == 1 ) then
    -- evaluate quality, adjust priority
    
  end
  
  -- Probabilistic damage will be one of the major deciding factors, but we also need to consider how much luck has to
  -- do with the amount of damage taken. If the unit is simply unlikely to die due to a low hit chance, then consider the
  -- risk to be high. If the unit is unlikely to die due to a high defensive stat (overall low damage), then the risk will
  -- be low, even the unit is not left with much HP.
  -- Another factor, which will be weighed against tile parameters, is the distance moved to reach the tile.
  -- Strategic placement will be considered once choke point analysis can be done.
  
  -- Assume that there is a chance that the primary target is going to die. We have to consider changes that will be made to
  -- enemy attack ranges based on this unit's absence.
  -- mark new ranges for hostile teams
  for i = 1, team.hostileTeams.length() do
    local hteam = team.hostileTeams.get(i);
    grid.markAttackForTeamWI( hteam, action.target );
  end
  
  -- Original attack data
  local oad = action.atkData;
  local bestTile = nil;
  local bestPriority = -1000000;
  for i = 1, tiles.length() do
    local tile = tiles.get(i);
    local attackers = nil;
    
    -- Primary attack data: consider differences in attacking the unit from the current tile versus what the original
    -- attack data reports. Use this to make a priority adjustment.
    local pad = unit.simulateAttack( action.target, tile, nil );
    local kill = pad.kill;
    local priority = (pad.damage - oad.damage);
    if( kill ) then
      priority = priority + action.target.stat.rating/12;
    end
    
    
    -- use the appropriate set of attackers to compute damage
    if( kill ) then attackers = tile.attackersWI;
    else attackers = tile.attackers; end
    
    -- need to move part of this outside the loop, otherwise the "what if" scenario will play out many times, rather than once
    local atkData = AIControl.computeDamage( unit, attackers, action.target );
    
    -- Let the average HP left over from all attacks (HP gap, G) balance when it equals how much damage luck might save us from taking.
    -- Also, scale this equation to balance when G is some value V (let V = maxHP/3, in this case). The following scaling will
    -- go to one when G is 1.5*V, and higher for larger values of G.
    -- Note: G is interpreted as the average HP left after all attacks. D is the difference between the max damage and the probabilistic
    -- damage. It is an effective (average) measure of how much the unit would have to depend on luck (the random roll on hit%) to get by.
    -- D/N is the average damage avoided (by luck) per attack received.
    
    -- NOTE: It may be worth looking into computing damage returned to these attackers in computing priorities. This correction should
    -- be scaled significantly lower since there is no guarantee than any particular unit is actually going to attack, but this consideration
    -- should allow for some slightly more sophisticated behavior.
    -- ALSO NOTE: Another thing that needs to be considered are limitations on number of possible attackers. If a particular tile has a
    -- large number of potential attackers, then it is likely that only a small subset of them may actually be capable of delivering
    -- attacks within a single turn. Limiting factors include footing (somewhat less rigorous since units can be killed, and also
    -- can have ranged attacks), number of moves per turn allowed.
    local V = unit.stat.maxHP/3;
    local G = unit.stat.hp - atkData.pdamage;
    local D = atkData.damage - atkData.pdamage;
    local N = atkData.numAttacks;
    priority = priority + (G - D/N) * 2*(G - V)/V;
    
    -- AP consumption balances at n, the number of tiles away the target stands. If the unit can stand anywhere closer than n
    -- tiles away, then the priority will receive a positive boost; farther than n, a penalty incurred.
    local n_tile = tile.address.hexDistanceTo( unit.tile.address );
    local n_target = action.target.tile.address.hexDistanceTo( unit.tile.address );
    local AP_IMPORTANCE = 1.0;
    priority = priority + (n_target - n_tile)*AP_IMPORTANCE;
    
    -- Also to be considered is proximity of the tile to other beneficial assets: healer, high affinity units, leader, etc.
    -- Consider terrain: strategic chokes, tile parameters
    
    if( priority > bestPriority ) then
      bestPriority = priority;
      bestTile = tile;
    end
    
  end
  
  -- clean up the "what if" scenario
  grid.clearAttackWI();
  
  -- this really should never happen
  if( bestTile == nil ) then
    print( 'SHOULD NOT HAPPEN' );
    action.priority = 0;
    return;
  end
  
  -- path find to best tile and clean up
  grid.addPathFindingTarget( bestTile );
  grid.findPath();
  local path = grid.getPathForUnit( unit );
  grid.clearPathFinding();
  
  -- set action parameters and return
  action.path = path;
  action.terminus = bestTile;
  action.priority = action.priority + bestPriority;
  
  print( 'ATK PRIORITY: '..tostring( action.priority ) );
end


--[[ Check for the existence of a target that this unit might be tracking. If one exists, then we should
  consider moving toward it; path find to it, and allow the pathValCost to influence the scored priority. In either case,
  all tiles within the unit's move range will be considered for offensive and defensive positioning.
  ]]
function AIControl.analyzeHeal( action )
  print( 'analyze heal' );
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  
  -- Now that this unit will be healed, can/should it be on the offensive, defensive, or general strategy?
  -- Find movement range, then consider offensive positioning and defensive positioning. Compute priorities for both,
  -- then pick the best one.
  local range = grid.getTilesWithinRange( unit, unit.getMovementRange(), false );
  unit.range.movement = range;
  
  local seekGoal = unit.team.goal ~= nil;
  if( seekGoal ) then
    grid.addPathFindingTarget( unit.team.goal.tiles.get(1) );
    grid.findPath();
  end
  
  -- compute damage for current tile (use for defensive priority)
  local oad = AIControl.computeDamage( unit, unit.tile.attackers, nil );
  
  local bestOffenseTile = nil;
  local bestOffensePriority = -10000000;
  local bestDefenseTile = nil;
  local bestDefensePriority = -10000000;
  for i = 1, range.length() do
    local tile = range.get(i);
    
    local atkData = AIControl.computeDamage( unit, tile.attackers, nil );
    
    -- Offensive moves involve saddling up next to an enemy unit to provoke attack, or sitting on a tile with high attack.
    -- see AIControl.analyzeAttack() for meaning of calculation
    -- NOTE: need to take pathfind result into account
    local V = unit.stat.maxHP/3;
    local G = atkData.pdamage - unit.stat.hp;
    local D = atkData.damage - atkData.pdamage;
    local N = atkData.numAttacks;
    local R = unit.tile.pathValCost - tile.pathValCost;
    local offensePriority = (G - D/N) * 2*(G - V)/V;
    
    -- Defensive moves will take the unit away from combat areas.
    -- Defensive priorities will, by default, max out far lower than offensive priorities. If we can be on the offensive,
    -- we should be. If we cannot, then we should look to defensive positioning. Defensive priority scaling will be such
    -- that a high defensive score will be comparable to a low offensive score.
    -- Defensive priorities should also take proximity to healers and other strong units (perhaps the leader) into account
    -- Base priority depends on damage difference between where the unit currently stands, and at the prospective tile.
    local defensePriority = oad.pdamage - atkData.pdamage;
    
    -- adjust priorities if seeking a goal
    if( seekGoal ) then
      offensePriority = offensePriority + R;
      defensePriority = defensePriority + R;
    end
    
    -- compare priorities to best
    if( offensePriority > bestOffensePriority ) then
      bestOffensePriority = offensePriority;
      bestOffenseTile = tile;
    end
    if( defensePriority > bestDefensePriority ) then
      bestDefensePriority = defensePriority;
      bestDefenseTile = tile;
    end
    
  end
  
  -- clean up
  grid.clearPathFinding();
  
  -- choose between the best of offensive and defensive positions
  local terminus = nil;
  if( bestOffensePriority > bestDefensePriority ) then
    terminus = bestOffenseTile;
    action.priority = action.priority + bestDefensePriority;
  else
    terminus = bestDefenseTile;
    action.priority = action.priority + bestOffensePriority;
  end
  
  -- find path to whichever target tile was chosen, mark it within the action
  grid.addPathFindingTarget( terminus );
  local path = grid.getPathForUnit( unit );
  action.path = path;
  action.terminus = terminus;
  grid.clearPathFinding();
  
end

function AIControl.analyzeAvoid( action )
  print( 'analyze avoid' );
  -- Healing has already been ruled out as a possible way to help, but it could still be useful if: (it's necessary and...)
  -- Units strategically block enemy attacks
  -- Current unit flees, entirely or partially out of attack range
  -- Allied units can kill one or more enemmies which threaten this unit. (make sure to take unit synergy into account)
  -- We need to also consider if this unit might be able to simply retreat on its own. If this is the case, then this action
  -- should be saved for last, as the issue may well be resolved by alternative means, for free. Only consider this option if
  -- healing is not required/important. If the unit cannot fix its
  -- own situation, then collaborative action must be employed, using one of the above methods.
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  
  -- Can the unit escape from danger by itself?
  local oad = AIControl.computeDamage( unit, unit.tile.attackers, nil );
  local range = grid.getTilesWithinRange( unit, unit.getMovementRange(), false );
  unit.range.move = range;
  local bestFleePriority = -100000000;
  local bestFleeTile = nil;
  for i = 1, range.length() do
    local tile = range.get(i);
    local td = AIControl.computeDamage( unit, tile.attackers, nil );
    -- need to think this one over some more
    local fleePriority = (oad.pdamage - td.pdamage)/unit.stat.maxHP * (unit.stat.hp - td.pdamage);
    
    if( fleePriority > bestFleePriority ) then
      bestFleePriority = fleePriority;
      bestFleeTile = tile;
    end
    
  end
  
  -- COLLABORATIVE ACTION
  -- Can other allied units quell the threat by eliminating it?
  local attackCollab = attackCollab( unit );
  local attackCollabActions = attackCollab.actions;
  local bestAttackCollabPriority = attackCollab.bestPriority;
  
  -- Can other allied unit(s) block the threat by using strategic positioning (chokes)?
  local chokeCollab = chokeCollab( unit );
  
  -- compare collab priority with flee priority
  if( bestAttackCollabPriority > bestFleePriority ) then
    action.priority = action.priority + bestAttackCollabPriority;
    action.collaborative = true;
    action.collabList = attackCollabActions;
  else
    action.priority = action.priority + bestFleePriority;
    -- set action parameters for fleeing
    action.terminus = bestFleeTile;
  end
  
end

-- TODO: DO THIS AT SOME POINT, I GUESS!!
function AIControl.chokeCollab( unit )
  print( 'choke collab' );
end

function AIControl.analyzeChoke( action )
  print( 'analyze choke' );
  local unit = action.unit;
  local team = unit.team;
  local map = _G.currentMap;
  local grid = map.grid;
  action.actionType = ACTION_MOVE_TARGET;
  
  local allies = createList();
  local enemies = createList();
  allies.add( unit );
  enemies.addList( unit.tile.attackers );
  grid.analyzeLocalFlow( allies, enemies );
  -- locate the best choke tile by pathfinding
  grid.pathFindTargets.add( unit.tile );
  grid.findPath();
  local bestTiles = createList();
  for i = 1, enemies.length() do
    local path = grid.getPathForUnit( enemies.get(i) );
    local maxFlow = 0;
    local bestTile = nil;
    -- trace paths from all relevant enemies
    -- store the best tile for each enemy in a list
    -- choose the best tile based upon other criteria
    for j = 1, path.length do
      local tile = path.path.get(j);
      if( tile.localFlowIndex > maxFlow ) then
        bestTile = tile;
        maxFlow = tile.localFlowIndex;
      end
    end
    bestTiles.addUnique( bestTile );
  end
  grid.clearPathFinding();
  if( bestTiles.length() == 0 ) then
    action.priority = 0;
    action.path = {};
    action.path.path = createList();
    action.path.vpath = createList();
    action.path.length = 0;
    return;
  end
  
  -- TODO: need to consider the possibility of moving toward the choke if the unit cannot reach it rather than
  -- just throwing the idea of trying out the window.
  --If we only have one tile in the list, then it's a genuine choke, and we should just determine the quality
  if( bestTiles.length() == 1 ) then
    local quality = AIControl.computeChokeQuality( action, bestTiles.get(1) );
    action.priority = action.priority + quality;
    action.terminus = bestTiles.get(1);
    grid.pathFindTargets.add( bestTiles.get(1) );
    grid.findPath();
    action.path = grid.getPathForUnit( unit );
  else
    -- We have several potential chokes. It's possible that some of these tiles might be effective for choking,
    -- but it's also possible that we're simply not looking at a situation where a choke actually exists.
    local maxQuality = -100000;
    local bestChoke = nil;
    for i = 1, bestTiles.length() do
      local tile = bestTiles.get(i);
      local quality = AIControl.computeChokeQuality( action, tile );
      if( quality > maxQuality ) then
        maxQuality = quality;
        bestChoke = tile;
      end
    end
    action.priority = action.priority + maxQuality;
    action.terminus = bestChoke;
    grid.pathFindTargets.add( bestChoke );
    grid.findPath();
    action.path = grid.getPathForUnit( unit );
  end
  grid.clearPathFinding();
  
end

function AIControl.computeChokeQuality( action, choke )
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  
  local quality = 0;
  -- how much damage will the unit take standing here?
  local data = AIControl.computeDamage( unit, choke.attackers );
  -- it may be OK if this unit bites the dust, but it would be best if that didn't happen
  quality = quality + 0.5*(unit.stat.hp - data.pdamage);
  
  -- can this unit reach the tile?
  grid.pathFindTargets.add( choke );
  grid.findPath();
  local path = grid.getPathForUnit( unit );
  if( path.length > unit.getMoveRange() ) then
    print( 'ZERO QUALITY!!!' );
    quality = 0;
    return quality;
  end
  
  -- how well does it actually hinder enemy movement?
  -- This is really important, but it's also very expensive because it requires marking alternative attack ranges.
  -- mark "what if" attack ranges for enemy units that can reach our nearbyAllies, in the case of our unit standing in the choke
  grid.markAttackForUnitsWI( action.attackers, unit, choke );
  local avgImp = 0;
  local avgNum0 = 0;
  local avgNumf = 0;
  local prioSum0 = 0;
  local prioSumf = 0;
  for i = 1, action.nearbyAllies.length() do
    local ally = action.nearbyAllies.get(i);
    avgImp = avgImp + ally.stat.rating / 10.0;
    local data0 = AIControl.computeDamage( ally, ally.tile.attackers );
    local dataf = AIControl.computeDamage( ally, ally.tile.attackersWI );
    avgNum0 = avgNum0 + data0.numAttacks;
    avgNumf = avgNumf + dataf.numAttacks;
    prioSum0 = prioSum0 + (data0.pdamage - ally.stat.hp*0.75)/5;
  end
  local dPrio = prioSumf - prioSum0;
  
  grid.clearAttackWI();
  
  quality = quality - dPrio;
  print( 'CHOKE QUALITY: '..tostring( quality )..', '..tostring( dPrio ) );
  return quality;
end

function attackCollab( unit )
  -- create a sorted list of full mesh attack data on enemy units
  -- create a new attack action, from scratch, for each ally unit in the list, and perform analyzeAttack() for each one
  --[[ We need to somehow analyze unit placement in order to determine the attack order for these units. The main problem
    is that analyzeAttack() finds a suitable place for each unit to stand, but assumes that the state of the grid is
    accurate. Without knowing the move order in advance, there is no way for this function to have an accurate picture
    to work with. I may have to create a slightly modified analyzeAttack() process which can consider special tile markings
    when choosing unit placement. These markings would indicate where any other prospective units have been proposed to
    stand so that the process can make necessary adjustments. The tile markings could be a table which carries a ref to the
    unit along with a proposed turn order index. If a secondary call to this analyze function finds that a prior move prevents
    the current one from happening, then it can swap the order as necessary.
  ]]
  local bestPriority = -100000000;
  local collabData = {};
  collabData.actions = createList();
  collabData.bestPriority = bestPriority;
  -- compile a list of enemy units which threaten the main unit; sort this list, descending by pdamage
  local enemies = createList();
  local untouchable = createList();
  for i = 1, unit.tile.attackers.length() do
    local attacker = unit.tile.attackers.get(i);
    local data = attacker.simulateAttack( unit );
    data.pdamage = data.damage * data.acc/100.0;
    attacker.atkData = data;
    enemies.sortAddDescend( attacker, data.pdamage );
  end
  
  -- compile a list of ally units which can attack these enemy units
  local allies = createList();
  for i = enemies.length(), 1, -1 do
    local enemy = enemies.get(i);
    local allyLen = enemy.tile.attackers2.length();
    -- remove the enemy from the list, if no one can attack it
    if( allyLen == 0 ) then
      untouchable.addUnique( enemy );
      enemies.remove(i);
      goto continue;
    end
    for j = 1, allyLen do
      local ally = enemy.tile.attackers2.get(j);
      allies.addUnique( ally );
    end
    ::continue::
  end
  
  -- check the untouchable list to see if we should just quit
  local totalPDamage = 0;
  for i = 1, untouchable.length() do
    local enemy = untouchable.get(i);
    totalPDamage = totalPDamage + enemy.atkData.damage * enemy.atkData.acc/100.0;
  end
  
  -- should we continue?
  if( totalPDamage < unit.stat.hp ) then
    return collabData;
  end
  
  local actions = createList();
  for i = 1, allies.length() do
    local ally = allies.get(i);
    for j = 1, enemies.length() do
      local enemy = enemies.get(j);
      -- generate attack action using ally's ai strategy
      local action = ally.ai.strategy.generateAttackOn( ally, enemy );
      
      -- analyze the attack
      AIControl.analyzeAttack( action );
      local data = action.attData;
      
      local kill = 0;
      if( data.kill ) then kill = 1; end
      local atkPriority = enemy.stat.hp*(1 + kill) - math.abs(data.damage - enemy.stat.hp);
      action.priority = action.priority + 2.0 * atkPriority;
      actions.sortAddDescend( action, action.priority );
    end
  end
  
  --[[ Choose the top actions in the list to be executed. Once an action is chosen, no other actions from the same unit, or
    for the same target, may be chosen. The above priority calculations are based on the efficiency of attack by a single
    ally on a single target. The selected actions should be marked as analyzed, and added to the priority queue for execution.
  ]]
  if( actions.length() == 0 ) then
    return collabData;
  end

  local chosen = createList();
  chosen.add( actions.get(1) );
  for i = 2, actions.length() do
    local action = actions.get(i);
    for j = 1, chosen.length() do
      local chaction = chosen.get(j);
      -- check for common unit and target
      if( action.unit == chaction.unit and action.target == chaction.target ) then
        -- skip this action, we can't use it
        goto continueOuter;
      end
    end
    chosen.add( action );
    -- remove added targets from enemies list so that we can add the remaining targets to the untouchable list
    enemies.remove( action.target );
    
    ::continueOuter::
  end
  untouchable.addList( enemies );
  enemies.clear();
  
  -- compare the number of chosen actions to the number of moves left in the turn, truncate if necessary
  local remMoves = GameState.activePlayer.remainingMoves;
  while chosen.length() > remMoves do
    local action = chosen.get( chosen.length() );
    untouchable.add( action.target );
    chosen.remove( chosen.length() );
  end
  
  -- compute an overall collaboration priority based on average action priority and number of actions in the list
  local avgPrio = 0;
  for i = 1, chosen.length() do
    local action = chosen.get(i);
    avgPrio = avgPrio + action.priority;
  end
  avgPrio = avgPrio / chosen.length();
  totalPDamage = 0;
  for i = 1, untouchable.length() do
    local enemy = untouchable.get(i);
    totalPDamage = totalPDamage + enemy.atkData.damage * enemy.atkData.acc/100.0;
  end
  local effectiveness = (oad.pdamage - totalPDamage)/unit.stat.maxHP * (unit.stat.hp - totalPDamage);
  bestPriority = (avgPrio + effectiveness)/chosen.length();
  collabData.actions = actions;
  collabData.bestPriority = bestPriority;
  return collabData;
end


-- utility
function AIControl.computeDamage( unit, attackers, primaryTarget )
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
    if( hunit ~= primaryTarget ) then
      local data = hunit.simulateAttack( unit );
      atkData.pdamage = atkData.pdamage + data.damage * data.acc/100.0;
      atkData.damage = atkData.damage + data.damage;
      atkData.hit = atkData.hit * data.acc/100.0;
      atkData.numAttacks = atkData.numAttacks + 1;
    end
  end
  
  return atkData;
end


function AIControl.computeDamageAtTile( unit, tile )
  local map = _G.currentMap;
  local grid = map.grid;
  local damage = 0;
  
  for i = 1, tile.attackers.length() do
    local hunit = tile.attackers.get(i);
    local data = hunit.simulateAttack( unit );
    damage = damage + data.damage * data.acc/100.0;
  end
  
  return damage;
end


-- other stuff
function AIControl.nextAction()
  local player = GameState.activePlayer;
  if( player.endTurn ) then
    Action_Queue.clear();
    GameState.endTurn();
    GameState.switchTeams();
    return;
  end
  
  AIControl.main();
  
  --[[
  Action_Queue.pop();
  action = Action_Queue.top();
  if( action ~= nil and player.remainingMoves > 0 ) then
    action.execute();
  else
    Action_Queue.clear();
    GameState.endTurn();
    GameState.switchTeams();
  end
  ]]
end

function AIControl.animationFinished()
  -- Take control after an animation has finished, and resume the
  -- appropriate actions. Status can be determined by data held
  -- within the current AI action.
  
  local action = Action_Queue.top();
  if( action ~= nil ) then
    action.execute();
  end
  
end

function AIControl.cameraFinished()
  local action = Action_Queue.top();
  if( action ~= nil ) then
    action.execute();
  end
end

function AIControl.displayFinished()
  local action = Action_Queue.top();
  if( action ~= nil ) then
    action.execute();
  end
end
