-- meandering strategy

function meanderAttack( unit )
  local actions = createList();
  
  -- move to a random location (meander)
  local meanderAction = createAction();
  meanderAction.unit = unit;
  meanderAction.actionType = ACTION_MOVE;
  meanderAction.priority = unit.stat.ap;
  local moveItem = createActionItem( moveRandom );
  local attackItem = createActionItem( attackAdjacent );
  local finishItem = createActionItem( finishAction );
  meanderAction.addItem( moveItem );
  meanderAction.addItem( attackItem );
  meanderAction.addItem( finishItem );
    
  actions.add( meanderAction );
  return actions;
end

function moveRandom( action )
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  local range = grid.getTilesWithinRange( unit, unit.stat.mv, false );
  if( range.length() <= 1 ) then
    action.execute();
    return;
  end
  -- choose a random tile to move to (don't choose the first one)
  local rand = 1 + math.ceil( math.random() * (range.length()-1) );
  local dest = range.get( rand );
  -- path find to this tile
  grid.clearMarkings();
  grid.addPathFindingTarget( dest );
  grid.findPath( unit );
  local addy = unit.tile.address;
  local path = grid.getPathForUnit( unit );
  grid.clearPathFinding();
  if( path.length == 0 ) then
    action.execute();
    return;
  end
  
  moveUnitRemote( action.unit, path.vpath );
  local data = {};
  data.id = NET_UNIT_PATH;
  PF.sendData( data );
  
  GameState.addAP( path.length );
  GameState.activePlayer.activeUnit = action.unit;
end

function attackAdjacent( action )
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  local range = grid.getTilesWithinRange( unit, unit.equipped.range.high, true );
  -- scan to see if there's a unit within attack range
  local targetUnit = nil;
  for i = 2, range.length() do
    local tile = range.get(i);
    if( tile ~= nil ) then
      if( tile.occupant ~= nil and unit.team ~= tile.occupant.team ) then
        targetUnit = tile.occupant;
        break;
      end
    end
  end
  grid.clearMarkings();
  
  if( targetUnit == nil ) then
    action.execute();
    return;
  end
  
  local data = encounter( unit, targetUnit, ENCOUNTER_ATTACK );
  -- display damage
  displayDamage( data );
  
  -- confirm
  PF.syncActionPoints( unit );
  
  -- send attack
  data.id = NET_ATTACK;
  data.attackerID = data.attacker.id;
  data.targetID = data.target.id;
  PF.sendData( data );
  
  -- send confirm for move
  local data0 = {};
  data0.id = NET_CONFIRM_ACTION;
  data0.unitID = unit.id;
  data0.totalAP = GameState.currentAP + data.totalTime;
  PF.sendData( data0 );
  
  GameState.addAP( data.totalTime );
  
  -- next item
  action.execute();
end

function finishAction( action )
  GameState.executeAction( false );
  nextAction();
end

