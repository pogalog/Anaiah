-- scene
package.path = "resource/lua/?.lua;resource/lua/game/?.lua;resource/map/?.lua";

require( "main.loop" );
require( "input" );
require( "shader" );
require( "menu" );
require( "font" );
require( "game.levelmap" );
require( "game.unit" );
require( "game.team" );
require( "game.player" );
require( "game.ai.controller" );
require( "flow.simul" );

require( "action.queue" );
require( "action.task_sequence" );
require( "action.action_event" );
require( "ui.menu.action_menu" );
require( "ui.menu.second_action_menu" );

require( "warning" );
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
require( "control" );

require( "network.net_proc" );
require( "network.latency" );

require( "game.camera" );

Shaders = {};
Units = {};
Fonts = {};
local shaderPath = "resource/shader/";

function setGameInstance( game, network )
	_G.GameInstance = game;
	_G.Network = net.createNetwork( network );
	if( network == nil ) then
		require( "network.surrogate" );
	end
end


function inventoryAction()
	UIReg.open( "UnitInventoryMenu" );
end

function initScene()
	Camera = createCamera();
	
	Shaders.wireShader = Shader_new( shaderPath.."wire.vsh", shaderPath.."wire.fsh" );
	Shaders.solidShader = Shader_new( shaderPath.."solid.vsh", shaderPath.."solid.fsh" );
	Shaders.animShader = Shader_new( shaderPath.."anim.vsh", shaderPath.."anim.fsh" );
	Shaders.textShader = Shader_new( shaderPath.."text.vsh", shaderPath.."text.fsh" );
	Shaders.cubemapShader = Shader_new( shaderPath.."cubemap.vsh", shaderPath.."cubemap.fsh" );
	
	initializeUIRegister( Controller );
	
	-- LevelMap
	local LM_data = Game_readLevelMap( GameInstance, "resource/map/test.tbs" );
	_G.LevelMap = parseMapDataFromBinaryData( LM_data );
	LevelMap.getTilePointers();
	LevelMap.setGridShader( Shaders.wireShader );
	LevelMap.setRangeShader( Shaders.solidShader );
	LevelMap.setCursorShader( Shaders.wireShader );
	LevelMap.setCursorPosition( createVec2( 1, 1 ) );
	dofile( LevelMap_getMainLuaScript( GameInstance ) );
	
	-- Items
	readItemsFromDisk();
	readWeaponsFromDisk();
	
	-- Units
	local unit_Anaiah = placeUnit( "Anaiah", createVec4( 0.2, 0.5, 0.7, 1.0 ), createVec2( 3, 2 ), "Anaiah.rel", "Anaiah_attack" );
	unit_Anaiah.addItem( Items.Potion );
	unit_Anaiah.addItem( Items.Tarball );
	unit_Anaiah.equipped = Weapons[1];
	unit_Anaiah.stat.mv = 7;
	unit_Anaiah.stat.hp = 120;
	unit_Anaiah.stat.maxHP = 120;
	unit_Anaiah.stat.str = 100;
	local unit_Eran = placeUnit( "Eran", createVec4( 0.7, 0.5, 0.2, 1.0 ), createVec2( 3, 6 ), "Eran.rel", "Eran_attack" );
	unit_Eran.stat.mv = 6;
	unit_Eran.stat.str = 30;
	unit_Eran.stat.hp = 100;
	unit_Eran.stat.maxHP = 100;
	unit_Eran.addItem( Items.Potion );
	unit_Eran.addItem( Items.Tonic );
	unit_Eran.equipped = Weapons[1];
	
	-- Teams
	_G.Teams = createList();
	local team1 = createTeam( "Googuys" );
	local team2 = createTeam( "Bagguys" );
	local team3 = createTeam( "Shadows" );
	createAIController( team3 );
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
			if( tile.occupant ~= nil ) then goto cont; end
			LevelMap.moveUnit( unit, tile );
			break;
			::cont::
		end
	end
	
	
	-- ranges, ftw
	LevelMap.initTileRanges();
	LevelMap.setRangeShaders( Shaders.solidShader );
	
	-- some units at random places for team3
	for i = 1, 10 do
		local unit = placeUnit( "Shadow " .. i, createVec4( 0.8, 0.2, 0.1, 1.0 ), createVec2( 0, 0 ), "Anaiah.rel", "Anaiah_attack" );
		unit.addItem( Items.Potion );
		team3.addUnit( unit );
		randPlacement( unit );
		unit.equipped = Weapons[1];
	end
	
--	local u0 = placeUnit( "Shadow 0", createVec4( 0.8, 0.2, 0.1, 1.0 ), createVec2( 6, 9 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u0 );
--	u0.equipped = Weapons[1];
--	
--	local u1 = placeUnit( "Shadow 1", createVec4( 0.8, 0.2, 0.1, 1.0 ), createVec2( 5, 1 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u1 );
--	u1.equipped = Weapons[1];
--	
--	local u2 = placeUnit( "Shadow 2", createVec4( 0.8, 0.2, 0.1, 1.0 ), createVec2( 5, 8 ), "Anaiah.rel", "Anaiah_attack" );
--	team3.addUnit( u2 );
--	u2.equipped = Weapons[1];
	
	-- Local Player
	_G.Player = createPlayer( Network.isServer() and team1 or team2 );
	
	-- Text
	Fonts.courier = Font_load( GameInstance, "Courier New", Shaders.textShader );
	buildMessage = createMessage( "prototype map_A\nbuild ver. 001", Fonts.courier );
	buildMessage.setScale( createVec3( 40, 40, 1 ) );
	buildMessage.setPosition( createVec3( 50, 50, 0 ) );
	
	-- Menu
	actionMenu = createGameMenu( Menu_new( GameInstance ), Fonts.courier, createControlScheme( Controller ) );
	actionMenu.addItems( "Move", "Attack", "Items" );
	actionMenu.build();
	actionMenu.setSize( createVec2( 50, 50 ) );
	actionMenu.setPosition( createVec2( 200, 600 ) );
	actionMenu.setAction( "Move", actionMenuMove );
	actionMenu.setAction( "Attack", actionAttack );
	actionMenu.setAction( "Items", inventoryAction );
	
	action2Menu = createGameMenu( Menu_new( GameInstance ), Fonts.courier, createControlScheme( Controller ) );
	action2Menu.addItems( "Attack", "Items", "Wait" );
	action2Menu.build();
	action2Menu.setSize( createVec2( 50, 50 ) );
	action2Menu.setPosition( createVec2( 200, 600 ) );
	action2Menu.setAction( "Attack", actionMoveAndAttack );
	action2Menu.setAction( "Items", inventoryAction );
	action2Menu.setAction( "Wait", actionMoveAndWait );
	
	-- UI
	createUnitSelectionUI();
	createActionMenuUI( actionMenu );
	createUnitMoveUI();
	createSecondaryActionMenuUI( action2Menu );
	createInventoryMenuUI( createInventoryMenu( unit_Anaiah ) );
	createItemTargetSelectUI();
	createTargetSelectUI();
	createActionAnimUI();
	
	-- Skybox
	local skybox = Scene_loadSkybox( "resource/skybox", "sky" );
	Skybox_setShader( skybox, Shaders.cubemapShader );
	Scene_setSkybox( GameInstance, skybox );
	
	-- ActionQueue
	ActionQueue = createActionQueue();
	ActionQueue.finished = function()
		UIReg.clear();
		net.sendActionCompleted();
	end
	RemoteQueue = createActionQueue();
	AIQueue = createActionQueue();
	
	-- Asynchronous Task List (use this for latency measurement)
	_G.ATS = ats.createTaskSequenceList();
	if( Network.isServer() ) then
		net.measureLatency( 10000, true );
	end
	
end

-- need to create a Lua Unit, wrap everything inside, and return it
function placeUnit( name, teamColor, location, modelFile, animationFile )
	local unit = createUnit( name );
	local index = #Units + 1;
	unit.userdata = Unit_new( GameInstance );
	Units[index] = unit;
	unit.setTeamColor( teamColor );
	unit.setRingShader( Shaders.wireShader );
	unit.loadModel( "resource/model/" .. modelFile );
	local runAnim = unit.loadAnimation( "resource/model/Anaiah_run.rea", ANIMATE_UNIT_MOVE );
	runAnim.loop = true;
	local atkAnim = unit.loadAnimation( "resource/model/" .. animationFile .. ".rea", ANIMATE_UNIT_ATTACK );
	local itemAnim = unit.loadAnimation( "resource/model/Anaiah_item.rea", ANIMATE_UNIT_USE_ITEM );
	Unit_setShader( unit.userdata, Shaders.animShader );
	local tile = LevelMap.grid.getTile( location );
	LevelMap.addUnit( unit );
	LevelMap.moveUnit( unit, tile );
	return unit;
end


