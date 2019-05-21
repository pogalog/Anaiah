-- items 1

--[[ Description
Item functions are used in order to allow the player to execute
the use of an inventory item. Typically, this will involve selecting
a target for the item that has been selected from the item menu.
Once this is done, input handling is delegated to functions defined
here to facilitate the process of finishing the use of the item. Once
the task is finished, the function will return control of input processing
back to the main input processing script.

Note: This entire method needs to be more organized and modular so that
adding functions to accommodate new items is trivial.
]]

-- create a control regime for the default selection mode
ItemSelectionControl = createControlRegime();

local SelectedItem = nil;

function ItemSelectionControl.confirm()
  local map = _G.currentMap;
  local target = map.getUnitOnCursor();
  if( target == nil ) then return; end
  local valid = PF.tileWithinItemRange( target.tile );
  SelectedItem.func( target, SelectedItem );
end

function ItemSelectionControl.cancel()
  PF.setItemRangeVisible( false );
  PF.setRangesVisible( true );
  setActiveMenu( ItemMenu );
end

function ItemSelectionControl.direction( key, ... )
  local args = {...};
  local map = _G.currentMap;
  local dir = args[1];
  PF.moveCursor( dir );
    
  -- display texts
  updateTileDisplay();
  updateUnitDisplay();
end

-- bind keys
ItemSelectionControl.bindKey( 32, 'Space', ItemSelectionControl.confirm );
ItemSelectionControl.bindKey( 67, 'C', ItemSelectionControl.cancel );
ItemSelectionControl.bindKey( 87, 'W', ItemSelectionControl.direction, DIRECTION_UP_LEFT );
ItemSelectionControl.bindKey( 65, 'A', ItemSelectionControl.direction, DIRECTION_LEFT );
ItemSelectionControl.bindKey( 83, 'S', ItemSelectionControl.direction, DIRECTION_DOWN_RIGHT );
ItemSelectionControl.bindKey( 68, 'D', ItemSelectionControl.direction, DIRECTION_RIGHT );
ItemSelectionControl.bindKey( 69, 'E', ItemSelectionControl.direction, DIRECTION_UP_RIGHT );
ItemSelectionControl.bindKey( 90, 'Z', ItemSelectionControl.direction, DIRECTION_DOWN_LEFT );


--[[ The default item execution method. Only considers
the target of the item, and calls the item's specified
execution function.
]]
function ItemDefaultSelection( item )
  SelectedItem = item;
  PrimaryControl = ItemSelectionControl;
  PF.setMenuVisible( ItemMenu, false );
  local map = _G.currentMap;
  local unit = GameState.activePlayer.activeUnit;
  -- mark item range, put the player in item target selection mode
  PF.setRangesVisible( false );
  -- compute and show singleton attack range
  PF.markItemRange( unit.userdata );
  PF.setItemRangeVisible( true );
  -- set mode to 'target select'
  Mode = MODE_TARGET;
end

function reset()
  -- reset
  local map = _G.currentMap;
  map.selectedUnit = nil;
  PF.clearMovePath();
  setActiveMenu( nil );
  ActionMenu.reset();
  ItemMenu.reset();
  PF.clearRanges();
  PF.markMovementRange();
  
  updateUnitDisplay();
  
  PF.setRangesVisible( true );
  PF.setItemRangeVisible( false );
  PF.setMovePathVisible( true );
  PF.confirmUnit();
  
  SelectedItem = nil;
  Mode = MODE_NORMAL;
  PrimaryControl = DefaultControl;
end

function ItemPotion( target, item, remote )
  if( target == nil ) then
    ItemDefaultSelection( item );
    return;
  end
  
  local unit = GameState.activePlayer.activeUnit;
  -- expend item
  unit.useItem( item.id );
  
  -- give some HP to the target
  target.gainHP( 10 );
  -- execute action in game state
  GameState.addAP( 2.0 );
  GameState.executeAction( false );
  
  -- display healing amount over unit
  local dat = {};
  dat.healAmount = 10;
  dat.unit = unit;
  dat.target = target;
  displayHealing( dat );
  
  if( remote ) then return;
  end
  
  -- send over network
  local data = {};
  data.id = NET_USE_ITEM;
  data.itemID = item.id;
  data.targetID = target.id;
  data.unitID = unit.id;
  PF.sendData( data );
  
  reset();
end
