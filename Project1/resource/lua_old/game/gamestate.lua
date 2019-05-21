require( "game.ai.queue" );
-- game state

MAX_PLAYERS = 3;
ALLY_AP_MULT = 0.5;
OTHER_AP_MULT = 5.0 * ALLY_AP_MULT;

local startedMove = false;

-- an event queue used to store AI actions
Action_Queue = createQueue();


function createGameState()
  local state = {};
  
  state.activePlayer = nil;
  state.activePlayerID = 1;
  state.elapsedAP = 0;
  state.currentAP = 0;
  
  function state.addAP( ap )
    state.currentAP = state.currentAP + ap;
  end
  
  function state.subAP( ap )
    state.currentAP = state.currentAP - ap;
  end
  
  
  function state.switchTeams()
    -- check for units that have not moved this turn,
    -- give them each a bonus +2 AP
    -- also, set all moved flags back to 'false'
    state.activePlayer.endTurn = false;
    local team = state.activePlayer.team;
    for i = 1, team.units.length() do
      local u = team.units.get(i);
      if( u.moved == false ) then u.gainAP( 2.0 ); end
      u.moved = false;
    end
    
    -- increment player index, change to new player
    local id = state.activePlayer.id + 1;
    if( id > MAX_PLAYERS ) then
      id = 1;
    end
    state.activePlayer = Players[id];
    
    -- this needs to be set based on a map parameter for this team
    state.activePlayer.remainingMoves = 3;
    
    -- give all units on new team +1 AP
    team = state.activePlayer.team;
    for i = 1, team.units.length() do
      local u = team.units.get(i);
      u.gainAP( 1.0 );
    end
    
    -- make sure this team has at least one available unit
    local avail = state.checkAvailability();
    if( avail == false ) then
      state.switchTeams();
      return;
    end
    
    state.activePlayer.assumeControl();
  end
  
  
  function state.executeAction( remote )
    local ap = state.currentAP;
    local p = state.activePlayer;
    -- expend AP
    local unit = p.activeUnit;
    unit.moved = true;
    
    -- grant AP to other units
    local map = _G.currentMap;
    for i = 1, map.teams.length() do
      local team = map.teams.get(i);
      if( team == state.activePlayer.team ) then
        for j = 1, team.units.length() do
          local u = team.units.get(j);
          if( u ~= unit ) then
            u.gainAP( ap * ALLY_AP_MULT );
            PF.syncActionPoints( u );
          end
        end
      else
        for j = 1, team.units.length() do
          local u = team.units.get(j);
          u.gainAP( ap * OTHER_AP_MULT );
          PF.syncActionPoints( u );
        end
      end
    end
    
    -- expend move
    p.remainingMoves = p.remainingMoves -1;
    if( p.remainingMoves == 0 ) then
      -- advance to next team
      if( remote == false ) then
        state.elapsedAP = state.elapsedAP + ap;
        state.currentAP = 0;
        if( p.aiControl ) then
          p.endTurn = true;
        else
          state.endTurn();
          state.switchTeams();
        end
        return;
      end
    end
    
    -- check if there are any more available units
    local team = state.activePlayer.team;
    local avail = state.checkAvailability();
    if( remote == false and avail == false ) then
      state.elapsedAP = state.elapsedAP + ap;
      state.currentAP = 0;
      if( p.aiControl ) then
        p.endTurn = true;
      else
        state.endTurn();
        state.switchTeams();
      end
      return
    end
  end
  
  function state.endTurn()
    local data = {};
    data.id = NET_END_TURN;
    PF.sendData( data );
  end
  
  function state.checkAvailability()
    local team = state.activePlayer.team;
    local avail = false;
    for i = 1, team.units.length() do
      local u = team.units.get(i);
      if( u.available() ) then avail = true; end
    end
    return avail;
  end
  
  
  return state;
end
