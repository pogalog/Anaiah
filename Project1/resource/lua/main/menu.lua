-- Main Menu
require("math.vector");
require("ui.text.message");
require("ui.text.field");
require("network.main");




function initIntro(width, height)
	_G.Intro = Intro_new(width, height);
	Intro_setClearColor(Intro, Vec4_new(0.3, 0.3, 0.3, 1.0));
	initMenus();
end

function initMenus()
	loadShaders();
	loadFonts();
	createMainMenu();
end




function loadShaders()
	Shaders = {};
	Shaders.wireShader = Render.createShader("wire.vsh", "wire.fsh");
	Shaders.solidShader = Render.createShader("solid.vsh", "solid.fsh");
	Shaders.textShader = Render.createShader("text.vsh", "text.fsh");
end


function loadFonts()
	Fonts = {};
	Render.setFontShader(Shaders.textShader);
	Fonts.courier = Render.createFont("Courier New");
end

function createMainMenu()
	local menu = UI.createGameMenu(IntroMenu_new(Intro), Fonts.courier, Input.createControlScheme(Controller));
	UI.registerUI(UI.createUI("MainMenu", menu.control, menu), true);
	
	function menu.callback_Single()
		if( Network.userdata == nil ) then
			Network.createNetwork(nil);
		end
		
		Lua_feedGameInstance(GameState, GameInstance, Network.userdata);
		Lua_callFunction(GameState, "initScene");
		Intro_controlSleep();
		Render_changeMode(1);
	end
	
	function menu.callback_Host()
		local server = Server_listen(8520);
		Network.createNetwork(server);
	end
	
	function menu.callback_Connect()
		menu.ipLabel.setVisible(true);
		menu.ipField.setVisible(true);
		menu.ipField.grabFocus();
	end
	
	function menu.callback_Quit()
		Intro_quit();
	end
	
	menu.ui.open = function()
		menu.setVisible( true );
	end
	
	menu.addItems("Single", "Host Game", "Connect", "Quit");
	menu.build();
	menu.setSize(Vec2_new(100, 100));
	menu.setPosition(Vec2_new(200, 200));
	menu.setAction("Single", menu.callback_Single);
	menu.setAction("Host Game", menu.callback_Host);
	menu.setAction("Connect", menu.callback_Connect);
	menu.setAction("Quit", menu.callback_Quit);
	menu.setVisible(true);
	
	
	-- Text
	menu.helloMessage = UI.createIntroMessage("build ver. 001", Fonts.courier);
	menu.helloMessage.setScale(Vec3_new(40, 40, 1));
	menu.helloMessage.setPosition(Vec3_new(50, 50, 0));
	
	menu.ipLabel = UI.createIntroMessage("IP: ", Fonts.courier);
	menu.ipLabel.setScale(Vec3_new(100, 100, 1));
	menu.ipLabel.setPosition(Vec3_new(800, 300, 0));
	menu.ipLabel.setVisible(false);
	
	-- Field
	menu.ipField = UI.createIntroField("192.168.1.64", Fonts.courier);
	menu.ipField.setScale(Vec3_new(100, 100, 1));
	menu.ipField.setPosition(Vec3_new(1000, 300, 0 ));
	menu.ipField.setVisible(false);
	
	menu.ipField.action = function()
		print("Connecting...");
		Network.createNetwork(Client_connect(menu.ipField.message, 8520));
	end
	
	return menu;
end