-- UI Damage Display
require( "ui.overlay.main" );
require( "ui.text.message" );

Overlay.damageDisplays = createList();

function Overlay.createDamageDisplay( unit, damageValue )
	local display = {};
	display.duration = 0.75;
	
	function display.setUnit( unit )
		display.unit = unit;
		display.setPosition( unit.tile.position );
	end
	
	function display.setPosition( position )
		local copy = position.copy();
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
		Overlay.damageDisplays.remove( display );
		display.text.dispose();
		display = nil;
	end
	
	
	
	-- setup
	display.scale = createVec3( 0.75, 0.75, 1 );
	display.position = unit.tile.position.add( createVec3( 0, 2, 0 ) );
	
	local stringy = nil;
	local color = nil;
	
	if( type( damageValue ) == "number" ) then
		stringy = tostring( math.abs( damageValue ) );
		color = damageValue > 0 and createColor( 0, 1, 0, 1 ) or damageValue < 0 and createColor( 1, 0, 0, 1 ) or createColor( 1, 1, 1, 1 );
	else
		stringy = damageValue;
		color = createColor( 1, 1, 1, 1 );
	end
	display.text = createMessage( stringy, Fonts.courier );
	display.setScale( display.scale );
	display.setColor( color );
	display.setUnit( unit );
	display.text.set3D();
	Overlay.damageDisplays.add( display );
	
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