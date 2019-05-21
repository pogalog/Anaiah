-- strategy
-- General structure for unit-based strategy. The functions which are
-- part of the strategy structure should be overridden by an implementation.

GOAL_ROUT = 1;
GOAL_KILL_TARGET = 2;
GOAL_REACH_TARGET = 3;
GOAL_DEFEND = 4;
GOAL_SURVIVE = 5;

function createStrategy()
  local strategy = {};
  
  strategy.violence = 0;
  strategy.synergy = 4;
  
  -- considers which actions to take
  function strategy.chooseActions()
  end
  
  function strategy.computePriority( action )
  end
  
  
  
  return strategy;
end
