-- Main Menu
require( "game.vector" );
require( "ui.text.message" );
require( "ui.text.field" );
require( "network.net_proc" );

function initIntro( width, height )
	_G.Intro = Intro_new( width, height );
	Intro_setClearColor( Intro, createVec4( 0.3, 0.3, 0.3, 1.0 ) );
	initMenus();
end

function initMenus()
	loadShaders();
	loadFonts();
	createMainMenu();
end


function parseDeclaration( dec )
	local _type = "";
	local _name = "";
	
	local tokens = {};
	
	for token in string.gmatch( dec, "%S+" ) do
		table.insert( tokens, token );
	end
	_type = tokens[1];
	_name = tokens[2];
	
	return _type, _name;
end


function createUniform( uniType, uniName )
	local uniform = {};
	uniform.name = uniName;
	uniform.type = uniType;
	
	return uniform;
end


function findUniformVars( source )
	local vars = {};
	
	local start = 1;
	local a = 1;
	local b = 1;
	while( true ) do
		a, b = string.find( source, "uniform", start );
		if( a == nil ) then break; end
		
		local sa, sb = string.find( source, ";", b );
		local line = string.sub( source, b+1, sa-1 );
		local uniType, uniName = parseDeclaration( line );
		table.insert( vars, createUniform( uniType, uniName ) );
		
		start = sb+1;
	end
	
	return vars;
end


function loadShader( vertPath, fragPath )
	local shaderPath = "resource/shader/";
	
	-- vert shader
	local file = io.open( shaderPath..vertPath, "r" );
	io.input( file );
	local vertSource = io.read( "*all" );
	io.close( file );
	findUniformVars( vertSource );
	
	-- frag shader
	local file = io.open( shaderPath..fragPath, "r" );
	io.input( file );
	local fragSource = io.read( "*all" );
	io.close( file );
	local uniforms = findUniformVars( fragSource );
	
	local shader = {};
	shader.userdata = Shader_new( shaderPath..vertPath, shaderPath..fragPath );
	shader.vertexPath = vertPath;
	shader.fragmentPath = fragPath;
	shader.vertexSource = vertSource;
	shader.fragmentSource = fragSource;
	shader.uniforms = uniforms;
	
	return shader.userdata;
end


function loadShaders()
	Shaders = {};
	Shaders.wireShader = loadShader( "wire.vsh", "wire.fsh" );
	Shaders.solidShader = loadShader( "solid.vsh", "solid.fsh" );
	Shaders.textShader = loadShader( "text.vsh", "text.fsh" );
end


function loadFonts()
	Fonts = {};
	Fonts.courier = Font_load( GameInstance, "Courier New", Shaders.textShader );
end

function createMainMenu()
	local menu = createGameMenu( IntroMenu_new( Intro ), Fonts.courier, createControlScheme( Controller ) );
	UIReg.registerUI( createUI( "MainMenu", menu.control, menu ), true );
	
	function menu.callback_Single()
		if( Network == nil ) then
			_G.Network = net.createNetwork( nil );
		end
		Lua_feedGameInstance( GameState, GameInstance, Network.userdata );
		Lua_callFunction( GameState, "initScene" );
		Intro_controlSleep();
		Render_changeMode( 1 );
	end
	
	function menu.callback_Host()
		_G.Network = net.createNetwork( Server_listen( 8520 ) );
	end
	
	function menu.callback_Connect()
		menu.ipLabel.setVisible( true );
		menu.ipField.setVisible( true );
		menu.ipField.grabFocus();
	end
	
	function menu.callback_Quit()
		Intro_quit();
	end
	
	menu.ui.open = function()
		menu.setVisible( true );
	end
	
	
	menu.addItems( "Single", "Host Game", "Connect", "Quit" );
	menu.build();
	menu.setSize( createVec2( 100, 100 ) );
	menu.setPosition( createVec2( 200, 200 ) );
	menu.setAction( "Single", menu.callback_Single );
	menu.setAction( "Host Game", menu.callback_Host );
	menu.setAction( "Connect", menu.callback_Connect );
	menu.setAction( "Quit", menu.callback_Quit );
	menu.setVisible( true );
	
	
	-- Text
	menu.helloMessage = createIntroMessage( "build ver. 001", Fonts.courier );
	menu.helloMessage.setScale( createVec3( 40, 40, 1 ) );
	menu.helloMessage.setPosition( createVec3( 50, 50, 0 ) );
	
	menu.ipLabel = createIntroMessage( "IP: ", Fonts.courier );
	menu.ipLabel.setScale( createVec3( 100, 100, 1 ) );
	menu.ipLabel.setPosition( createVec3( 800, 300, 0 ) );
	menu.ipLabel.setVisible( false );
	
	-- Field
	menu.ipField = createIntroField( "192.168.1.66", Fonts.courier );
	menu.ipField.setScale( createVec3( 100, 100, 1 ) );
	menu.ipField.setPosition( createVec3( 1000, 300, 0 ) );
	menu.ipField.setVisible( false );
	
	menu.ipField.action = function()
		print( "Connecting..." );
		_G.Network = net.createNetwork( Client_connect( menu.ipField.message, 8520 ) );
	end
	
	return menu;
end