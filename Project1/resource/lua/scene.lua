-- scene
package.path = "resource/lua/?.lua;resource/lua/game/?.lua;resource/map/?.lua";


require( "main.loop" );
require( "game.main" );
require( "math.matrix" );
require( "input.main" );
require( "render.pipeline" );
require( "render.shader" );
require( "render.render_unit" );
require( "render.framebuffer" );
require( "render.cubemap" );
require( "render.font" );
require( "main.menu" );
require( "main.warning" );
require( "flow.simul" );
require( "network.main" );
require( "binaryio.map_io" );
require( "structure.queue" );
require( "executive.main" );
require( "ui.menu.action_menu" );
require( "ui.menu.second_action_menu" );
require( "ui.menu.main" );
require( "ui.unit_select_ui" );
require( "ui.unit_move_ui" );
require( "ui.unit_action_menu_ui" );
require( "ui.unit_secondary_action_ui" );
require( "ui.unit_inventory_menu_ui" );
require( "ui.target_select_ui" );
require( "ui.item_target_select_ui" );
require( "ui.action_anim_ui" );
require( "ui.overlay.unit_info" );
require( "ui.overlay.main" );
require( "ui.overlay.damage_display" );
require( "ui.menu.unit_inventory_menu" );
require( "input.processing" );


_G.RenderUnits = createList();
_G.Framebuffers = {};
_G.Shaders = {};
_G.Units = {};
_G.Fonts = {};
local shaderPath = "resource/shader/";


function setGameInstance( game, network )
	GameInstance = game;
	Network.createNetwork( network );
	if( network == nil ) then
		require( "network.surrogate" );
	end
end


function UI.inventoryAction()
	UI.open( "UnitInventoryMenu" );
end

function initScene()
	InitGame();
	
	-- Window
	Window = {};
	local w, h = Render_getWindowSize( GameInstance );
	Window.width = w;
	Window.height = h;
	
	-- pipeline
	local pipeline = Render.createPipeline();
	
	-- shaders
	Shaders.wireShader = Render.createShader( "wire.vsh", "wire.fsh" );
	Shaders.solidShader = Render.createShader( "solid.vsh", "solid.fsh" );
	Shaders.animShader = Render.createShader( "anim.vsh", "anim.fsh" );
	Shaders.textShader = Render.createShader( "text.vsh", "text.fsh" );
	Shaders.cubemapShader = Render.createShader( "cubemap.vsh", "cubemap.fsh" );
	
	-- framebuffers
	Framebuffers.main = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.bpf = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.blur = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.bloomH8 = Render.createFramebuffer( Window.width/8, Window.height/8 );
	Framebuffers.bloomV8 = Render.createFramebuffer( Window.width/8, Window.height/8 );
	Framebuffers.bloomH4 = Render.createFramebuffer( Window.width/4, Window.height/4 );
	Framebuffers.bloomV4 = Render.createFramebuffer( Window.width/4, Window.height/4 );
	Framebuffers.bloomH2 = Render.createFramebuffer( Window.width/2, Window.height/2 );
	Framebuffers.bloomV2 = Render.createFramebuffer( Window.width/2, Window.height/2 );
	Framebuffers.bloomH1 = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.bloomV1 = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.noise = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.ui = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.crepuscular = Render.createFramebuffer( Window.width, Window.height );
	Framebuffers.gbuffer = Render.createGBuffer( Window.width, Window.height );
	
	
	
	-- render units
	-------------------------------------------------
	local mainRU = Render.createUnit( "main" );
	local rangeRU = Render.createUnit( "range" );
	local bpfRU = Render.createPostRU( "bpf", "brightpass.fsh" );
	local blurH8RU = Render.createPostRU( "blurH8", "blurHorSmall.fsh" );
	local blurV8RU = Render.createPostRU( "blurV8", "blurVerSmall.fsh" );
	local blurH4RU = Render.createPostRU( "blurH4", "blurHor.fsh" );
	local blurV4RU = Render.createPostRU( "blurV4", "blurVer.fsh" );
	local blurH2RU = Render.createPostRU( "blurH2", "blurHor.fsh" );
	local blurV2RU = Render.createPostRU( "blurV2", "blurVer.fsh" );
	local blurH1RU = Render.createPostRU( "blurH", "blurHor.fsh" );
	local blurV1RU = Render.createPostRU( "blurV", "blurVer.fsh" );
	local raysRU = Render.createPostRU( "crepuscular", "scatter.vsh", "crepuscular.fsh" );
	local noiseRU = Render.createPostRU( "noise", "noise.fsh" );
	local gridRU = Render.createUnit( "grid" );
	local uiRU = Render.createUnit( "ui" );
	local screenRU = Render.createPostRU( "screen", "blend3.fsh" );
	local outputRU = Render.createPostRU( "output", "quad.fsh" );
	
	--[[
	Todo List:
	Figure out a good solution for passing in time-varying uniform params to the shader
	Fix Blinn-phong lighting problems
	Materials
	Physically based shading techniques? (https://learnopengl.com/#!PBR/Theory)
	SSAO (https://learnopengl.com/#!Advanced-Lighting/SSAO)
	Point source shadows (http://ogldev.atspace.co.uk/www/tutorial43/tutorial43.html)
	GPU Paricles
	]]
	
	-- Models
	local sunModel = Geom.createCircularDisc( 5 );
	sunModel.build();
	sunModel.setShader( Shaders.solidShader );
	sunModel.setUniform( "vec4 color", Color_new( 1, 1, 1, 1 ) );
	sunModel.setPosition( Vec3_new( 0, -1000, -2000 ) );
	sunModel.setScale( Vec3_new( 20, 20, 20 ) );
	sunModel.setBillboard( true );
	mainRU.addStaticModel( sunModel );
	
	
	-- add to pipeline
	pipeline.addUnits( mainRU, bpfRU );
	pipeline.addUnits( blurH8RU, blurV8RU, blurH4RU, blurV4RU, blurH2RU, blurV2RU, blurH1RU, blurV1RU );
	pipeline.addUnits( raysRU, rangeRU, noiseRU, gridRU, uiRU, screenRU );
--	pipeline.addUnit( outputRU );

	RenderUnits.add( uiRU, "ui" );
		
	-- setup
	pipeline.clearBufferBits( bpfRU, blurH8RU, blurV8RU, blurH4RU, blurV4RU, blurH2RU, blurV2RU, blurH1RU, blurV1RU, mainRU );
	pipeline.clearBufferBits( raysRU, uiRU, screenRU );
	rangeRU.useBlendFunc( GL.SRC_ALPHA, GL.ONE );
	uiRU.useDepthFunc( GL.LEQUAL );
	
--	mainRU.setOutput( Framebuffers.gbuffer );
	mainRU.setOutput( Framebuffers.main );
	rangeRU.setOutput( Framebuffers.main );
	bpfRU.addInput( "colormap", Framebuffers.main );
	bpfRU.setOutput( Framebuffers.bpf );
	blurH8RU.addInput( "colormap", Framebuffers.bpf );
	blurH8RU.setOutput( Framebuffers.bloomH8 );
	blurH8RU.setUniform( "float xstep", 2.0/Window.width );
	
	blurV8RU.addInput( "colormap", Framebuffers.bloomH8 );
	blurV8RU.setOutput( Framebuffers.bloomV8 );
	blurV8RU.setUniform( "float ystep", 2.0/Window.height );
	
	blurH4RU.addInput( "colormap", Framebuffers.bloomV8 );
	blurH4RU.setOutput( Framebuffers.bloomH4 );
	blurH4RU.setUniform( "float xstep", 4.0/Window.width );
	
	blurV4RU.addInput( "colormap", Framebuffers.bloomH4 );
	blurV4RU.setOutput( Framebuffers.bloomV4 );
	blurV4RU.setUniform( "float ystep", 4.0/Window.height );
	
	blurH2RU.addInput( "colormap", Framebuffers.bloomV4 );
	blurH2RU.setOutput( Framebuffers.bloomH2 );
	blurH2RU.setUniform( "float xstep", 8.0/Window.width );
	
	blurV2RU.addInput( "colormap", Framebuffers.bloomH2 );
	blurV2RU.setOutput( Framebuffers.bloomV2 );
	blurV2RU.setUniform( "float ystep", 8.0/Window.height );
	
	blurH1RU.addInput( "colormap", Framebuffers.bloomV2 );
	blurH1RU.setOutput( Framebuffers.bloomH1 );
	blurH1RU.setUniform( "float xstep", 16.0/Window.width );
	
	blurV1RU.addInput( "colormap", Framebuffers.bloomH1 );
	blurV1RU.setOutput( Framebuffers.bloomV1 );
	blurV1RU.setUniform( "float ystep", 16.0/Window.height );
	
--	noiseRU.setOutput( Framebuffers.noise );
--	noiseRU.setUniform( "float time", os.time() );
	
	
	raysRU.addInput( "map", Framebuffers.main );
--	raysRU.setUniform( "cameraMVP", THINGBUTT ); smallish problem here...
	raysRU.setUniform( "vec3 lightPos", sunModel.position );
	raysRU.setUniform( "float aspect", Window.width / Window.height );
	raysRU.setOutput( Framebuffers.crepuscular );
	gridRU.setOutput( Framebuffers.main );
	uiRU.setOutput( Framebuffers.ui );
	screenRU.addInput( "map0", Framebuffers.main );
	screenRU.addInput( "map1", Framebuffers.bloomV1 );
	screenRU.addInput( "map2", Framebuffers.ui );
	screenRU.addInput( "map3", Framebuffers.crepuscular );
	
--	outputRU.addTexture( "colormap", Framebuffers.gbuffer.pos );
	-------------------------------------------------
	
	
	
	UI.initializeUIRegister( Controller );
		
	-- LevelMap
	local LM_data = Game_readLevelMap( GameInstance, "resource/map/map0.tbs" );
	_G.LevelMap = Binary.parseMapDataFromBinaryData( LM_data, true );
	LevelMap.grid.generateModel();
	LevelMap.getTilePointers();
	LevelMap.setGridShader( Shaders.wireShader );
	LevelMap.setRangeShader( Shaders.solidShader );
	LevelMap.cursor.buildModel();
	LevelMap.cursor.setShader( Shaders.wireShader );
	gridRU.addStaticModel( LevelMap.grid.model );
	gridRU.addStaticModel( LevelMap.cursor.model );
	LevelMap.grid.setShader( Shaders.wireShader );
	dofile( LevelMap_getMainLuaScript( GameInstance ) );
	
	-- ranges, ftw
	LevelMap.initTileRanges();
	LevelMap.setRangeShaders( Shaders.solidShader );
	LevelMap.addRangesToRenderUnit( rangeRU );
	
	-- Items
	Game.readItemsFromDisk();
	Game.readWeaponsFromDisk();
	
	-- Units
	local unit_Anaiah = placeUnit( "Anaiah", Vec4_new( 0.2, 0.5, 0.7, 1.0 ), Vec2_new( 4, 3 ), "Anaiah.rel", "Anaiah_attack" );
	mainRU.addUnit( unit_Anaiah );
	unit_Anaiah.addItem( Items.Potion );
	unit_Anaiah.addItem( Items.Tarball );
	unit_Anaiah.equipped = Weapons[1];
	unit_Anaiah.stat.mv = 7;
	unit_Anaiah.stat.hp = 500;
	unit_Anaiah.stat.maxHP = 500;
	unit_Anaiah.stat.ap = 500;
	unit_Anaiah.stat.maxAP = 500;
	unit_Anaiah.stat.str = 45;
	local unit_Eran = placeUnit( "Eran", Vec4_new( 0.7, 0.5, 0.2, 1.0 ), Vec2_new( 3, 6 ), "Eran.rel", "Eran_attack" );
	mainRU.addUnit( unit_Eran );
	unit_Eran.stat.mv = 6;
	unit_Eran.stat.str = 30;
	unit_Eran.stat.hp = 100;
	unit_Eran.stat.maxHP = 100;
	unit_Eran.stat.ap = 100;
	unit_Eran.stat.maxAP = 100;
	unit_Eran.addItem( Items.Potion );
	unit_Eran.addItem( Items.Tonic );
	unit_Eran.equipped = Weapons[1];
	
	-- Teams
	_G.Teams = createList();
	local team1 = Game.createTeam( "Googuys" );
	local team2 = Game.createTeam( "Bagguys" );
	local team3 = Game.createTeam( "Shadows" );
	Game.createAIController( team3 );
	Teams.add( team1 );
	Teams.add( team2 );
	Teams.add( team3 );
	team1.addUnit( unit_Anaiah );
	team2.addUnit( unit_Eran );
	
	-- fix the random places
	local function randPlacement( unit )
--		math.randomseed( os.time() );
		while( true ) do
			local x = math.random( 10 );
			local y = math.random( 10 );
			local tile = LevelMap.grid.getTileAtAddress( x, y );
			if( tile == nil ) then goto cont; end
			if( tile.exists == false ) then goto cont; end
			if( tile.getOccupant() ~= nil ) then goto cont; end
			LevelMap.moveUnit( unit, tile );
			break;
			::cont::
		end
	end
	
	
	-- some units at random places for team3
	for i = 1, 5 do
		local unit = placeUnit( "Shadow " .. i, Vec4_new( 0.8, 0.2, 0.1, 1.0 ), Vec2_new( 0, 0 ), "Anaiah.rel", "Anaiah_attack" );
		mainRU.addUnit( unit );
		bpfRU.addUnit( unit );
		unit.stat.maxAP = 100;
		unit.stat.ap = 100;
		unit.stat.mv = 6;
		unit.addItem( Items.Potion );
		team3.addUnit( unit );
		randPlacement( unit );
		unit.equipped = Weapons[1];
	end
	
--	local u0 = placeUnit( "Shadow 0", Vec4_new( 0.8, 0.2, 0.1, 1.0 ), Vec2_new( 6, 9 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u0 );
--	u0.equipped = Weapons[1];
--	
--	local u1 = placeUnit( "Shadow 1", Vec4_new( 0.8, 0.2, 0.1, 1.0 ), Vec2_new( 5, 1 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u1 );
--	u1.equipped = Weapons[1];
--	
--	local u2 = placeUnit( "Shadow 2", Vec4_new( 0.8, 0.2, 0.1, 1.0 ), Vec2_new( 5, 8 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u2 );
--	u2.equipped = Weapons[1];
	
	-- Local Player
	Player = Game.createPlayer( Network.isServer() and team1 or team2 );
	
	-- Text
	Render.FontShader = Shaders.textShader;
	Fonts.courier = Render.createFont( "Courier New" );
	buildMessage = UI.createMessage( "prototype map \'" .. LevelMap.name .. "\'\nbuild ver. 002", Fonts.courier );
	buildMessage.setScale( Vec3_new( 40, 40, 1 ) );
	buildMessage.setPosition( Vec3_new( 50, 50, 0 ) );
	uiRU.addUIMessage( buildMessage );
	
	-- Menu
	actionMenu = UI.createGameMenu( Menu_new( GameInstance ), Fonts.courier, Input.createControlScheme( Controller ) );
	actionMenu.addItems( "Move", "Attack", "Items" );
	actionMenu.build();
	actionMenu.setSize( Vec2_new( 50, 50 ) );
	actionMenu.setPosition( Vec2_new( 200, 600 ) );
	actionMenu.setAction( "Move", UI.actionMenuMove );
	actionMenu.setAction( "Attack", UI.actionAttack );
	actionMenu.setAction( "Items", UI.inventoryAction );
	uiRU.addUIMenu( actionMenu );
	
	action2Menu = UI.createGameMenu( Menu_new( GameInstance ), Fonts.courier, Input.createControlScheme( Controller ) );
	action2Menu.addItems( "Attack", "Items", "Wait" );
	action2Menu.build();
	action2Menu.setSize( Vec2_new( 50, 50 ) );
	action2Menu.setPosition( Vec2_new( 200, 600 ) );
	action2Menu.setAction( "Attack", UI.actionMoveAndAttack );
	action2Menu.setAction( "Items", UI.inventoryAction );
	action2Menu.setAction( "Wait", UI.actionMoveAndWait );
	uiRU.addUIMenu( action2Menu );
	
	-- UI
	UI.createUnitSelectionUI();
	UI.createActionMenuUI( actionMenu );
	UI.createUnitMoveUI();
	UI.createSecondaryActionMenuUI( action2Menu );
	UI.createInventoryMenuUI( UI.createInventoryMenu( unit_Anaiah ) );
	UI.createItemTargetSelectUI();
	UI.createTargetSelectUI();
	UI.createActionAnimUI();
	
	-- Skybox
	local skybox = Render.createCubemap( "resource/skybox", "sky" );
	skybox.setShader( Shaders.cubemapShader );
	mainRU.setCubemap( skybox );
	
	-- Measure latency
	if( Network.isServer() ) then
		Network.measureLatency( 5, true );
	end
	
	LevelMap.setCursorPosition( Vec2_new( 1, 1 ) );
end



-- create a Lua Unit, wrap everything inside, and return it
function placeUnit( name, teamColor, location, modelFile, animationFile )
	local unit = createUnit( name, LevelMap.grid );
	local index = #Units + 1;
	unit.userdata = Unit_new( GameInstance );
	Units[index] = unit;
	unit.setTeamColor( teamColor );
	unit.setRingShader( Shaders.wireShader );
	unit.loadModel( "resource/model/" .. modelFile );
	local runAnim = Anim.createUnitAnimation( "resource/model/Anaiah_run.rea", unit, Anim.ANIMATE_UNIT_MOVE );
	runAnim.loop = true;
	local atkAnim = Anim.createUnitAnimation( "resource/model/" .. animationFile .. ".rea", unit, Anim.ANIMATE_UNIT_ATTACK );
	local itemAnim = Anim.createUnitAnimation( "resource/model/Anaiah_item.rea", unit, Anim.ANIMATE_UNIT_USE_ITEM );
	unit.setShader( Shaders.animShader );
	local tile = LevelMap.grid.getTile( location );
	LevelMap.addUnit( unit );
	LevelMap.moveUnit( unit, tile );
	return unit;
end


