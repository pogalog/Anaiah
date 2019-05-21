-- Prototype startup main menu
menuObject = nil;

local j_LevelMapIO = luajava.bindClass( "hex.fileio.LevelMapIO" );

-- main init function, called by Java-class menu that this script controls
-- menuObject is of type userdata and contains a ref to the menu class instance
-- this function must be called before anything can be done
function initializeMenu( mainMenu )
  menuObject = mainMenu;
  
  -- create the menu layout
  mainPanel = menuObject:addPanel();
  loadPanel = menuObject:addPanel();
  loadPanel:setVisible( false );
  loadMapButton = mainPanel:addButton2D( "Load Map", 100, 300, 100 );
  quitButton = mainPanel:addButton2D( "Quit", 100, 200, 100 );
  --menuObject:useFullScreen( true );
end

function buttonPress( button )
  if( button == loadMapButton ) then
    local cd = luajava.newInstance( "java.io.File", "./resource/map" );
    local jfc = luajava.newInstance( "javax.swing.JFileChooser", cd );
    choice = jfc:showOpenDialog( menuObject );
    if( choice == 0 ) then
      local selectedFile = jfc:getSelectedFile();
      map = j_LevelMapIO:readLevelMapFromFile( selectedFile );
      gameContext = luajava.newInstance( "hex.ui.game.GameContext", map );
      
    end
    
  elseif( button == quitButton ) then
    menuObject:quit();
  end
  menuObject:repaint();
end
