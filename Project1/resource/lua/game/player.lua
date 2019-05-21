-- player

BLUE_TEAM = 1;
GREEN_TEAM = 2;
RED_TEAM = 3;

Game.Players = {};

function Game.createPlayer( team, ai )
  local player = {};
  player.userdata = nil;
  player.id = id;
  player.teamID = 0;
  player.team = team;
  player.name = "Personman";
  player.remainingMoves = 0;
  player.activeUnit = nil;
  player.aiControl = ai;
  player.control = nil;
  
  -- game flags
  player.endTurn = false;
  
  function player.assumeControl()
    if( player.control ~= nil ) then
      player.control.activate();
    end
  end
  
  return player;
end
