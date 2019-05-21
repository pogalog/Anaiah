-- Unit Inventory Menu
require( "ui.main" );
require( "input.main" );



function UI.itemSelected( menuItem )
	local unit = LevelMap.cursor.getSelectedUnit();
	local item = unit.getItemCalled( menuItem.message );
	if( item == nil ) then return; end
	unit.heldItem = item;
	UI.open( "ItemTargetSelect" );
end

function UI.createInventoryMenu( unit )
	local menu = UI.createGameMenu( Menu_new( GameInstance ), Fonts.courier, Input.createControlScheme( Controller ) );
	for i = 1, unit.items.length() do
		local item = unit.items.get(i);
		menu.addItem( item.name );
		menu.setAction( item.name, UI.itemSelected );
	end
	menu.build();
	menu.setSize( Vec2_new( 50, 50 ) );
	menu.setPosition( Vec2_new( 200, 600 ) );
	
	return menu;
end