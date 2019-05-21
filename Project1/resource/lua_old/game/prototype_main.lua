require( "network.receiver" );
require( "menu.display" );
require( "menu.menu" );
require( "input.input_proc" );
require( "game.encounter" );
require( "game.item" );

-- main script for protyping game play

function initGame()
  local context = _G.gameContext;
  
  readItemsFromDisk();
  initMap();
  assignTeams();
  initializeDisplays();
  initializeMenus();
end

function assignTeams()
  Teams = {};
  Teams[BLUE_TEAM] = blueTeam;
  Teams[GREEN_TEAM] = greenTeam;
  Teams[RED_TEAM] = redTeam;
  Player.team = Teams[Player.teamID];
end


function selectUnit( unit )
  local map = _G.currentMap;
  if( unit == nil ) then return; end
  map.selectUnit( unit );
  --map.movePath.restartWith( unit.tile );
  --map.grid.getTilesWithinRange( unit, unit.stat.mv, true );
  PF.selectJUnit( unit.userdata );
end

function moveUnit( unit, location )
  local map = _G.currentMap;
  map.moveUnit( unit, map.grid.getTile( location ) );
  map.selectedUnit = nil;
  map.grid.clearMarkings();
  map.movePath.clearPath();
  local j_location = PF.createJVec2i( location.x, location.y );
end

function moveUnitRemote( unit, path )
  local map = _G.currentMap;
  local t1a = path.get( path.length() );
  if( t1a == nil ) then print( 'oh crap' ); end
  local t1 = map.grid.getTile( t1a );
  if( path.length() > 1 ) then
    local t0a = path.get( path.length()-1 );
    if( t0a == nil ) then print( 'durn dump' ); end
    local t0 = map.grid.getTile( t0a );
    local direction = t0.getDirectionToNeighbor( t1 );
    unit.orientation = direction;
    
    local location = t1.address;
    PF.moveUnitRemote( unit, location, direction );
  end
  map.moveUnit( unit, t1 );
  PF.startMovingUnitRemote( unit, path );
  unit.stat.ap = unit.stat.ap - (path.length()-1);
  
  PF.syncActionPoints( unit );
  updateUnitDisplay();
  PF.clearRanges();
  PF.markRanges();
end

function confirmRemoteAction( unitID, totalAP )
  local map = _G.currentMap;
  local unit = map.getUnitByID( unitID );
  GameState.activePlayer.activeUnit = unit;
  GameState.addAP( totalAP );
  GameState.executeAction( true );
  GameState.activePlayer.activeUnit = nil;
  PF.syncActionPointsAll();
end


function cancelMoveRemote( unitID, pos, ap, orientation )
  local map = _G.currentMap;
  local unit = map.getUnitByID( unitID );
  map.returnUnit( unit );
  map.selectedUnit = nil;
  --map.moveUnit( unit, map.grid.getTile( pos ) );
  unit.orientation = orientation;
  unit.stat.ap = unit.stat.ap + ap;
  PF.syncActionPoints( unit );
  PF.moveUnitRemote( unit, pos, orientation );
end

function attackRemote( data )
  local map = _G.currentMap;
  resolveAttack( data );
  -- display damage/crit/miss and so forth
  displayDamage( data );
  updateUnitDisplay();
end

function useItemRemote( unitID, targetID, itemID )
  local map = _G.currentMap;
  local unit = map.getUnitByID( unitID );
  local target = map.getUnitByID( targetID );
  local item = Items[itemID];
  GameState.activePlayer.activeUnit = unit;
  item.func( target, item, true );
  GameState.activePlayer.activeUnit = nil;
  updateUnitDisplay();
end


