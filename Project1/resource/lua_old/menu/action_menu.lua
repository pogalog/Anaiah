-- ActionMenu

-- ActionMenu functions
function Action_Cancel()
  -- send
  local data = {};
  local unit = ActionMenu.unit;
  data.id = NET_CANCEL_MOVE;
  data.location = unit.prevLocation;
  data.unitID = unit.id;
  data.ap = PF.getMovePathLength();
  data.orientation = unit.prevOrientation;
  PF.sendData( data );
  
  -- move unit to previous location
  local map = _G.currentMap;
  PF.returnUnit( ActionMenu.unit );
  PF.setMovePathVisible( true );
  ActionMenu.cancel();
  
  GameState.subAP( data.ap );
end

function Action_Attack()
  -- close the menu
  ActionMenu.cancel();
  -- hide movement range
  PF.setRangesVisible( false );
  -- compute and show singleton attack range
  PF.markAttackRange( ActionMenu.unit.userdata );
  PF.setAttackRangeVisible( true );
  -- set mode to 'target select'
  Mode = MODE_TARGET;
  PF.setMovePathVisible( false );
end

function Action_Item()
  -- display Items menu
  setActiveMenu( ItemMenu );
end

function Action_Wait()
  local map = _G.currentMap;
  
  -- send
  local data = {};
  data.id = NET_CONFIRM_ACTION;
  data.unitID = ActionMenu.unit.id;
  data.totalAP = GameState.currentAP;
  PF.sendData( data );
  
  -- reset
  map.selectedUnit = nil;
  PF.clearMovePath();
  setActiveMenu( nil );
  ActionMenu.reset();
  PF.clearRanges();
  PF.markRanges();
  Mode = MODE_NORMAL;
  
  -- confirm
  PF.confirmUnit();
  GameState.executeAction( false );
  PF.syncActionPoints( Player.activeUnit );
  Player.activeUnit = nil;
  
  updateUnitDisplay();
end

-- create menu
ActionMenu = createMenu( 'ActionMenu', 0.5, 0.5, 0.1, 0.2 );
local atk = createMenuItem( ActionMenu, "Attack", "atk", 0.3, Action_Attack );
local item = createMenuItem( ActionMenu, "Item", "item", 0.3, Action_Item );
local wait = createMenuItem( ActionMenu, "Wait", "wait", 0.3, Action_Wait );
PF.setMenuVisible( ActionMenu, false );

-- key bindings
local control = ActionMenu.control;

control.bindKey( 67, 'C', Action_Cancel );
