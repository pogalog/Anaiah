-- in-game menus

-- constructor
function createMenu( name, x, y, w, h )
  local menu = {};
  menu.name = name;
  menu.visible = false;
  menu.userdata = PF.createIGMenu( x, y, w, h );
  menu.cursor = 1;
  menu.items = createList();
  menu.selectedItem = nil;
  menu.control = createControlRegime();
  menu.overrideControl = nil;
  
  function menu.cursorDown()
    local num = menu.items.length();
    menu.cursor = menu.cursor + 1;
    if( menu.cursor > num ) then
      menu.cursor = 1;
    end
    menu.selectedItem = menu.items.get( menu.cursor );
    PF.menuCursorDown( menu );
    return menu.selectedItem;
  end
  
  function menu.cursorUp()
    local num = menu.items.length();
    menu.cursor = menu.cursor - 1;
    if( menu.cursor <= 0 ) then
      menu.cursor = num;
    end
    menu.selectedItem = menu.items.get( menu.cursor );
    PF.menuCursorUp( menu );
    return menu.selectedItem;
  end
  
  function menu.cursorLeft()
  end
  
  function menu.cursorRight()
  end
  
  function menu.init()
  end
  
  function menu.confirm()
    menu.selectedItem.confirm();
  end
  
  function menu.cancel()
    setActiveMenu( nil );
    menu.reset();
  end
  
  function menu.reset()
    menu.cursor = 1;
    menu.selectedItem = menu.items.get(1);
  end
  
  
  -- default key bindings
  menu.control.bindKey( 87, 'W', menu.cursorUp );
  menu.control.bindKey( 83, 'S', menu.cursorDown );
  menu.control.bindKey( 65, 'A', menu.cursorLeft );
  menu.control.bindKey( 68, 'D', menu.cursorRight );
  menu.control.bindKey( 32, 'Space', menuConfirm );
  menu.control.bindKey( 67, 'C', menuCancel );
  
  function menu.control.keyPress( key, ... )
    local kbind = menu.control.keys[key];
    if( kbind == nil ) then return; end
    local kfunc = kbind.func;
    kfunc( kbind.val, ... );
  end
  
  return menu;
end

function createMenuItem( parent, name, handle, size, func )
  local item = {};
  item.name = name;
  item.handle = handle;
  item.size = size;
  item.parent = parent;
  parent.items.add( item );
  item.func = func;
  
  parent.reset();
  
  item.userdata = PF.addMenuItem( parent.userdata, name, handle, size );
  
  function item.confirm()
    item.func();
  end
  
  return item;
end


ActiveMenu = nil;

-- initialize
function initializeMenus()
  local context = _G.gameContext;
  require( "menu.action_menu" );
  require( "menu.item_menu" );
end

-- update
function setActiveMenu( menu )
  -- set current menu invisible
  if( ActiveMenu ~= nil ) then
    PF.setMenuVisible( ActiveMenu, false );
  end
  
  -- return focus to main
  if( menu == nil ) then
    DefaultControl.activate();
    return;
  end
  
  -- focus on menu
  PrimaryControl = menu.control;
  ActiveMenu = menu;
  menu.init();
  PF.setMenuVisible( menu, true );
end
