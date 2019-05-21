-- agressive attacker strategy

Aggressive = {};

function aggressiveAttack( unit )
  local actions = createList();
  
  -- move to a random location (meander)
  local aggAction = createAction();
  aggAction.unit = unit;
  aggAction.actionType = ACTION_MOVE;
  aggAction.priority = 1000;
  local initItem = createActionItem( Aggressive.init );
  local scanItem = createActionItem( Aggressive.scan );
  local camItem = createActionItem( Aggressive.camera );
  local moveItem = createActionItem( Aggressive.move );
  local attackItem = createActionItem( Aggressive.attack );
  local finishItem = createActionItem( Aggressive.finish );
  aggAction.addItem( initItem );
  aggAction.addItem( scanItem );
  aggAction.addItem( camItem );
  aggAction.addItem( moveItem );
  aggAction.addItem( camItem );
  aggAction.addItem( attackItem );
  aggAction.addItem( finishItem );
  
  actions.add( aggAction );
  return actions;
end

-- init functions can be used to prepare data to be used in later steps
function Aggressive.init( action )
  GameState.activePlayer.activeUnit = action.unit;
  action.fail = false;
  action.camTarget = action.unit.tile;
  action.execute();
end

-- scan for targets
function Aggressive.scan( action )
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  local moveRange = grid.getTilesWithinRange( unit, unit.getMoveRange(), false );
  if( moveRange.length() <= 1 ) then
    action.fail = true;
    action.execute();
    return;
  end
  
  local atkRange = grid.getAttackRange( unit, moveRange );
  
  -- scan tiles for a unit to attack
  local targetUnit = nil;
  for i = 1, atkRange.length() do
    local tile = atkRange.get(i);
    local target = tile.occupant;
    if( target ~= nil and target.team ~= unit.team ) then
      targetUnit = target;
      break;
    end
  end
  
  if( targetUnit == nil ) then
    grid.clearMarkings();
    action.fail = true;
    action.execute();
    return;
  end
  action.targetData = targetUnit;
  action.secondTarget = targetUnit.tile;
  
  -- scan tiles surrounding target for a place to stand
  local range = grid.getTilesWithinRange2( action.targetData, 1, false );
  local dest = nil;
  for i = 1, range.length() do
    local tile = range.get(i);
    if( tile.open ) then
      dest = tile;
      break;
    end
  end
  grid.clearMarkings();
  
  if( dest == nil ) then
    action.fail = true;
    action.execute();
    return;
  end
  
  action.destination = dest;
  action.execute();
end


-- move camera to selected unit
-- terminated by Java callback to 'cameraFinished'
function Aggressive.camera( action )
  if( action.fail ) then action.execute(); return; end
  if( action.camTarget ~= nil ) then
    PF.moveCursorToTile( action.camTarget );
    local data = {};
    data.id = NET_MOVE_CURSOR;
    data.location = action.camTarget.address;
    PF.sendData( data );
  else
    action.execute();
  end
end

-- moves unit to a new location
-- terminated by Java callback to 'AIControl.animationFinished'
function Aggressive.move( action )
  if( action.fail ) then action.execute(); return; end
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  
  -- path find to this tile
  grid.clearMarkings();
  grid.addPathFindingTarget( action.destination );
  grid.findPath( unit );
  local addy = unit.tile.address;
  local path = grid.getPathForUnit( unit );
  grid.clearPathFinding();
  if( path.length == 0 ) then
    action.fail = true;
    action.execute();
    return;
  end
  
  action.camTarget = action.secondTarget;
  
  moveUnitRemote( action.unit, path.vpath );
  local data = {};
  data.id = NET_UNIT_PATH;
  PF.sendData( data );
  
  GameState.addAP( path.length );
end


function Aggressive.attack( action )
  if( action.fail ) then action.execute(); return; end
  if( action.targetData == nil ) then
    action.fail = true;
    action.execute();
    return;
  end
  
  local map = _G.currentMap;
  local grid = map.grid;
  local unit = action.unit;
  local targetUnit = action.targetData;
  
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
  --action.execute();
end

function Aggressive.finish( action )
  GameState.executeAction( false );
  nextAction();
end

