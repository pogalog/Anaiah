-- Unit Inventory Menu

function itemSelected( menuItem )
	local unit = LevelMap.cursor.getSelectedUnit();
	local item = unit.getItemCalled( menuItem.message );
	if( item == nil ) then return; end
	unit.heldItem = item;
	UIReg.open( "ItemTargetSelect" );
end

function createInventoryMenu( unit )
	local menu = createGameMenu( Menu_new( GameInstance ), Fonts.courier, createControlScheme( Controller ) );
	for i = 1, unit.items.length() do
		local item = unit.items.get(i);
		menu.addItem( item.name );
		menu.setAction( item.name, itemSelected );
	end
	menu.build();
	menu.setSize( createVec2( 50, 50 ) );
	menu.setPosition( createVec2( 200, 600 ) );
	
	return menu;
end