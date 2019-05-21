-- Unit Information Overlay
require( "game.list" );

if( ui == nil ) then
	_G.ui = {};
end

function ui.createUnitOverlay( font )
	local overlay = {};
	overlay.font = font;
	overlay.messages = createList();
	overlay.userdata = Overlay_new( GameInstance );
	overlay.size = createVec2( 0, 0 );
	overlay.position = createVec2( 0, 0 );
	overlay.shader = Shaders.solidShader;
	overlay.messageShader = Shaders.textShader;
	
	-- set defaults
	Overlay_setFont( overlay.userdata, font );
	Overlay_setShader( overlay.userdata, overlay.shader );
	Overlay_setItemShader( overlay.userdata, overlay.messageShader );
	
	
	function overlay.addMessage( text )
		local message = {};
		message.text = text;
	
		function message.create()
			message.userdata = Overlay_addItem( overlay.userdata, text );
			overlay.messages.add( message );
		end
		
		function message.setVisible( visible )
			message.visible = visible;
			Overlay_setItemVisible( overlay.userdata, message.userdata, visible );
		end
		
		function message.setColor( color )
			Overlay_setItemColor( message.userdata, color );
		end
		
		message.create();
		message.setVisible( true );
		return message;
	end
	
	function overlay.setShader( shader )
		Overlay_setShader( overlay.userdata, shader );
	end
	
	function overlay.setItemShader( shader )
		Overlay_setItemShader( overlay.userdata, shader );
	end
	
	function overlay.build()
		Overlay_build( overlay.userdata );
	end
	
	function overlay.setSize( size )
		overlay.size = size;
		Overlay_setSize( overlay.userdata, size );
	end
	
	function overlay.setPosition( position )
		overlay.position = position;
		Overlay_setPosition( overlay.userdata, position );
	end
	
	-- sets visibility for all messages
	function overlay.setMessagesVisible( visible )
		for key,item in pairs( overlay.messages ) do
			item.setVisible( visible );
		end
	end
	
	function overlay.setVisible( visible )
		overlay.visible = visible;
		Overlay_setVisible( overlay.userdata, visible );
	end
	
	return overlay;
end