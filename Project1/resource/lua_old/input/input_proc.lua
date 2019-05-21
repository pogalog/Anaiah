require( "input.binding" );
require( "game.control_regime" );
require( "game.ai.action" );
require( "game.ai.ai_logic_control" );

-- Input constants
DIRECTION_UP_RIGHT = 0;
DIRECTION_UP_LEFT = 1;
DIRECTION_LEFT = 2;
DIRECTION_DOWN_LEFT = 3;
DIRECTION_DOWN_RIGHT = 4;
DIRECTION_RIGHT = 5;
DIRECTION_UP = 6;
DIRECTION_DOWN = 7;

MODE_NORMAL = 0;
MODE_MOVE = 1;
MODE_TARGET = 2;

Mode = MODE_NORMAL;


DefaultControl = createControlRegime();
PrimaryControl = DefaultControl;

-- used when the remote player animation finishes
function DefaultControl.animationFinished()
  PF.clearMovePath();
  Mode = MODE_NORMAL;
end


AnimationControl = createControlRegime();
function AnimationControl.activate()
  PrimaryControl = AnimationControl;
end

-- used for when a local player animation is finished
function AnimationControl.animationFinished()
  -- display menu
  ActionMenu.unit = GameState.activePlayer.activeUnit;
  setActiveMenu( ActionMenu );
  updateUnitDisplay();
end


-- game board
function DefaultControl.activate()
  PrimaryControl = DefaultControl;
end

function DefaultControl.direction( key, ... )
  local args = {...};
  local map = _G.currentMap;
  local dir = args[1];
  PF.moveCursor( dir );
  if( Mode == MODE_NORMAL ) then
    if( map.selectedUnit == nil ) then
      PF.markMovementRange();
    end
  end
    
  -- display texts
  updateTileDisplay();
  updateUnitDisplay();
end

-- game board
function DefaultControl.confirm()
  if( Mode == MODE_NORMAL ) then
    -- NORMAL MODE
    confirmNormal();
  elseif( Mode == MODE_MOVE ) then
    -- MOVE MODE
    confirmMove();
  elseif( Mode == MODE_TARGET ) then
    -- TARGET MODE
    confirmTarget();
  end
end



function confirmNormal()
  if( GameState.activePlayer ~= Player ) then return; end
  
  local map = _G.currentMap;
  -- try to select a unit
  local unit = map.getUnitOnCursor();
  if( unit == nil ) then return; end
  if( unit.team ~= Player.team ) then return; end
  if( unit.available() == false ) then return; end
  Player.activeUnit = unit;
  selectUnit( unit );
  PF.setMovePathVisible( true );
  PF.clearRanges();
  PF.markRanges();
  if( map.selectedUnit ~= nil ) then
    Mode = MODE_MOVE;
  end
end

function confirmMove()
  local map = _G.currentMap;
  local unit = map.selectedUnit;
  if( PF.isMoveValid() ) then
    -- move the unit
    AnimationControl.activate();
    --PrimaryControl = AnimationControl;
    PF.startMovingUnit();
    PF.moveUnitTemp( unit, map.cursor );
    PF.setMovePathVisible( false );
    GameState.addAP( PF.getMovePathLength() );
    
    -- send position
    local data = {};
    data.id = NET_UNIT_PATH;
    PF.sendData( data );
  end
end

function confirmTarget()
  local map = _G.currentMap;
  local unit = ActionMenu.unit;
  local target = map.getUnitOnCursor();
  if( target == nil ) then return; end
  local valid = PF.tileWithinAttackRange( target.tile );
  if( valid ) then
    if( unit.team ~= target.team ) then
      local data = encounter( unit, target, ENCOUNTER_ATTACK );
      
      -- reset
      map.selectedUnit = nil;
      PF.clearMovePath();
      setActiveMenu( nil );
      ActionMenu.reset();
      PF.clearRanges();
      PF.markMovementRange();
      
      updateUnitDisplay();
      
      PF.setRangesVisible( true );
      PF.setAttackRangeVisible( false );
      PF.setMovePathVisible( true );
      
      -- display damage
      displayDamage( data );
      
      -- confirm
      PF.confirmUnit();
      PF.syncActionPoints( Player.activeUnit );
      
      -- send attack
      data.id = NET_ATTACK;
      data.attackerID = data.attacker.id;
      data.targetID = data.target.id;
      PF.sendData( data );
      
      -- send confirm for move
      local data0 = {};
      data0.id = NET_CONFIRM_ACTION;
      data0.unitID = ActionMenu.unit.id;
      data0.totalAP = GameState.currentAP + data.totalTime;
      PF.sendData( data0 );
      
      GameState.addAP( data.totalTime );
      GameState.executeAction( false );
      
      Player.activeUnit = nil;
      Mode = MODE_NORMAL;
    end
  end
end


-- menu
function menuConfirm()
  ActiveMenu.confirm();
end

-- game board
function DefaultControl.cancel( unit )
  local map = _G.currentMap;
  if( Mode == MODE_MOVE ) then
    cancelMove();
  elseif( Mode == MODE_TARGET ) then
    cancelTarget();
  end
end

function cancelMove()
  local map = _G.currentMap;
  if( PF.getMovePathLength() > 0 ) then
    PF.returnCursor();
  end
  
  map.selectedUnit = nil;
  PF.selectJUnit( nil );
  PF.clearMovePath();
  Mode = MODE_NORMAL;
end

function cancelTarget()
  local map = _G.currentMap;
  -- cancel target, go back to move
  Mode = MODE_MOVE;
  PF.setAttackRangeVisible( false );
  PF.setRangesVisible( true );
  setActiveMenu( ActionMenu );
end

-- menu
function menuCancel()
  ActiveMenu.cancel();
end

function findUnit()
  if( Mode ~= MODE_NORMAL ) then return; end
  local map = _G.currentMap;
  local team = Player.team;
  local unit = nil;
  local cu = map.getUnitOnCursor();
  local index = 1;
  if( cu ~= nil ) then
    local ind = team.units.getIndex( cu );
    if( ind == nil ) then
      index = 1;
    else
      index = ind+1;
    end
  else
    index = 1;
  end
  unit = team.nextUnit( index );
  if( unit ~= nil ) then
    PF.highlightUnit( unit );
    PF.clearRanges();
    PF.markMovementRange();
    updateUnitDisplay();
    updateTileDisplay();
  end
end



  -- create key bindings
DefaultControl.bindKey( 32, 'Space', DefaultControl.confirm );
DefaultControl.bindKey( 87, 'W', DefaultControl.direction, DIRECTION_UP_LEFT );
DefaultControl.bindKey( 65, 'A', DefaultControl.direction, DIRECTION_LEFT );
DefaultControl.bindKey( 83, 'S', DefaultControl.direction, DIRECTION_DOWN_RIGHT );
DefaultControl.bindKey( 68, 'D', DefaultControl.direction, DIRECTION_RIGHT );
DefaultControl.bindKey( 69, 'E', DefaultControl.direction, DIRECTION_UP_RIGHT );
DefaultControl.bindKey( 90, 'Z', DefaultControl.direction, DIRECTION_DOWN_LEFT );
DefaultControl.bindKey( 67, 'C', DefaultControl.cancel );
DefaultControl.bindKey( 81, 'Q', findUnit );
