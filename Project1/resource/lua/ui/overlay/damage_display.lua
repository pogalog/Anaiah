-- UI Damage Display
require( "ui.overlay.main" );
require( "ui.text.message" );

Overlay.damageDisplays = createList();

function Overlay.createDamageDisplay( unit, damageValue, duplicate )
	local display = {};
	if( duplicate ~= true and unit.doesCoexist() ) then
		display.coexist = Overlay.createDamageDisplay( unit, damageValue, true );
	end
	display.duration = 0.75;
	
	function display.setUnit( unit )
		display.unit = unit;
		display.setPosition( duplicate == true and unit.tile.coexist.position or unit.tile.position );
	end
	
	function display.setPosition( position )
		local copy = Vec3_copy( position );
		copy.y = copy.y + 2;
		display.text.setPosition( copy );
	end
	
	function display.setScale( scale )
		display.scale = scale;
		display.text.setScale( scale );
	end
	
	function display.setColor( color )
		display.color = color;
		display.text.setColor( color );
	end
	
	function display.update( dt )
		display.duration = display.duration - Global_dt;
		if( display.duration < 0 ) then
			display.dispose();
			return;
		end
		
		-- move up and fade
		local p = display.position;
		p.y = p.y + 0.015;
		display.text.setPosition( p );
	end
	
	function display.dispose()
		RenderUnits.key( "ui" ).removeUIMessage( display.text );
		Overlay.damageDisplays.remove( display );
		display.text.dispose();
		display = nil;
	end
	
	
	
	-- setup
	display.scale = Vec3_new( 0.75, 0.75, 1 );
	display.position = Vec3_add( duplicate and unit.tile.coexist.position or unit.tile.position, Vec3_new( 0, 2, 0 ) );
	
	local stringy = nil;
	local color = nil;
	
	if( type( damageValue ) == "number" ) then
		stringy = tostring( math.abs( damageValue ) );
		color = damageValue > 0 and Color_new( 0, 1, 0, 1 ) or damageValue < 0 and Color_new( 1, 0, 0, 1 ) or Color_new( 1, 1, 1, 1 );
	else
		stringy = damageValue;
		color = Color_new( 1, 1, 1, 1 );
	end
	display.text = UI.createMessage( stringy, Fonts.courier );
	display.setScale( display.scale );
	display.setColor( color );
	display.setUnit( unit );
	display.text.set3D();
	Overlay.damageDisplays.add( display );
	RenderUnits.key( "ui" ).addUIMessage( display.text );
	
	return display;
end


function Overlay.updateDamageDisplays()
	for i = 1, Overlay.damageDisplays.length() do
		local disp = Overlay.damageDisplays.get(i);
		if( disp == nil ) then goto cont; end
		disp.update( Global_dt );
		::cont::
	end
end