-- Text Message


function createMessage( message, font )
	local text = {};
	text.message = message;
	text.userdata = Text_new( GameInstance, font, message );
	
	
	function text.setText( message )
		text.message = message;
		Text_setText( text.userdata, message );
	end
	
	function text.setScale( scale )
		Text_setScale( text.userdata, scale );
	end
	
	function text.setPosition( position )
		Text_setPosition( text.userdata, position );
	end
	
	function text.setColor( color )
		Text_setColor( text.userdata, color );
	end
	
	function text.set2D()
		Text_set2D( text.userdata );
	end
	
	function text.set3D()
		Text_set3D( text.userdata );
	end
	
	function text.dispose()
		Text_dispose( GameInstance, text.userdata );
	end
	
	return text;
end


function createIntroMessage( message, font )
	local text = {};
	text.message = message;
	text.font = font;
	text.visible = true;
	text.userdata = IntroText_new( Intro, font, message );
	
	function text.setText( message )
		text.message = message;
		Text_setText( text.userdata, message );
	end
	
	function text.setScale( scale )
		Text_setScale( text.userdata, scale );
	end
	
	function text.setPosition( position )
		Text_setPosition( text.userdata, position );
	end
	
	function text.setVisible( visible )
		text.visible = visible;
		Text_setVisible( text.userdata, visible );
	end
	
	return text;
end