-- movement path

require( "game.grid" );
require( "game.list" );

function createPath( grid )
  local path = {};
  path.desc = "MovementPath";
  path.grid = grid;
  path.tiles = createList();
  path.unit = nil;
  path.startTile = nil;
  path.cap = 0;
  
  -- FUNCTIONS
  function path.addTile( tile, unit )
    if( unit == nil ) then return; end
    if( unit.tile == tile ) then
      path.tiles.clear();
      return;
    end
    
    cap = unit.stat.mv;
    path.unit = unit;
    
    -- check if the tile is valid
    if( tile.exists == false ) then return; end
    if( tile.moveID > cap ) then return; end
    -- check if we already have this tile
    if( tile == path.startTile ) then
      for i = 1, path.tiles.length() do
        local t = path.tiles.get(i);
        t.pathValCost = 1000;
        t.pathValDir = -1;
      end
      path.tiles.clear();
      path.setUnitPathing( tile );
    end
    for i = 1, path.tiles.length() do
      local t = path.tiles.get(i);
      if( t == tile ) then
        path.tiles.removeRange( i, path.tiles.length() );
      end
    end
    
    -- check for adjacency
    local tf = nil;
    if( path.tiles.length() > 0 ) then
      tf = path.tiles.get( path.tiles.length() );
    else
      tf = path.startTile;
    end
    if( tile.address.hexDistanceTo( tf.address ) > 1 ) then
      path.tiles.add( tile );
      path.findShortestPath();
      path.setUnitPathing( tile );
      return;
    end
    -- repath
    if( path.tiles.length() == cap ) then
      path.tiles.add( tile );
      path.findShortestPath();
      path.setUnitPathing( tile );
      return;
    end
    if( path.tiles.length() > 0 ) then
      local prev = path.tiles.get( path.tiles.length() );
      prev.pathValDir = prev.getDirectionToNeighbor( tile );
    end
    path.tiles.add( tile );
    tile.pathValCost = 0;
    for i = 1, path.tiles.length() do
      path.tiles.get(i).pathValCost = path.tiles.length() - i;
    end
    path.setUnitPathing( tile );
    
  end
  
  function path.length()
    return path.tiles.length();
  end
  
  function path.print()
    print( "Path, len="..path.tiles.length() );
    for i = 1, path.tiles.length() do
      print( path.tiles.get(i).toString() );
    end
    
  end
  
  function path.computeOrientation()
    if( path.tiles.length() < 2 ) then return 0; end
    local tiles = path.tiles;
    local res = tiles.get( tiles.length()-1 ).getDirectionToNeighbor( tiles.get( tiles.length() ) );
    return res;
  end
  
  function path.findShortestPath()
    local dest = path.getDestinationTile();
    path.clearPath();
    path.grid.addPathFindingTarget( dest );
    grid.findPath( path.unit );
    local best = path.startTile.bestTile;
    while( best ~= nil ) do
      path.tiles.add( best );
      best = best.bestTile;
    end
    grid.clearPathFinding();
    for i = 1, path.tiles.length() do
      local ti = path.tiles.get(i);
      local j = i+1;
      if( j <= path.tiles.length() ) then
        local tj = path.tiles.get(j);
        ti.pathValDir = ti.getDirectionToNeighbor( tj );
      end
      ti.pathValCost = path.tiles.length() - i;
    end
  end
  
  function path.clearPath()
    for i = 1, path.tiles.length() do
      path.tiles.get(i).pathValDir = -1;
      path.tiles.get(i).pathValCost = 1000;
    end
    path.tiles.clear();
  end
  
  function path.restartWith( tile )
    path.clearPath();
    path.startTile = tile;
  end
  
  function path.getDestinationTile()
    return path.tiles.get( path.tiles.length() );
  end
  
  
  function path.setUnitPathing( tile )
    if( path.tiles.length() > 1 ) then
      path.unit.penultTile = path.tiles.get( path.tiles.length()-1 );
    end
      
  end
  
  
  return path;
end
