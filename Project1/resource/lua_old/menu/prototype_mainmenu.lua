require( "network.receiver" );
require( "game.player" );
require( "game.gamestate" );

-- Prototype startup main menu
local menuObject = nil;

-- main init function, called by Java-class menu that this script controls
-- menuObject is of type userdata and contains a ref to the menu class instance
-- this function must be called before anything can be done
function initializeMenu( mainMenu )
  menuObject = mainMenu;
  
  -- create the menu layout
  mainPanel = menuObject:addPanel();
  connectPanel = menuObject:addPanel();
  teamPanel = menuObject:addPanel();
  connectPanel:setVisible( false );
  teamPanel:setVisible( false );
  loadMapButton = mainPanel:addButton2D( "Load Map", 100, 300, 100 );
  networkButton = mainPanel:addButton2D( "Connect", 100, 200, 100 );
  quitButton = mainPanel:addButton2D( "Quit", 100, 100, 100 );
  loopbackButton = connectPanel:addButton2D( "Localhost", 100, 100, 50 );
  backButton = connectPanel:addButton2D( "back", 20, 20, 40 );
  addressField = connectPanel:addTextField( 100, 300, 200, 50 );
  blueTeamButton = teamPanel:addButton2D( "Blue team", 100, 300, 100 );
  greenTeamButton = teamPanel:addButton2D( "Green team", 100, 200, 100 );
  --menuObject:useFullScreen( true );
  
end

function inputConfirm( source )
  if( source == addressField ) then
    _G.windowLocation = menuObject:getWindowLocation();
    menuObject:hideWindow();
    _G.networkNode = luajava.newInstance( "hex.network.NetworkClient" );
    _G.networkNode:connect( addressField:getText(), 8123 );
    Local_Server = false;
  end
end

function buttonPress( button )
  if( button == loadMapButton ) then
    local cd = luajava.newInstance( "java.io.File", "./resource/map" );
    jfc = luajava.newInstance( "javax.swing.JFileChooser", cd );
    choice = jfc:showOpenDialog( menuObject );
    if( choice == 0 ) then
      mainPanel:setVisible( false );
      teamPanel:setVisible( true );
    end
  elseif( button == quitButton ) then
    menuObject:quit();
  elseif( button == networkButton ) then
    mainPanel:setVisible( false );
    connectPanel:setVisible( true );
  elseif( button == backButton ) then
    mainPanel:setVisible( true );
    connectPanel:setVisible( false );
  elseif( button == loopbackButton ) then
    _G.windowLocation = menuObject:getWindowLocation();
    menuObject:hideWindow();
    _G.networkNode = luajava.newInstance( "hex.network.NetworkClient" );
    _G.networkNode:connect( "127.0.0.1", 8123 );
    Local_Server = false;
  elseif( button == blueTeamButton ) then
    startGame( BLUE_TEAM );
  elseif( button == greenTeamButton ) then
    startGame( GREEN_TEAM );
  end
  menuObject:repaint();
end


function startGame( team )
  Local_Server = true;
  local windowLocation = menuObject:getWindowLocation();
  menuObject:hideWindow();
  local selectedFile = jfc:getSelectedFile();
  map = j_LevelMapIO:readLevelMapFromFile( selectedFile );
  _G.gameContext = luajava.newInstance( "hex.ui.game.GameContext", map, networkNode, false );
  _G.gameContext:setWindowLocation( windowLocation );
  _G.networkNode = luajava.newInstance( "hex.network.NetworkServer", _G.gameContext, 8123 );
  _G.networkNode:startServer();
  local data = {};
  data.id = 0;
  data.team = team;
  local fname = selectedFile:getName();
  data.nameLen = string.len( fname );
  data.mapName = selectedFile:getName();
  PF.sendData( data );
  jfc = nil;
  
  Player = createPlayer( 1, team, false );
  Player.name = "Server";
  require( "game.prototype_main" );
  initGame();
  
  -- I really want this setup being done in a more intelligent place.
  GameState = createGameState();
  GameState.activePlayer = Player;
  Player.remainingMoves = 3;
  local clTeam = -1;
  if( Player.team.id == BLUE_TEAM ) then clTeam = GREEN_TEAM;
  else clTeam = BLUE_TEAM; end
  Players[1] = Player;
  Players[1].control = DefaultControl;
  Players[2] = createPlayer( 2, clTeam, false );
  Players[2].name = "Client";
  Players[2].team = Teams[Players[2].teamID];
  Players[2].control = DefaultControl;
  Players[3] = createPlayer( 3, RED_TEAM, true );
  Players[3].name = "AI";
  Players[3].team = Teams[Players[3].teamID];
  Players[3].control = AIControl;
  PF.createPlayer();
end

