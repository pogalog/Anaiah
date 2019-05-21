-- action.lua
require( "game.ai.action_item" );

ACTION_MOVE_TARGET = 0;
ACTION_HEAL = 1;
ACTION_HEAL_ALLY = 2;
ACTION_ATTACK = 3;
ACTION_ITEM = 4;
ACTION_BUFF = 5;
ACTION_DEBUFF = 6;
ACTION_EXPLORE = 7;
ACTION_SCAVENGE = 8;
ACTION_AVOID_DANGER = 9;
ACTION_KAMIKAZE = 10;
ACTION_CHOKE = 11;
ACTION_ACTIVATE = 12;

function createAction( unit )
  local action = {};
  action.unit = unit;
  action.target = nil;
  action.actionType = nil;
  action.item = nil;
  action.priority = 0;
  action.items = createList();
  action.stepNumber = 0;
  action.name = "";
  action.assessed = false;
  action.collaborative = false;
  
  function action.addItem( actionItem )
    action.items.add( actionItem );
  end
  
  function action.print()
    print( action.name..": priority="..tostring( action.priority ) );
  end
  
  -- main function for an action which steps through the items in its list
  function action.step()
    action.stepNumber = action.stepNumber + 1;
    --print( 'step '..tostring(action.stepNumber) );
    action.items.get( action.stepNumber ).execute( action );
  end
  
  function action.execute()
    if( action.stepNumber < action.items.length() ) then
      action.step();
      -- action is not finished
      return false;
    else
      -- action is finished
      AIControl.nextAction();
      return true;
    end
  end
    
  
  return action;
end
