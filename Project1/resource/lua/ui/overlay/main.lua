-- Overlay Main

Overlay = {};
Overlay.unit = nil;

function Overlay.updateUnitOverlay()
	local cursor = LevelMap.cursor;
	if( cursor.getHighlightedUnit() == nil ) then return; end
	
	Overlay.disposeUnitOverlay();
	Overlay.displayUnitOverlay( cursor.getHighlightedUnit() );
end

function Overlay.displayUnitOverlay( unit )
	local uo = ui.createUnitOverlay( Fonts.courier );
	uo.addMessage( unit.name );
	
	-- only show information for team units
	if( Player.team.containsUnit( unit ) ) then
		local hpMsg = uo.addMessage( "HP: " .. unit.stat.hp .. "/" .. unit.stat.maxHP );
		local hpColor = unit.hasLowHP() and Color_new( 0.8, 0.3, 0.3, 1 ) or unit.hasFullHP() and Color_new( 0.3, 0.8, 0.3, 3 ) or Color_new( 1, 1, 1, 1 );
		hpMsg.setColor( hpColor );
		local apHigh = unit.stat.ap > unit.stat.minAP and unit.stat.maxAP or unit.stat.minAP;
		local apColor = unit.stat.ap > unit.stat.minAP and Color_new( 1, 1, 1, 1 ) or Color_new( 0.8, 0.3, 0.3, 1 );
		local apMsg = uo.addMessage( "AP: " .. unit.stat.ap .. "/" .. apHigh );
		apMsg.setColor( apColor );
	end
	
	uo.build();
	uo.setSize( Vec2_new( 50, 50 ) );
	uo.setPosition( Vec2_new( 500, 800 ) );
	uo.setVisible( true );
	
	Overlay.unit = uo;
end

function Overlay.disposeUnitOverlay()
	if( Overlay.unit == nil ) then return; end
	RenderUnits.key( "ui" ).removeUIOverlay( Overlay.unit );
	Overlay_dispose( GameInstance, Overlay.unit.userdata );
	Overlay.unit = nil;
end