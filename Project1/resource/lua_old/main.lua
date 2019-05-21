-- Lua Main --
require( "input" );
require( "shader" );
require( "menu" );
require( "font" );
require( "input" );
require( "ui.ui_register" );
require( "main.menu" );
require( "warning" );




function file_exists( name )
   local f = io.open( name, "r" )
   if f ~= nil then io.close( f ) return true else return false end
end


-- Temporarily build a GameInstance and load a LevelMap
GameInstance, GameState = Main_createNewGameInstance( ControllerPort, AudioManager );

-- Register Luac functions on the newly created Lua states
Game_registerGameLuacFunctions( GameInstance );
Game_registerAILuacFunctions( GameInstance );



-- Allow C++ to retrieve a pointer to the GameInstance
function getGameInstance()
	return GameInstance;
end


initializeUIRegister( Controller );



function loadGame()
	initIntro( 1280, 720 );
	
	-- Temporarily load in a Lua file on the game state, and call it's initScene()
	Lua_doFile( GameState, "resource/lua/scene.lua" );
end



print( "Main program initialized..." );