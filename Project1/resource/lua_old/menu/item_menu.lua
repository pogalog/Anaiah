-- item menu

function Item_Cancel()
  ItemMenu.cancel();
  setActiveMenu( ActionMenu );
  PF.setMenuCursorPosition( ActionMenu, 2 );
end

function Item_Confirm()
  local mi = ItemMenu.selectedItem;
  local item = mi.item;
  item.func( nil, item );
end

function Thing()
  print( 'Item exec function does not exist!' );
end



ItemMenu = createMenu( 'ItemMenu', 0.3, 0.5, 0.2, 0.2 );
PF.setMenuVisible( ItemMenu, false );

function ItemMenu.populateList( unit )
  PF.clearMenu( ItemMenu );
  ItemMenu.items = createList();
  for i = 1, unit.items.length() do
    local ii = unit.items.get(i);
    local txt = ii.name..' '..ii.quantity..'/'..ii.maxStack;
    local mi = createMenuItem( ItemMenu, txt, ii.name, 0.3, Item_Confirm );
    mi.item = ii;
  end
  if( unit.items.length() == 0 ) then
    createMenuItem( ItemMenu, "empty", "null", 0.3, Thing );
  end
  
end

function ItemMenu.init()
  local unit = ActionMenu.unit;
  ItemMenu.populateList( unit );
end


-- bind keys
local control = ItemMenu.control;
control.bindKey( 67, 'C', Item_Cancel );

