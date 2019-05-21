-- Text Field
require( "input.main" );
require( "ui.main" );



function UI.createField( message, font )
	local field = {};
	field.message = message;
	field.userdata = Text_new( GameInstance, font.userdata, message );
	
	
	function text.setText( message )
		field.message = message;
		Text_setText( field.userdata, message );
	end
	
	function field.setScale( scale )
		Text_setScale( field.userdata, scale );
	end
	
	function field.setPosition( position )
		Text_setPosition( field.userdata, position );
	end
	
	return text;
end


function UI.createIntroField( message, font )
	local field = {};
	field.message = message;
	field.font = font;
	field.visible = true;
	field.userdata = IntroText_new( Intro, font.userdata, message );
	field.textControl = Input.createKeyboardListener( Keyboard );
	field.action = function() end
	
	
	function field.grabFocus()
		field.textControl.grabFocus();
	end
	
	field.textControl.keyPressed = function( key )
		if( string.byte( key ) == 8 ) then
			field.message = string.sub( field.message, 1, string.len( field.message )-1 );
			field.setText( field.message );
			return;
		end
		if( string.byte( key ) == 13 ) then
			field.action();
			return;
		end
		field.type( key );
	end
	
	function field.type( c )
		field.setText( field.message .. c );
	end
	
	function field.setText( message )
		field.message = message;
		Text_setText( field.userdata, message );
	end
	
	function field.setScale( scale )
		Text_setScale( field.userdata, scale );
	end
	
	function field.setPosition( position )
		Text_setPosition( field.userdata, position );
	end
	
	function field.setVisible( visible )
		field.visible = visible;
		Text_setVisible( field.userdata, visible );
	end
	
	return field;
end